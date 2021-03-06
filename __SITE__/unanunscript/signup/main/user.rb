# encoding: UTF-8
#
class User

  # {Paiement} Le paiement pour le programme UAUS
  # Le mail de confirmation en a besoin pour construire la facture.
  attr_reader :last_paiement

  # Création du programme de l'user
  # -------------------------------
  # L'user vient de payer le programme, on lui crée son programme.
  # Attention : ici, "créer" son programme, c'est son programme UAUS en
  # général, pas spécialement son UUProgram qui est l'instance du
  # programme informatique qui gère son programme UAUS.
  #
  # @param {Hash} options
  #               options.paiement Si défini, c'est le montant
  #               à enregistrer dans la base. Une facture est alors
  #               aussi produite pour l'utilisateur.
  #
  def create_program options = nil
    options ||= Hash.new

    debug "-> User#create_program(options=#{options.inspect})"
    # Ici, on doit s'assurer que ce n'est pas un user inscrit
    # qui utilise simplement l'adresse pour créer son programme
    # sans payer.
    is_valid_request?(options) || begin
      debug "========= PROBLÈME =========="
      debug "Requête non valide => Abandon de la création du programme UN AN UN SCRIPT"
      debug "Pour info : site.session['uaus_signup'] = #{site.session['uaus_signup'].inspect}"
      debug "site.session.session_id = #{site.session.session_id.inspect}"
      debug "user.get(:session_id) = #{user.get(:session_id)}"
      debug "=============================="
      return false
    end

    # On crée le programme pour l'auteur(e)
    @program_id = Unan::UUProgram.create_program_for(self, options)

    # On crée le projet pour l'auteur(e)
    options.merge!(program_id: @program_id)
    @projet_id = Unan::UUProjet.create_projet_for(self, options)

    # On met le projet_id du programme
    prog = Unan::UUProgram.new(@program_id)
    prog.set(projet_id: @projet_id)

    # On crée l'enregistrement du paiement si nécessaire
    options[:paiement] && begin
      # Définition de l'objet du paiement, pour la facture
      hpaie = options[:paiement]
      hpaie.merge!(objet: "Programme UN AN UN SCRIPT ##{@program_id}")
      enregistre_paiement(hpaie)
    end

    return true
  end

  # Retourne true si c'est une vrai requête après le paiement
  # du programme, et pas seulement un rigolo qui "force" l'adresse
  # sans avoir rien payé.
  # Noter qu'on ne peut pas vérifier avec le paiement, puisque ce paiement
  # va justement être enregistré ici.
  def is_valid_request? options = nil
    if options && options[:paiement]
      opaie = options[:paiement]
      opaie[:state]  == 'approved' || raise('Le state du paiement devrait être "approved"')
      opaie[:status] == 'VERIFIED' || raise('Le status du paiement devrait être "VERIFIED"')
      opaie[:montant][:spec] == opaie[:montant][:total] || begin
        raise("Le montant n'est pas cohérent entre celui fixé et celui payé…")
      end
    end
    site.session['uaus_signup'] || raise('Un variable session devrait exister.')
    site.session['uaus_signup'] == site.session.session_id || begin
      raise('La variable session ne correspond pas.')
    end
    return user.get(:session_id) == site.session['uaus_signup']
  rescue Exception => e
    debug e
    false
  end

  # Enregistre le paiement de l'user si nécessaire.
  #
  # @param {Hash} paiement
  #               Les données du paiement, telles que renvoyées par PayPal
  #               Cf. le module `main.rb` au même niveau que ce fichier
  #               sont composées.
  def enregistre_paiement paiement
    debug "-> enregistre_paiement(#{paiement.inspect})"
    require './lib/utils/paiement'
    ipaiement = Paiement.new(paiement.merge(user_id: self.id, objet_id: '1AN1SCRIPT'))
    ipaiement.save
    @last_paiement = ipaiement # Pour le mail
  end
end
