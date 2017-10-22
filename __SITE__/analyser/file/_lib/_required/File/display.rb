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

    # Le contenu affiché, en fonction de celui qui visite
    #
    # Qu'il y ait un fichier ou non, le div est inscrit, car il peut
    # aussi contenir le formulaire d'édition du texte.

    def contenu_displayed ope

      <<-HTML
      <div class="file_content" id="file-#{id}-content">
        #{
          if ufiler.redactor? || ufiler.contributor? || 
              ufiler.corrector? || ufiler.admin? || visible_par_inscrit?
            if ['edit','save'].include?(ope)
              formulaire_edition
            elsif ope == 'compare'
              version1 = param(:version1).nil_if_empty
              version2 = param(:version2).nil_if_empty
              if version1 && version2
                comparer_versions(version1, version2)
              else
                afficher_liste_versions
              end
            else
              apercu
            end
          else
            'Vous n’avez pas accès au contenu de ce fichier.'
          end
        }
      </div>
      HTML
    end

    def formulaire_edition
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

    # Affichage de la liste des versions pour comparaisons
    #
    def afficher_liste_versions
      require_form_support
      <<-HTML
      <form id="versions_compare_form" method="POST">
        <input type="hidden" name="op" value="compare" />
        <ul class="simple">
        #{
        Dir["#{fpath}/*.*"].sort.collect do |fversion|
          nversion = File.basename(fversion)
          <<-SHTML
            <li class="version">
              <input type="radio" id="v1-#{nversion}" name="version1" value="#{nversion}" />
              <input type="radio" id="v2-#{nversion}" name="version2" value="#{nversion}" />
              #{version_name_linked(nversion)}
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
    def comparer_versions version1, version2

      # TODO On pourrait enregistrer ces différences puisque les fichiers ne
      # peuvent pas être modifié. Donc après la première demande de différence, on
      # pourrait enregistrer le code produit par diff pour un fichier qui porterait
      # le nom `diff_<version1>-<version2>.txt` et le charger la prochaine fois 
      # qu'on voudrait voir la différence.
      
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
          <span class="libelle">Comparer la version :</span>
          #{div_version1}
          <span class="libelle">… à la version :</span>
          #{div_version2}
        </div>
        <div class="diffs">
          #{cmp}
        </div>
      HTML
    end

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

    def apercu
      if File.exist?(fpath_version(:last))
        formate_file(fpath_version(:last))
      else
        '[Ce fichier ne possède pas encore de contenu. Cliquer le bouton “edit” pour le définir.]'
      end
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

  end #/AFile
end #/Analyse
