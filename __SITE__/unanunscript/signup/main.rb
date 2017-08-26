# encoding: UTF-8
class Unan

  # Appelé quand on revient du paiement
  def self.on_paiement_ok
    # ========> CRÉATION DU PROGRAMME <=================
    dpaiement = {
      auteur: {
        prenom: param(:auteur_first_name),
        nom:    param(:auteur_last_name),
        mail:   param(:auteur_email)
      },
      id:               param(:id),
      cart:             param(:cart),
      state:            param(:state),    # doit être 'approved'
      status:           param(:status),   # doit être 'VERIFIED'
      montant:{
        id:       param(:montant_id),
        spec:     param(:montant).to_f, # le montant que j'ai fixé
        total:    param(:montant_total).to_f,
        monnaie:  param(:montant_currency)
      }
    }
    user.create_program(paiement: dpaiement)
    # ==================================================
  end

end
