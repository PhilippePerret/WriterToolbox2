# encoding: UTF-8
class MailSender

  # Les données SMTP pour l'envoi des mails
  require './__SITE__/_config/data/secret/data_mail.rb'

  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------

  class << self

    # Send the mail (don't call directly, use Mail.new(...) instead)
    def send mail, to, from
      connexion_smtp.send_message( mail, from, to )
    end

    def connexion_smtp
      @connexion ||= begin
        s = MY_SMTP
        Net::SMTP.start(s[:server], s[:port], 'localhost', s[:user], s[:password])
      end
    end

  end # /<< self

end #/MailSender
