# encoding: utf-8
class Scenodico
  class Mot

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
    end

    # --------------------------------------------------------------------------------
    #
    #     MÉTHODES DE DONNÉES 
    #
    # --------------------------------------------------------------------------------

    def mot
      @mot ||= dparam[:mot] || data[:mot]
    end
    def definition
      @definition ||= dparam[:definition] || data[:definition]
    end
    def liens
      @liens ||= dparam[:liens] || data[:liens]
    end
    def categories
      @categories ||= dparam[:categories] || data[:categories]
    end
    def relatifs
      @relatifs ||= dparam[:relatifs] || data[:relatifs]
    end
    def synonymes
      @synonymes ||= dparam[:synonymes] || data[:synonymes]
    end
    def contraires
      @contraires ||= dparam[:contraires] || data[:contraires]
    end

    # Les données du mot dans les paramètres, i.e. dans le formulaire soumis
    def dparam
      @dparam ||= param(:mot) || Hash.new
    end

    # --------------------------------------------------------------------------------
    #
    #     MÉTHODES D'ENREGISTREMENT
    #
    # --------------------------------------------------------------------------------

    # Méthode de sauvegarde des données
    #
    # En fonction de la définition de `id`, la méthode sait s'il s'agit d'une
    # édition ou d'une création et sauve les données en fonction.
    #
    def save
      user.admin? || raise('Cette opération vous est interdite, désolé.')
      data_valid? || return
      if id.nil?
        insert(data2save, true)
        __notice("Nouveau mot créé.")
      else
        update(data2save)
        __notice("Mot actualisé.")
      end
    end

    # Données à sauver, en les prenant dans le formulaire
    def data2save
      {
        mot:        dform[:mot],
        definition: dform[:definition],
        relatifs:   dform[:relatifs],
        synonymes:  dform[:synonymes],
        contraires: dform[:contraires],
        categories: dform[:categories],
        liens:      dform[:liens]
      }
    end

    # Données relevées dans le formulaire
    #
    # Certaines de ces données sont corrigées ici. Par exemple, tous les champs vides
    # sont mis à nil. Le mot est titleisé et les \r\n des liens et des définitions sont
    # remplacés par de simples \n
    def dform
      @dform ||= 
        begin
          h = param(:mot)
          h.each { |k,v| h[k] = v.nil_if_empty }
          h[:mot] && h[:mot] = h[:mot].titleize
          h[:definition] && h[:definition].gsub!(/\r\n/,"\n")
          h[:liens] && h[:liens].gsub!(/\r\n/,"\n")
          h
        end
    end

    ERRORS = {
      mot_required: "Le mot est requis.",
      mot_already_exists: "Ce mot existe déjà.",
      definition_required: "La définition du mot est absolument requise.",
      unknown_categorie:   "Une catégorie est inconnue. Ne les rentrez pas à la main.",
      href_lien_required:  "L'URL du lien est requise (format : url::titre).",
      titre_lien_required: "Le titre du lien est requis (format : url::titre).",
      lien_mal_formated:   "Un des liens est mal formaté (format : url::titre)."
    }
    # Return true si les données sont valides
    def data_valid?
      # === MOT (requis) ===
      dform[:mot] != nil || raise("mot_required")
      # Si c'est pour un nouveau mot, il faut s'assurer qu'il soit unique
      if id.nil? && site.db.count(:biblio,'scenodico',{mot: dform[:mot]}) > 0
        raise('mot_already_exists')
      end
      # === DÉFINITION (requise) ===
      dform[:definition] != nil || raise("definition_required")

      # === CATEGORIES ===
      # Note : étant donné qu'on ne peut mettre des identifiants qu'en choisissant
      # des mots, aucune erreur n'est possible à ce niveau.
      # En revanche, pour le moment, pour les catégories, il est possible de mettre 
      # n'importe quoi. On doit donc vérifier les catégories
      if dform[:categories]
        cates = dform[:categories].split(' ').uniq
        cates.each do |cate|
          if site.db.count(:biblio,'categories',{cate_id: cate}) != 1
            raise('unknown_categorie')
          end
        end
        dform[:categories] = cates.join(' ')
      end

      # === LIENS ===
      if dform[:liens]
        dform[:liens].split("\n").each do |lien|
          debug "Test du lien : '#{lien}'"
          if lien.match('::')
            href, titre = lien.split('::')
            href && href.strip != '' || raise('href_lien_required')
            titre && titre.strip != '' || raise('titre_lien_required')
            href.gsub(/[a-zA-Z\:\/\.\-_\?\[\]\#]/,'') == '' || raise('lien_mal_formated')
          else
            raise('lien_mal_formated')
          end
        end
      end
    rescue Exception => e
      debug e
      __error ERRORS[e.message.to_sym] # => false
    else
      return true
    end

    def base_n_table ; @base_n_table ||= [:biblio, 'scenodico'] end

  end #/Mot
end #/Scenodico

def mot
  @mot ||= Scenodico::Mot.new(site.route.objet_id)
end
