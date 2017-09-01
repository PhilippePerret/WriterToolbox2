# encoding: utf-8

class User
  class << self

    attr_reader :last_paiement

    # Méthode appelée lorsque le paiement est correct
    def on_paiement_ok options = nil
      options ||= Hash.new

      if false == is_valid_request? 
        debug "========== PROBLÈME AVEC LA VALIDATION DE LA REQUÊTE D'ABONNEMENT ============"
        raise "Impossible de vous abonner."
      end

      enregistre_paiement

      envoyer_mail_confirmation_to_user

      envoyer_mail_information_to_admin

    end

    # Enregistrer le paiement de l'abonnement
    def enregistre_paiement
      require './lib/utils/paiement'
      ipaiement = Paiement.new(data_paiement.merge(user_id: user.id, objet_id: 'ABONNEMENT'))
      ipaiement.save
      @last_paiement = ipaiement # Pour le mail
    end

    # Envoyer le mail au nouvel abonné
    def envoyer_mail_confirmation_to_user
      
    end

    # Envoyer le mail à l'administration
    def envoyer_mail_information_to_admin
      
    end

    # Récupérer les données du paiement transmis par l'url
    def data_paiement
      @data_paiement ||=
        begin
          {
            auteur: {
              prenom: param(:auteur_first_name),
              nom:    param(:auteur_last_name),
              mail:   param(:auteur_email)
            },
            id:               param(:id),
            cart:             param(:cart),
            state:            param(:state),    # doit être 'approved'
            status:           param(:status),   # doit être 'VERIFIED'
            montant: {
              id:       param(:montant_id),
              spec:     param(:montant).to_f, # le montant que j'ai fixé
              total:    param(:montant_total).to_f,
              monnaie:  param(:montant_currency)
            }
          }
        end
    end


    # Retourne true si c'est une vrai requête après le paiement
    # du programme, et pas seulement un rigolo qui "force" l'adresse
    # sans avoir rien payé.
    # Noter qu'on ne peut pas vérifier avec le paiement, puisque ce paiement
    # va justement être enregistré ici.
    def is_valid_request? 
      opaie = data_paiement
      opaie[:state]  == 'approved' || raise('Le state du paiement devrait être "approved"')
      opaie[:status] == 'VERIFIED' || raise('Le status du paiement devrait être "VERIFIED"')
      if opaie[:montant][:spec] != opaie[:montant][:total] 
        raise("Le montant n'est pas cohérent entre celui fixé et celui payé…")
      end
      site.session['user_suscribing'] || raise('Un variable session devrait exister.')
      if site.session['user_suscribing'] != site.session.session_id  
        raise('La variable session ne correspond pas.')
      end
      return user.get(:session_id) == site.session['user_suscribing']
    rescue Exception => e
      debug e
      false
    end

  end #<< self
end #/User
