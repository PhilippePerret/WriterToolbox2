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
      debug "-> send_mail_new_program_to_user"
      user.is_a?(User) || user = User.get(user)
      user.send_mail({
        subject: "Inscription au programme UN AN UN SCRIPT",
        message: deserb(File.join(thisfolder, 'mail', 'confirm_et_facture_user.erb')), 
        formated: true
      })
    end

    def send_mail_new_program_to_admin
      debug "-> send_mail_new_program_to_admin"
      site.admin.send_mail({
        subject: "Nouvelle inscription au programme UN AN UN SCRIPT",
        message: deserb(File.join(thisfolder, 'mail', 'annonce_admin.erb')), 
        formated: true
      })


    end

    def thisfolder
      @thisfolder ||= File.dirname(__FILE__)
    end
  end #/ << self

  class UUProgram
    class << self
      
      # Création d'un programme Unan pour l'user +user+
      #
      # @param {User} user
      #               Instance user de l'user pour lequel il faut
      #               construire le programme.
      # @param {Hash} options
      #               Eventuellement, les options à prendre en compte
      #               Par exemple l'identifiant du projet, s'il existe
      #               déjà.
      #
      # @return {Fixnum} program_id
      #                  ID du nouveau programme créé.
      #
      def create_program_for user, options = nil
        options ||= Hash.new

        # Données du programme à créer
        data_program = {
          auteur_id:            user.id,
          projet_id:            nil,
          rythme:               5,
          current_pday:         1,
          current_pday_start:   Time.now.to_i,
          options:              '100000000000',
          points:               0,
          retards:              nil,
          pauses:               nil
        }
        return insert(data_program)
      end

    end #/<< self (UUProgram)
  end #/UUProgram


  class UUProjet
    class << self

    # Crée un nouveau projet pour l'utilisateur +user+
    #
    # @param {User} user
    #               Instance User de l'utilisateur pour lequel
    #               créer le nouveau projet.
    # @param {Hash} options
    #               Eventuellement, les options pour cette création.
    #               Par exemple :program_id pour l'identifiant du
    #               programme associé à ce projet.
    #
    def create_projet_for user, options = nil
      options ||= Hash.new

      data_projet = {
        auteur_id:  user.id,
        program_id: options[:program_id],
        titre:      nil,
        resume:     nil,
        specs:      '10000000'
      }

      return insert(data_projet)

    end
    end #/<< self (UUProjet)
  end #/UUProjet
end #/ Unan
