# encoding: UTF-8
#
class User

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

    # Ici, on doit s'assurer que ce n'est pas un user inscrit
    # qui utilise simplement l'adresse pour créer son programme
    # sans payer.
    is_valid_request? || return

    # On crée l'enregistrement du paiement si nécessaire
    options[:paiement] && enregistre_paiement(options[:paiement])

    # On crée le programme pour l'auteur(e)
    program_id = UUProgram.create_program_for(self, options)

    # On crée le projet pour l'auteur(e)
    options.merge!(program_id: program_id)
    projet_id = UUProjet.create_projet_for(self, options)

    # On met le projet_id du programme
    prog = UUProgram.new(program_id)
    prog.set(projet_id: projet_id)

  end

  # Retourne true si c'est une vrai requête après le paiement
  # du programme, et pas seulement un rigolo qui "force" l'adresse
  # sans avoir rien payé.
  # Noter qu'on ne peut pas vérifier le paiement, puisque ce paiement
  # va justement être enregistré ici.
  def is_valid_request?

    return  site.session['uaus_signup'] &&
            site.session['uaus_signup'] == site.session.session_id &&
            user.get(:session_id) == site.session['uaus_signup']
  end

  # Enregistre le paiement de l'user si nécessaire.
  def enregistre_paiement montant
      site.db.insert(:cold, 'paiements', {
        objet_id: '1UN1SCRIPT', user_id: self.id,
        montant: montant
      })
  end
  def send_facture facture

  end
end
