# encoding: UTF-8

class User

  def signup
    # debug "-> User#signup"

    # On vérifie que les données soient valides
    data_valide? || return

    # On enregistre les données dans la base
    save_data_user( param(:user) ) || return

    # Identification de l'user
    # ------------------------
    # Noter qu'il faut le faire avant l'envoi des messages, car les mails
    # s'en servent pour construire les messages.
    self.login

    # Envoi des mails
    # ---------------
    send_mail_confirmation_inscription
    send_mail_pour_confirmation_mail
    send_mail_information_administration

    if site.session['uaus_signup'] && site.session['uaus_signup'] == site.session.session_id
      # Inscription pour le programme UN AN UN SCRIPT
      # ---------------------------------------------
      # Si c'est une inscription pour le programme UN AN UN SCRIPT d'un
      # visiteur qui n'était pas encore inscrit, on le redirige vers le
      # formulaire qui va lui permettre de payer le programme pour
      # finaliser son inscription
      mess = "Inscription au site réussie.<br><span class='red'>N'oubliez pas de confirmer votre mail.</span>"
      redirect_to "unanunscript/signup", mess
    elsif site.session['user_suscribing']
      # Abonnement au site
      # ------------------
      mess = "Inscription au site réussie.<br><span class='red'>N'oubliez pas de confirmer votre mail.</span>"
      redirect_to "user/suscribe", mess
    end

  end

  def send_mail_confirmation_inscription
    mess = deserb("#{thisfolder}/mail/confirm_inscription.erb")
    send_mail(
      subject:    "Confirmation de votre inscription",
      message:    mess,
      formated:   true
    )
  end
  def send_mail_pour_confirmation_mail
    send_mail(
      subject:    "Confirmez votre adresse mail",
      message:    deserb("#{thisfolder}/mail/confirm_mail.erb"),
      formated:   true
    )
  end
  def send_mail_information_administration
    site.admin.send_mail(
      short_subject:  "Nouvelle inscription",
      message:        deserb("#{thisfolder}/mail/annonce_administration.erb")
    )
  end

  def thisfolder
    @thisfolder ||= File.dirname(__FILE__)
  end

  # Crée la donnée de l'user dans la base de données
  #
  # @param {Hash} duser
  #               Données de l'user dans le formulaire
  # @return {TrueClass|FalseClass}
  #         True en cas de succès de création, false dans le cas contraire.
  #
  def save_data_user duser

    duser.merge!(
      options:    default_options,
      salt:       random_salt,
      cpassword:  nil,
      updated_at: Time.now.to_i
    )
    duser[:cpassword] =
      crypte_password_with(
        duser[:password],
        duser[:mail],
        duser[:salt]
      )

    # On boucle sur les propriétés qu'il faut enregistrer dans la
    # base de données et seulement ces propriétés-là.
    user_db_data = Hash.new()
    [
      :pseudo, :patronyme, :mail, :sexe, :options,
      :salt, :cpassword,
      :updated_at
    ].each do |prop|
      user_db_data.merge!(prop => duser[prop])
    end

    # On insert la donnée dans la base de données
    site.db.insert(:hot, 'users', user_db_data)

    @id = site.db.last_id_of(:hot,'users')

    # debug "ID du nouvel user : #{id}"

  rescue Exception => e
    __error e
  else
    true
  end

  # Retourne le mot de passe crypté correspondant à +password+, le
  # mot de passe de l'user inscrit, son mail +mail+ et un sel +salt+
  # déterminé au hasard.
  def crypte_password_with(password, mail, salt)
    require 'digest/md5'
    Digest::MD5.hexdigest("#{password}#{mail}#{salt}")
  end

  # Retourne un nouveau sel pour le mot de passe crypté
  # C'est un mot de 10 lettres minuscules choisies au hasard
  def random_salt
    10.times.collect{ |itime| (rand(26) + 97).chr }.join('')
  end

  # Les options par défaut
  def default_options
    '0000000000' # pour le moment
  end


  def data_valide?
    data_user = param(:user)

    # Validité du PSEUDO
    pseudo = data_user[:pseudo].nil_if_empty
    begin
      pseudo != nil      || raise( "Il faut fournir votre pseudo." )
      pseudo.length < 40 || raise("Ce pseudo est trop long. Il doit faire moins de 40 caractères.")
      pseudo.length >= 3 || raise("Ce pseudo est trop court. Il doit faire au moins 3 caractères.")
      reste = pseudo.gsub(/[a-zA-Z0-9_\-]/,'')
      reste == "" || raise("Ce pseudo est invalide. Il ne doit comporter que des lettres, chiffres, traits plats et tirets. Il comporte les caractères interdits : #{reste.split.pretty_join}")
    rescue Exception => e
      data_user[:pseudo] = ''
      raise e
    end

    # Validité du PATRONYME
    patronyme = data_user[:patronyme].nil_if_empty
    begin
      patronyme != nil       || raise("Il faut fournir votre patronyme.")
      patronyme.length < 256 || raise("Ce patronyme est trop long. Il ne doit pas faire plus de 255 caractères.")
      patronyme.length > 3   || raise("Ce patronyme est trop court. Il ne doit pas faire moins de 4 caractères.")
    rescue Exception => e
      data_user[:patronyme] = ''
      raise e
    end

    # Validité du MAIL
    begin
      @mail = data_user[:mail].nil_if_empty
      @mail != nil        || raise("Il faut fournir votre mail.")
      @mail.length < 256  || raise("Ce mail est trop long.")
      format_correct_de_mail?(@mail) || raise("Ce mail n’a pas un format valide.")
    rescue Exception => e
      data_user[:mail] = ''
      data_user[:mail_confirmation] = ''
      raise e
    else
      @mail == data_user[:mail_confirmation] || raise("La confirmation du mail ne correspond pas.")
    end

    # Ni le mail, ni le pseudo, ni le patronyme ne doivent exister
    # Note : c'est dans la méthode de vérification qu'on raise si nécessaire
    data_similaires_in_db?(pseudo, @mail, patronyme)

    # Validité du MOT DE PASSE
    @password = data_user[:password].nil_if_empty
    begin
      @password != nil      || raise("Il faut fournir un mot de passe pour protéger vos données.")
      @password.length < 41 || raise("Ce mot de passe est trop long. Il ne doit pas excéder les 40 caractères.")
      @password.length > 7  || raise("Ce mot de passe est trop court. Il doit faire au moins 8 caractères.")
    rescue Exception => e
      data_user[:password] = ''
      data_user[:password_confirmation] = ''
      raise e
    else
      @password == data_user[:password_confirmation] || raise("La confirmation du mot de passe ne correspond pas.")
    end

    # On variabilise les choses non testées
    @sexe = data_user[:sexe].nil_if_empty
    raise "Le sexe devrait être défini." if @sexe.nil?
    raise "Le sexe n'a pas la bonne valeur." unless ['F', 'H'].include?(@sexe)

    captcha = data_user[:captcha].nil_if_empty
    raise "Il faut fournir le captcha pour nous assurer que vous n'êtes pas un robot." if captcha.nil?
    raise "Le captcha est mauvais, seriez-vous un robot ?" if captcha.to_i != 366

    # On envoie ces données à l'instance user pour
    # les dispatcher dans l'instance.
    # Remarquer cependant que tant que @id n'est pas défini pour l'user,
    # c'est comme s'il n'était pas identifié.
    user.dispatch data_user

  rescue Exception => e
    debug e
    __error e.message
  else
    true
  ensure
    param(:user, data_user)
  end

  # @return TrueClass
  #         Si le mail +mail+ est d'un format correct.
  def format_correct_de_mail? mail
    return mail.gsub(/^[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}$/,'') == ""
  end

  def data_similaires_in_db? pseudo, mail, patronyme
    site.db.use_database(:hot)
    res = site.db.execute('SELECT id, pseudo, mail, patronyme FROM users WHERE pseudo = ? OR mail = ? OR patronyme = ?', [pseudo, mail, patronyme])
    res.empty? && return # OK
    ms = [] # Pour mettre les messages d'erreur
    res.each do |hdata|
      hdata[:pseudo]    == pseudo     && ms << "Ce pseudo existe déjà."
      hdata[:mail]      == mail       && ms << "Ce mail existe déjà."
      hdata[:patronyme] == patronyme  && ms << "Ce patronyme existe déjà."
    end
    # debug "Retour DB : #{res.inspect}"
    __error(ms)
    raise "Votre inscription ne peut être enregistrée."
  end

end #/User
