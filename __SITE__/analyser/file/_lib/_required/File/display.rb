# encoding: utf-8
#
# Tout ce qui concerne l'affichage du fichier, que ce soit :
#
# - pour l'aperçu normale, la simple lecture en mode analyste
# - pour l'édition du fichier, la modification de son contenu
# - pour la comparaison des versions.
#
class Analyse
  class AFile

    # Sortie du fichier à afficher dans la page
    #
    # Dépend de l'opération choisie. Par défaut, c'est l'opération 'voir'
    #
    def output ope
      contenu_displayed(ope)
    end

    
    # Titre affiché dans la page
    #
    # Attention, il n'est pas lié à `output` comme `contenu_displayed`.
    def titre_displayed
      <<-HTML
      #{data[:titre]} <span class="tiny">(id ##{id})</span>
      HTML
    end

    # Le contenu affiché, en fonction de celui qui visite
    #
    # Qu'il y ait un fichier ou non, le div est inscrit, car il peut
    # aussi contenir le formulaire d'édition du texte.

    def contenu_displayed ope

      <<-HTML
      <div class="file_content" id="file-#{id}-content">
        #{
          if ufiler.redactor? || ufiler.contributor? || ufiler.corrector? || ufiler.admin? || visible_par_inscrit?
            case ope
            when 'edit', 'save' then afficher_formulaire_edition
            when 'compare'      then operation_compare
            when 'contributors' then afficher_contributors
            else afficher_apercu
            end
          else
            'Vous n’avez pas accès au contenu de ce fichier.'
          end
        }
      </div>
      HTML
    end

    # --------------------------------------------------------------------------------
    # 
    #     LES DIFFÉRENTS CONTENUS POSSIBLES :
    #
    #         - FORMULAIRE POUR ÉDITER LE FICHIER -> afficher_formulaire_edition
    #
    #         - APERÇU DU FICHIER TEL QU'IL APPARAITRA -> afficher_apercu
    #
    #         - LISTING DES DIFFÉRENTES VERSIONS -> afficher_liste_versions
    #
    #         - AFFICHAGE DE LA DIFFÉRENCE ENTRE DEUX VERSIONS -> afficher_comparaison_versions
    #
    #         
    # --------------------------------------------------------------------------------

    def operation_compare
      version1 = param(:version1).nil_if_empty
      version2 = param(:version2).nil_if_empty
      if version1 && version2
        afficher_comparaison_versions(version1, version2)
      else
        if version1 || version2
          __notice('Vous devez choisir les deux versions à comparer.')
        end
        afficher_liste_versions
      end
    end

    def afficher_formulaire_edition
      require_form_support
      <<-HTML
      <form id="edit_file_form" method="POST">
        <input type="hidden" name="op" value="save" />

        <textarea 
            id="file_content" name="file[content]" 
            onchange="onModifiedContent(this)">#{content_version(param(:v) || :last)}</textarea>

        <div class="buttons">
          <input type="submit" class="main btn" value="Enregistrer" />
        </div>
      </form>
      HTML
    end


    # Affichage et gestion (suivant le privilège) de la 
    # LISTE DES CONTRIBUTEURS AU FICHIER
    # (et seulement au fichier)
    #
    def afficher_contributors

      case param(:act)
      when 'remove'
        require_lib('analyser/file:act_on_contributor')
        remove_contributor( param(:cid).to_i )
      when 'add'
        require_lib('analyser/file:act_on_contributor')
        add_contributor( param(:new_contributor) )
      end

      # Si c'est un administrateur ou le créator du fichier, on 
      # trouve un formulaire pour ajouter un contributeur
      can_admin = ufiler.creator? || ufiler.admin?
      # Comme on va devoir afficher les contributeurs au fichier et
      # se servir des non-contributeur au fichier mais contributeur à 
      # l'analyse pour créer le menu pour ajouter de nouveaux contributeur,
      # il faut que je relève tous les contributeurs des deux côtés
      request = <<-SQL
        SELECT upf.user_id AS id, upf.role, u.pseudo, upf.created_at
          FROM user_per_file_analyse upf
          INNER JOIN `boite-a-outils_hot`.users AS u ON u.id = upf.user_id
          WHERE file_id = #{self.id}
          ORDER BY role DESC
      SQL
      site.db.use_database(:biblio)

      # On prend les contributeurs à ce fichier et on en fait un Hash avec en
      # clé leur identifiant et en valeur un hash contenant {:id, :pseudo, :role}
      # Note : on met en hash pour pouvoir distinguer les contributeurs de l'analyse
      # qui participe à ce fichier et ceux qui n'y participe pas (utilisés dans le 
      # menu pour en ajouter)
      file_contributors = Hash.new
      file_non_conts    = Hash.new # les nouveaux contributeurs possibles

      site.db.execute(request).each do |h| 
        file_contributors.merge!( h[:id] => h )
      end
      
      analyse.contributors.each do |h| 

        if file_contributors.key?(h[:id])

          # <= Ce contributeur à l'analyse contribue au fichier
          # => C'est dans la liste des contributeurs au fichier qu'on l'affichera
          # => On ne fait rien

        else

          # <= Ce contributeur à l'analyse en contribue pas au fichier
          # => On l'ajoute dans la liste des contributeurs possibles
          file_non_conts.merge!( h[:id] => h )

        end
      end

      #debug "Contributeurs analyse : #{analyse.contributors.inspect}"
      #debug "Contributeurs fichier : #{file_contributors.inspect}"
      #debug "Nouveaux contributeurs possibles : #{file_non_conts.inspect}"

      if can_admin
        require_form_support
        # On doit prendre les contributeurs à l'analyse
        # Noter que pour le moment, tout le monde est affiché ici alors qu'il ne faudrait
        # en vérité que les contributeurs qui ne sont pas déjà impliqués dans le fichier.
        # Comme on a 
        menu_new_contributors = Form.build_select({
          name:   'new_contributor[id]', 
          id:     'new_contributor_id', 
          values: file_non_conts.collect{|uid, h|[uid, h[:pseudo]]}
        })
        form_add =
          <<-HTML
         <form class="none" id="new_contributor_form" method="POST">
           <input type="hidden" name="op" value="contributors" />
           <input type="hidden" name="act" value="add" />
         #{menu_new_contributors} 
         <select id="new_contributor_role" name="new_contributor[role]">
          <option value="2">Rédacteur seulement</option>
          <option value="6">Rédacteur et correcteur</option>
          <option value="4">Correcteur seulement</option>
         </select>
         <input type="submit" class="btn medium main" value="Ajouter" />
       </form>
          HTML
      end

      <<-HTML
      <ul class="simple" id="contributors">
      #{
        file_contributors.collect do |cid, hu|
          cont = User.get(cid)
          # Si c'est le créateur ou un administrateur, on trouve
          # un bouton pour retirer le contributeur. Sauf évidemment si
          # c'est ce créateur.
          btn_remove = 
            if cid != ufiler.id && can_admin 
              "<a class=\"tiny\" href=\"analyser/file/#{id}?op=contributors&cid=#{cid}&act=remove\">supprimer</a>"
            else
              ''
            end
          <<-HTM
          <li class="contributor" id="contributor-#{cid}">
            <span class="pseudo">#{User.pseudo_linked(hu, false, 'nodeco')}</span>
            <span class="role">#{User.human_role(hu[:role], cont)}</span>
            <span class="depuis">#{hu[:created_at].as_human_date('%d %m %Y')}</span>
            #{can_admin ? btn_remove : ''}
          </li>
          HTM
        end.join
      }
      </ul>
      #{can_admin ? form_add : ''}
      HTML
    end


    # Affichage de la LISTE DES VERSIONS pour comparaisons
    #
    def afficher_liste_versions
      require_form_support
      <<-HTML
      <div class="titre">Liste des versions du fichier</div>
      <div class="tiny italic discret">
      Noter qu'elles sont en ordre inverse c'est-à-dire que la première version (la plus haute est aussi la plus récente.)
      </div>
      <div class="tiny">Choisissez la première version à comparer en la cochant dans la première colonne de boutons-radio, choisissez la deuxième version à comparer en la cochant dans la seconde colonne de boutons-radio, puis cliquez sur le bouton “Comparer” pour comparer les deux versions.</div>
      <div class="tiny">Notez que si vous choisissez d’<strong>éditer</strong> une version, ce n'est pas cette version que vous modifierez, vous créerez <strong>une nouvelle dernière version</strong> du fichier qui repartira de cette version. <span class="warning">Ne le faites donc qu'en toute connaissance de cause.</span></div>
      <form id="versions_compare_form" method="POST">
        <input type="hidden" name="op" value="compare" />
        <ul class="simple">
        #{
        Dir["#{fpath}/*.*"].sort.reverse.collect do |fversion|
          fversion_date = File.stat(fversion).mtime.to_i.as_human_date
          nversion = File.basename(fversion)
          nversion_disp = "#{nversion} - #{fversion_date}"
          <<-SHTML
            <li class="version">
              <input type="radio" id="v1-#{nversion}" name="version1" value="#{nversion}" />
              <input type="radio" id="v2-#{nversion}" name="version2" value="#{nversion}" />
              #{version_name_linked(nversion_disp)}
            </li>
          SHTML
        end.join
        }
        </ul>
        <div class="buttons">
          <input type="submit" class="main medium btn" value="Comparer" />
        </div>
      </form>
      HTML
    end

    # Affichage de la comparaison de version
    #
    # Les versions à comparer se trouvent dans les paramètres :version1 et :version2
    # et contiennent les noms des fichiers. Si ces paramètres sont vides, on prend les
    # deux dernières versions
    #
    # @param {String} version1
    #                 Le nom complet du fichier 1
    # @param {String} version2
    #                 Le nom complet du fichier 2
    #
    def afficher_comparaison_versions version1, version2

      # TODO On pourrait enregistrer ces différences puisque les fichiers ne
      # peuvent pas être modifié. Donc après la première demande de différence, on
      # pourrait enregistrer le code produit par diff pour un fichier qui porterait
      # le nom `diff_<version1>-<version2>.txt` et le charger la prochaine fois 
      # qu'on voudrait voir la différence.

      # On classe pour que la version 1 soit toujours la plus ancienne des
      # deux versions. Leur nom suffit puisqu'il est composé à l'aide du time
      # d'enregistrement du fichier
      version1, version2 = [version1, version2].sort_by{|v| v.split('-')[0]}
      
      cmd = "cd \"#{File.expand_path(fpath)}\"; diff -u #{version1} #{version2}"
      res = `#{cmd}`.force_encoding('utf-8')
      cmp = ""
      div_version1 = div_version2 = nil
      res.split("\n").collect do |p| 
        p.start_with?('\\') && (next '')
        classP = ''
        case
        when p.start_with?('---') then 
          div_version1 = "<div class=\"green\">#{reduce_comparaison_name(p)}</div>"
          next
        when p.start_with?('+++') then
          div_version2 = "<div class=\"blue\">#{reduce_comparaison_name(p)}</div>"
          next
        when p.start_with?('-') then classP = 'green'
        when p.start_with?('+') then classP = 'blue'
        end
        cmp << "<div class=\"#{classP}\">#{p}</div>"
      end.join
      <<-HTML
      <div class="comparaison">
        <div class="versions">
          <span class="libelle">Comparer l'ancienne version :</span>
          #{div_version1}
          <span class="libelle">… à la version plus récente :</span>
          #{div_version2}
        </div>
        <div class="diffs">
          #{cmp}
        </div>
      HTML
    end

    # APERCU du fichier tel qu'il pourra apparaitre à l'utilisateur
    #
    # Pour le moment, c'est juste un formatage "simple" du fichier markdown
    # original, mais ça sera des choses beaucoup plus complexes à l'avenir.
    def afficher_apercu
      if File.exist?(fpath_version(:last))
        # TODO Utiliser une librairie `build_page` qui serait dans "analyse"
        # et qui servirait aussi pour l'affichage normal des analyses.
        #
        formate_file(fpath_version(:last))
      else
        '[Ce fichier ne possède pas encore de contenu. Cliquer le bouton “edit” pour le définir.]'
      end
    end
    
    # --------------------------------------------------------------------------------
    # 
    #    / FIN AFFICHAGES 
    #         
    # --------------------------------------------------------------------------------


    # Prépare la ligne qui affiche le nom du fichier, son auteur (avec lien), sa
    # date de version et un lien pour l'éditer.
    #
    # @param {String} n
    #                 Nom du fichier de version tel qu'il apparait dans le
    #                 résultat de la comparaison.
    def reduce_comparaison_name n
      n = n[3..-1].strip
      n = n.split(' ') # ['nom fichier', 'JJ-MM-YY', 'HH:MM:SS.MSSSSS', '+0200']
      n[0] = version_name_linked(n[0])
      n[2] = n[2].split('.')[0] 
      n = n[0..2].join(' ')
    end

    # Retourne une version du nom du fichier avec ajouté un lien pour l'éditer
    # et le nom de son auteur.
    def version_name_linked n
      lien = "<a class=\"edit\" href=\"analyser/file/#{id}?op=edit&v=#{n}\">[Éditer]</a>"
      aut  = User.get(n.split('.')[0].split('-')[1].to_i)
      return "#{lien} <span class=\"bold\">#{n}</span> - #{User.pseudo_linked(aut)} -"
    end

    # Retourne le contenu de la version voulu du fichier
    #
    # @param {String|Symbol|Hash} version
    # Cf. la méthode `fpath_version` pour les (nombreuses) valeurs possibles
    #
    def content_version version
      File.exist?(fpath) || (return '')
      fversion = fpath_version(version)
      fversion != nil || (return '')
      File.read(fversion).force_encoding('utf-8')
    end

    # Retourne le path voulu de la version demandée +version+
    #
    # @param {String|Symbol|Hash} version
    #    - NIL. Quand c'est nil, c'est qu'on veut obtenir le nom de la version
    #      qui doit servir à enregistrer le texte courant.
    #    - le nom du fichier (complet, avec extension)
    #    - un symbol tel que :
    #       :last       Le dernier fichier
    #       :first      Le première
    #    - un Hash tel que :
    #       :before     Le fichier avant ce fichier
    #       :after      Le fichier après ce fichier
    def fpath_version version = nil
      @versions ||= Dir["#{fpath}/*.*"].sort
      case version

      when NilClass
        
        # Le cas où `version` est nil est spécial : il correspond au moment où
        # l'user sauve son fichier. Dans ce cas, pour qu'il ne multiplie pas les
        # fichiers, on mémorise dans cette session le nom de son fichier de version
        # courant et on lui redonne si c'est un autre enregistrement.
        @fpath_version ||= 
          begin
            name_session_variable = "version_file_analyse_#{self.id}-#{ufiler.id}"
            valsession = site.session[name_session_variable]
            # Note : la vérification ci-dessous sur l'ID de l'ufiler est nécessaire
            # seulement pour les tests, quand dans la même session (le même scénario),
            # je passe d'un utilisateur à l'autre. Dans le cas contraire, deux users
            # travailleraient le même fichier.
            if valsession && valsession.split('-').last.to_i == ufiler.id 
              valsession
            else
              f = File.join(fpath, "#{Time.now.to_i}-#{ufiler.id}.#{extension}")
              site.session[name_session_variable] = f
              f
            end
          end

        
      when :last
        return @versions.last
      when :before_last
        return @versions[-2]
      when String
        return File.join(fpath, version)
      else
        'Je ne sais pas quelle version du fichier retourner'
      end
    end


    # Boutons pour éditer, publier, etc. le fichier courant
    # Les boutons sont affichés en fonction du statut de l'user qui visite
    # et de l'opération courante, qui est toujours définie ici.
    #
    # @param {Symbol} where
    #                 :top ou :bottom pour savoir où ils sont placés
    # @param {String} ope
    #                 L'opération courante, p.e. 'voir' ou 'publish'
    #
    def buttons where, ope
      is_analyse_creator = analyse.uanalyser.creator?

      can_edit  = ufiler.redactor? || is_analyse_creator || ufiler.corrector? || ufiler.admin?
      can_admin = is_analyse_creator || ufiler.admin? || ufiler.creator?

      boutons = String.new

      # Les boutons, avec en clé leur préfixe de méthode ("bouton_<prefixe>") et
      # en valeur true ou false suivant qu'en la circonstance courante on peut les
      # afficher ou non.
      {
        'contributors' => true,
        'remove'       => can_admin,
        'publish'      => can_admin,
        'compare'      => true,
        'edit'         => can_edit,
        'voir'         => true
      }.each do |kbutton, visible|
        kbutton == 'compare' || (visible && ope != kbutton) || next
        boutons << send("bouton_#{kbutton}".to_sym)
      end
      
     <<-HTML
     <div class="file_buttons #{where}">#{boutons}</div>
     HTML
    end


    def bouton_edit
      build_bouton('edit', 'éditer')
    end
    def bouton_publish
      build_bouton('publish', 'publier', 'green')
    end
    def bouton_remove
      build_bouton('rem', 'détruire', 'warning')
    end
    def bouton_voir
      build_bouton('voir')
    end
    def bouton_compare
      Dir["#{fpath}/*.*"].count > 1 ? build_bouton('compare') : ''
    end
    def bouton_contributors
      build_bouton('contributors', 'contributeurs')
    end

    # Construit les boutons

    def build_bouton ope, tit = nil, css = nil
      simple_link("analyser/file/#{id}?op=#{ope}", tit || ope, css)
    end
  end #/AFile
end #/Analyse
