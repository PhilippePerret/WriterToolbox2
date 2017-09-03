# encoding: utf-8
#
class MD2Page
  class << self


    # Traitement de toutes les balises spéciales qu'on peut trouver dans
    # les textes (Narration, Unan, etc.)
    def traite_balises_speciales
      @wcode = formate_balises_propres(@wcode, options)
    end

    def formate_balises_propres str, options = nil

      # p = 'pour_voir.txt'
      # File.unlink(p) if File.exist?(p)
      # File.open(p, 'wb'){|f| f.write "AU DÉPART\n\n#{str}"}

      str = formate_balises_include(str)
      str = formate_balises_exemples(str)

      # File.open(p, 'a'){|f| f.write "\n\nAPRÈS CORRECTION\n\n#{str}"}

      str = evaluate_codes_ruby(str)
      str = formate_mises_en_forme_propres(str)
      str = traite_document_in_code(str)
      str = formate_balises_notes(str)
      str = formate_balises_references(str)
      str = formate_balises_images(str, options)
      str = formate_balises_mots(str)
      str = formate_balises_films(str)
      str = formate_balises_scenes(str)
      str = formate_balises_livres(str)
      str = formate_balises_personnages(str)
      str = formate_balises_realisateurs(str)
      str = formate_balises_producteurs(str)
      str = formate_balises_acteurs(str)
      str = formate_balises_auteurs(str)
      str = formate_termes_techniques(str)
      str = formate_balises_citations(str)

        # debug "STRING APRÈS = #{str.gsub(/</,'&lt;').inspect}"
      return str
    end

    # Formate les balises INCLUDE qui permettent d'inclure des
    # fichiers dans d'autres fichiers.
    # @usage
    #   INCLUDE[path/relatif/to/file.ext]
    def formate_balises_include str
      str.gsub!(/INCLUDE\[(.*?)\]/){
        sfile = SuperFile.new($1.split('/'))
        if sfile.exist?
          "\n\n" + sfile.read + "\n\n"
        else
          # TODO Ici, alerte administrateur
          "INSERTION FICHIER INTROUVABLE : #{sfile.path}"
        end
      }
      str
    end


    def formate_mises_en_forme_propres str

      # Le format pour mettre une sorte de note de marge, avec un texte
      # réduit à droite. Ce format est défini par des ++ (au moins 2)
      str = str.gsub(/^(.*?) (\+\++) (.*?)$/){
        note_marge  = $1
        les_plus    = $2
        texte       = $3
        css = {2 => 'vingt', 3 => 'vingtcinq', 4 => 'trente', 5 => 'trentecinq'}[les_plus.length]

        # Puisque le code sera mise entre balises DIV, il ne sera
        # pas corrigé par kramdown. Il faut donc le faire ici, suivant
        # le code du fichier.
        texte = texte.formate_balises_propres
        texte =
          if texte.match(/<%/)
            texte.deserb
          else
            texte.respond_to?(:kramdown) || site.require_module('kramdown')
            texte.kramdown
          end
        (
          note_marge.strip.in_div(class: 'notemarge') +
          texte.strip
        ).in_div(class: "mg #{css}")
      }

      return str
    end


    # Insertion des exemples (balises EXEMPLE)
    #
    # Elles fonctionnent comme les inclusions, sauf que le paramètre
    # est un chemin relatif depuis le dossier :
    #   ./data/unan/page_cours/cnarration/exemples/_textes_/
    # ou
    #   ./data/unan/page_semidyn/cnarration/exemples/_textes_/
    #
    # La méthode est appelée par le fichier :
    #   ./objet/cnarration/lib/module/page/build.rb
    def formate_balises_exemples str
      str.gsub!(/EXEMPLE\[(.*?)\]/){
        rel_path = $1.freeze
        path_in_cours   = self.class.folder_textes_exemples_in_cours + rel_path
        path_in_semidyn = self.class.folder_textes_exemples_in_semidyn + rel_path
        temp_line = "<adminonly>#{'Éditer l’exemple ci-dessous'.in_a(href: "site/edit_text?path=%s", target: :new)}</adminonly>\n"

        if path_in_cours.exist?
          (temp_line % [CGI.escape(path_in_cours.to_s)]) +
          formate_exemple_in_path(path_in_cours)
        elsif path_in_semidyn.exist?
          (temp_line % [CGI.escape(path_in_semidyn.to_s)]) +
          formate_exemple_in_path(path_in_semidyn)
        else
          error "Un fichier exemple introuvable : #{rel_path}" +
          "(recherché dans #{path_in_cours} et #{path_in_semidyn})".in_div(class: 'small')
          "[ERREUR DE FICHIER EXEMPLE INCONNU : #{rel_path}]"
        end.gsub(/\r/,'')
      }
      str
    end

    # Pour formater les exemples avec Kramdown, il faut les
    # traiter de façon particulière, pour ne pas transformer
    # les parties des notes et les marques `DOC/`. On ne peut
    # pas se contenter d'utiliser la méthode String#kramdown
    #
    # ÇA FOIRE COMPLÈTEMENT LE TRUC, DONC JE ME CONTENTE DE
    # CORRIGER "MANUELLEMENT" QUELS TRUCS MARKDOWN
    #
    def formate_exemple_in_path superfile
      sfstr = superfile.read.gsub(/\r/,'')
      sfstr.gsub!(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
      sfstr.gsub!(/\*(.*?)\*/, '<em>\1</em>')
      return sfstr
    end

    class << self
      def folder_textes_exemples_in_cours
        @folder_textes_exemples_in_cours ||= SuperFile.new('./data/unan/pages_cours/cnarration/exemples/_textes_')
      end
      def folder_textes_exemples_in_semidyn
        @folder_textes_exemples_in_semidyn ||= SuperFile.new('./data/unan/pages_semidyn/cnarration/exemples/_textes_')
      end
    end

    # Évalue le code situé entre balise RUBY_ et _RUBY
    #
    def evaluate_codes_ruby(str)
      str.gsub!(/RUBY_(.*?)_RUBY/m){
        code_ruby = $1.strip
        eval(code_ruby)
      }
      return str
    end

    # Formatage des notes
    # Cf. le mode d'emploi (narration) pour le détail de l'utilisation.
    # Résumé : les notes doivent être formatées de cette façon :
    #     Texte avec note {{1}}
    #     <!-- NOTES -->
    #     {{1: Ceci est la première note}}
    #     <!-- /NOTES -->
    # Peu importe l'ordre des numéros, ils seront toujours remplacés par
    # des numéros incrémentés.
    #
    def formate_balises_notes str

      # Il ne faut procéder au formatage que s'il y a des notes
      str =~ /\{\{([0-9]+)\}\}/ || (return str)

      str.gsub!(/\{\{([0-9]+)\}\}\{\{([0-9]+)\}\}/){
        "{{#{$1}}}<sup class='virgule'>,</sup>{{#{$2}}}"
      }

      # Pour conserver la correspondance entre l'ID de note attribué au
      # cours de la rédaction et l'INDEX attribué ici pour avoir un ordre
      # incrémentiel (alors que les ID ne se trouvent pas forcément dans
      # l'ordre du document)
      # C'est un Array avec en clé l'ID donné à la rédaction et en valeur
      # un Hash contenant {:id, :index}
      liste_notes = Hash.new

      # Pour incrémenter régulièrement les index de note
      inote = 0

      # Remplacement des renvois aux notes et collecte
      # des notes
      #
      str.gsub!(/ ?\{\{([0-9]+)\}\}/){
        # L'identifiant attribué dans le document
        id_note = $1.freeze

        if liste_notes.key?(id_note)
          index_note = liste_notes[id_note][:index]
        else
          # L'index réel pour que les notes soient dans l'ordre
          inote += 1
          index_note = inote.freeze
          liste_notes.merge!(id_note => {id: id_note, index: index_note})
        end
        "<sup class='note_renvoi'>#{index_note}</sup>"
      }

      # On classe la liste des notes
      liste_notes = liste_notes.sort_by{|idnote, dnote| dnote[:index]}
      # debug "liste_notes : #{liste_notes.inspect}"

      # Recherche des blocs `<!-- NOTES -->`...`<!-- /NOTES -->`
      # pour traiter les notes. Ce bloc doit forcément être présent, qui
      # contient la définition des notes.
      if str =~ /<\!-- NOTES -->/ && str =~ /<\!-- \/NOTES -->/
        str.gsub!(/<\!-- NOTES -->(.*?)<\!-- \/NOTES -->/m){
          def_notes = $1.strip.freeze
          notes_sorted = String.new
          liste_notes.each do |idnote, dnote|
            if def_notes =~ /\{\{#{idnote}:/
              def_note = def_notes.match(/\{\{#{idnote}:(.*?)\}\}/).to_a[1].strip
              notes_sorted << "#{dnote[:index]}   #{def_note}".in_div(class: 'small')
            end
          end

          # On remplace le bloc par la liste des notes classées
          notes_sorted.in_div(class: 'bloc_notes')
        }
      else
        raise 'Des notes sont présentes dans cette page, il faut impérativement définir la définition de ces notes entre la balise `&lt;!-- NOTES -->` et la balise `&lt;!-- /NOTES -->`.'
      end

      return str
    end

    def formate_balises_references str
      str.gsub!(/REF\[(.*?)\]/){
        pid, ancre, titre = $1.split('|')
        if titre.nil? && ancre != nil
          titre = ancre
          ancre = nil
        end
        lien.cnarration(to: :page, from_book:$narration_book_id, id: pid.to_i, ancre:ancre, titre:titre)
      }
      str
    end

    # Formate les balises images
    #
    # +subfolder+ {String} Un nom de dossier qui peut être transmis
    # parfois pour indiquer un dossier narration ou un dossier
    # d'analyse.
    #
    def formate_balises_images str, options = nil
      str.match(/(IMAGE|IMG)\[/) || (return str)
      str.gsub!(/(?:IMAGE|IMG)\[(.+?)\]/){
        args = $1.split('|')
        args.unshift(options)
        traite_donnees_images(*args)
      }
    end

    # Retourne le code HTML pour une balise image
    #
    def traite_donnees_images options, path = nil, class_css = nil, legend = nil, style = nil

      # Path de l'image
      # (raise si elle est introuvable)
      imgpath = seek_image_path_of( path, options[:img_folder])

      attrs = Hash.new

      class_css = class_css.nil_if_empty
      legend    = legend.nil_if_empty
      style     = style.nil_if_empty

      legend && legend.gsub!(/'/, '’')
      legend = legend ? "<div class=\"img_legend\">#{legend}</div>" : ''
      
      case class_css
      when 'inline'
        legend && attrs.merge!(alt: legend)
      when 'fleft', 'fright'
        attrs.merge!(class: "image_#{class_css}")
      when 'plain'
        style.nil? && style = ''
        style << "width:100%;"
      end

      style && attrs.merge!(style: style)
      attrs = attrs.collect { |attr, val| "#{attr}=\"#{val}\"" }.join(' ')

      img_tag = "<img src=\"#{imgpath}\" #{attrs} />"
      
      case class_css
      when 'fleft', 'fright'
        "<div class=\"image_#{class_css}\">#{img_tag + legend}</div>"
      when :inline
        img_tag
      else
        "<center class=\"image\"><div class=\"image\">#{img_tag}</div>#{legend}</center>"
      end
    end

    def seek_image_path_of relpath, folder = nil
      [
        '',
        './img/',
        "./img/narration/",
        "./img/narration/#{folder}/",
        "./img/analyse/",
        "./img/analyse/#{folder}/",
        "#{folder}" # narration ou autre
      ].each do |prefix_path|
        goodpath = "#{prefix_path}#{relpath}"
        File.exist?(goodpath) && (return goodpath) 
      end
      raise "Impossible de trouver l'image de relative path `#{relpath}`"
    end
    def formate_balises_mots str
      str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){ "<a href=\"scenodico/show/#{$1}\" class=\"mot\">#{$2}</a>"}
      str
    end

    def formate_balises_citations str
      str.gsub!(/CITATION\[([0-9]+)\|(.*?)\]/){ lien.citation($1.to_i, $2.to_s) }
      str
    end

    def formate_balises_films str
      @films_already_traited ||= Hash.new 
      str.gsub!(/FILM\[(.*?)(?:\|(.*?))?\]/){ 
        hfilm = site.db.select(:biblio,'filmodico',{film_id:$1},[:id,:titre,:realisateur,:annee,:titre_fr]).first
        "<a href=\"filmodico/show/#{hfilm[:id]}\" class=\"film\">#{titre_film_for hfilm}</a>"
      }
      str
    end
    def titre_film_for hfilm
      t = String.new
      t << "<span class=\"titre\">#{hfilm[:titre]}</span>"
      if @films_already_traited.key?(hfilm[:id])
        return t
      else
        @films_already_traited.merge!(hfilm[:id] => true)
      end
      dpar = Array.new
      hfilm[:titre_fr] && dpar << "<span class=\"titrefr\">#{hfilm[:titre_fr]}</span>"
      hreal = JSON.parse(hfilm[:realisateur]).first
      dpar << "<span class=\"realisateur\">#{(hreal['prenom']+' '+hreal['nom']).strip}</span>"
      dpar << "<span class=\"annee\">#{hfilm[:annee]}</span>"
      t << " (#{dpar.join(', ')})"
      return t
    end

    def formate_balises_scenes str # Analyses
      str.gsub!(/SCENE\[(.*?)\]/){
        numero, libelle, extra = $1.split('|').collect{|e| e.strip}
        # Je ne sais plus à quoi sert `extra`, il peut avoir
        # la valeur 'true'
        libelle ||= "scène #{numero}"
        libelle.in_a(onclick:"$.proxy(Scenes,'show',#{numero})()")
      }
      str
    end

    def formate_balises_livres str
      str.gsub!(/LIVRE\[(.*?)\]/){
        ref, titre = $1.split('|')
        lien.livre(titre, ref)
      }
      formate_balises_colon(str,'livre')
    end

    def formate_balises_personnages str
      formate_balises_colon(str,'personnage')
    end

    def formate_balises_acteurs str
      formate_balises_colon(str,'acteur')
    end

    def formate_balises_realisateurs str
      formate_balises_colon(str,'realisateur')
    end

    def formate_balises_producteurs str
      formate_balises_colon(str,'producteur')
    end

    def formate_balises_auteurs str
      formate_balises_colon(str,'auteur')
    end

    def formate_termes_techniques str
      formate_balises_colon(str,'tt')
    end

    def formate_balises_colon str, balise
      str.gsub!(/#{balise}:\|(.*?)\|/, "<#{balise}>\\1</#{balise}>")
      str.gsub!(/#{balise}:(.+?)\b/, "<#{balise}>\\1</#{balise}>")
      str
    end


  end #/<< self
end #/MD2Page
