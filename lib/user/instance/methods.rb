# encoding: UTF-8
class User

  def login
    site.session['user_id'] = id
    site.session['date_last_connexion'] = Time.now.to_i
    self.class.current= self
    site.session['user_nombre_pages'] = 1
    set(session_id: site.session.session_id)
  end

  def send_mail data_mail
    identified? || raise("User non identifié. Impossible d’envoyer un mail.")
    require_folder './lib/procedure/user/send_mail'
    Mailer.send_mail_to_user(self, data_mail)
  end

end#/ User
