# encoding: UTF-8
=begin

  Module principal pour l'envoi d'un mail à un utilisateur ou l'administration.

=end
class Mailer
class << self

  # Méthode principale qui envoie le mail +data_mail+ à +user+
  #
  def send_mail_to_user user, data_mail
    data_mail[:from] || data_mail.merge!(from: site.configuration.main_mail)
    data_mail.merge!(to: user.mail)
    MailSender.new(data_mail).send
  end

end #/<< self
end #/ Mailer
