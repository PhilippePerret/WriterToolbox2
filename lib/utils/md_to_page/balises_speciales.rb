# encoding: utf-8
#
class MD2Page


  # Traitement de toutes les balises spéciales qu'on peut trouver dans
>
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
          def_note = def_notes.match(/\{\{#{idnote}:(.*?)\}\}/m).to_a[1].strip
          # Pour des questions d'affichage, on a pu ajouter des blancs en début de ligne. On les supprime tous
          # dans les explications de notes.
          def_note.gsub!(/^( |\t)+/,'')
          def_note = MD2Page.transpile(nil,{code: def_note, dest: nil, no_leading_p: true})
          notes_sorted << "#{dnote[:index]}&nbsp;#{def_note}".in_div(class: 'small')
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

  def formate_balises_references str, options = nil
    str.gsub!(/REF\[(.*?)\]/){
      args = $1.split('|').collect{|e|e.nil_if_empty}
      args.unshift(options[:narration_current_book_id])
      traite_lien_narration(*args)
    }
    str
  end
  def traite_lien_narration cur_book_id, page_id, titre = nil, ancre = nil
    page_id = page_id.to_i
    hpage = site.db.select(:cnarration,'narration',{id: page_id},[:titre,:livre_id]).first
    hpage != nil || raise("Impossible d'obtenir la page Narration ##{page_id}. Merci de vérifier l'identifiant.")
    c = "<a href=\"narration/page/#{page_id}"
    ancre != nil && c << "##{ancre}"
    c << "\" class=\"page\">#{titre || hpage[:titre]}</a>"
    bid = hpage[:livre_id]
    if bid != cur_book_id
      require './__SITE__/narration/_lib/_required/constants'
      c << " dans <a href=\"narration/livre/#{bid}\" class=\"livre\">#{Narration::LIVRES[bid][:hname]}</a>"
    end
    return c
  end

  # Formate les balises images
  #
  # +subfolder+ {String} Un nom de dossier qui peut être transmis
  # parfois pour indiquer un dossier narration ou un dossier
  # d'analyse.
  #
  def formate_balises_images str, options = nil
    str.match(/IMAGE\[/) || (return str)
      str.gsub!(/IMAGE\[(.+?)\]/){
        args = $1.split('|')
        args.unshift(options)
        traite_donnees_images(*args)
      }
  end

  # Retourne le code HTML pour une balise image
  #
  def traite_donnees_images options, path = nil, class_css = nil, legend = nil, style = nil, subfolder = nil

    # Path de l'image
    # (raise si elle est introuvable)
    imgpath = seek_image_path_of( path, options[:img_folder], subfolder)

    attrs = Hash.new
    img_attrs = Hash.new

    class_css = class_css.nil_if_empty
    legend    = legend.nil_if_empty
    style     = style.nil_if_empty

    legend && legend.gsub!(/'/, '’')

    case class_css
    when 'inline'
      legend && img_attrs.merge!(alt: legend)
    when 'fleft', 'fright'
      attrs.merge!(class: "image_#{class_css}")
    when 'plain'
      style.nil? && style = ''
      style << "width:100%;"
    end

    main_div_class =
      case class_css
      when 'inline' then nil
      when 'fleft', 'fright' then class_css
      else 'center'
      end

    attrs = attrs.collect {|k,v|"#{k}=\"#{v}\""}.join(' ')

    style && img_attrs.merge!(style: style)
    img_attrs = img_attrs.collect{|k,v|"#{k}=\"#{v}\""}.join(' ')
    img_tag = "<img src=\"#{imgpath}\" #{img_attrs} />"

    case class_css
    when 'inline'
      img_tag
    else
      legend  = legend ? "<div class=\"img_legend\">#{legend}</div>" : ''
      img_tag = "<div class=\"image\">#{img_tag}</div>"
      "<div class=\"#{main_div_class} image\">#{img_tag}#{legend}</div>"
    end
  end

  def seek_image_path_of relpath, folder = nil, other_folder = nil
    dossiers = [
      '',
      './img/',
      "./img/narration/",
      "./img/analyse/",
    ]
    if folder
      dossiers += [
        folder,
        "./img/#{folder}/",
        "./img/narration/#{folder}/",
        "./img/analyse/#{folder}/"
      ]
    end
    if other_folder
      dossiers += [
        other_folder,
        "./img/#{other_folder}",
        "./img/narration/#{other_folder}",
        "./img/analyse/#{other_folder}"
      ]
    end
    paths_seek = Array.new
    dossiers.each do |prefix_path|
      testedpath = File.join(prefix_path,relpath)
      File.exist?(testedpath) && (return testedpath)
      paths_seek << testedpath
    end
    rc = "\n"
    raise "Impossible de trouver l'image de relative path `#{relpath}`.\nElle a été recherchée dans :\n#{paths_seek.join(rc)}"
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
      numero, libelle, extra = $1.split('|').collect{|e| e.nil_if_empty}
      # Je ne sais plus à quoi sert `extra`, il peut avoir
      # la valeur 'true'
      libelle ||= "scène ##{numero}"
      libelle.in_a(onclick:"Scenes.show.call(Scenes,#{numero})")
    }
    str
  end

 def formate_balises_livres str
   str.gsub!(/LIVRE\[(.*?)\]/){
     lien_vers_livre( *$1.split('|').collect{|e|e.nil_if_empty} )
   }
   return str
 end
 def lien_vers_livre livre_id, titre = nil
   require './__SITE__/narration/_lib/_required/constants'
   hlivre = Narration::BIBLIOGRAPHIE[livre_id]
   titre ||= hlivre[:titre]
   titre  = titre.in_span(class: 'livre')
   auteur = hlivre[:auteur].in_span(class: 'auteur')
   annee  = hlivre[:annee].to_s.in_span(class: 'annee')
   "#{titre} (#{auteur}, #{annee})"
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

end #/MD2Page
