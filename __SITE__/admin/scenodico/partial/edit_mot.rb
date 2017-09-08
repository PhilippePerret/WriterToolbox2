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
    def save
     __error("La sauvegarde du mot n'est pas encore implémenté.") 
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
    def dform
      @dform ||= 
        begin
          h = param(:mot)
          h.each { |k,v| h[k] = v.nil_if_empty }
          h[:liens] && h[:liens] = h[:liens].join("\n")
          h
        end
    end

    ERRORS = {
      mot_required: "Le mot est requis.",
      definition_required: "Le définition du mot est absolument requise."
    }
    # Return true si les données sont valides
    def data_valid?
      dform[:mot] != nil || raise(:mot_required)
      dform[:definition] != nil || raise(:definition_required)
      # Note : étant donné qu'on ne peut mettre des identifiants qu'en choisissant
      # des mots, aucune erreur n'est possible à ce niveau.
    rescue Exception => e
      __error ERRORS[e.message.to_sym]
    else
      return true
    end

    def base_n_table ; @base_n_table ||= [:biblio, 'scenodico'] end

  end #/Mot
end #/Scenodico

def mot
  @mot ||= Scenodico::Mot.new(site.route.objet_id || 1)
end
