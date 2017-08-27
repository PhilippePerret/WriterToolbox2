# encoding: UTF-8
class Unan
  class << self

    # Appelé quand on revient du paiement
    def on_paiement_ok
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

      if user.create_program(paiement: dpaiement)

        send_mail_new_program_to_user(user)
        send_mail_new_program_to_admin

      end
      # ==================================================
    end

    def send_mail_new_program_to_user user
      user.is_a?(User) || user = User.get(user)
      user.send_mail({
        subject: "Inscription au programme UN AN UN SCRIPT",
        message: deserb(File.join(thisfolder, 'mail', 'confirm_et_facture_user.erb')),
        formated: true
      })
    end

    def send_mail_new_program_to_admin
      site.admin.send_mail({
        subject: "Nouvelle inscription au programme UN AN UN SCRIPT",
        message: deserb(File.join(thisfolder, 'mail', 'annonce_admin.erb')),
        formated: true
      })
    end

    def thisfolder
      @thisfolder ||= File.dirname(File.dirname(__FILE__))
    end
  end #/ << self
end #/ Unan
