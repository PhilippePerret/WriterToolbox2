# encoding: UTF-8
require './lib/procedure/user/send_mail/module_mail_methods'
class MailSender
  include MailModuleMethods

  # Données transmises à l'instanciation
  attr_reader :data

  # Mail format (:html, :text, :both)
  attr_reader :format


  # Envoi du message
  # ----------------
  def send
    site.offline? && marshal_copy_of_mail
    (site.online? || @force_offline) && self.class.send(message, to, from)
  end

  def marshal_copy_of_mail
    now = Time.now.to_i

    # Trouver le nom du mail
    x = 0
    begin
      x += 1
      filename = "mail_#{now}-#{x}.msh"
      mail_path = File.join(marshal_mail_folder, filename)
    end while File.exist?(mail_path)

    # Assembler la donnée
    dmarshal = data.merge!(
      filename:   filename, # servira d'identifiant à l'instance
      subject:    subject,
      to:         to,
      from:       from,
      message:    message,
      sended_at:  now
    )
    # Enregistrer la donnée
    File.open(mail_path,'w'){|f| f.write(Marshal.dump(dmarshal))}
  end
  def marshal_mail_folder
    @marshal_mail_folder ||= begin
      d = './xtmp/mails'
      `mkdir -p "#{d}"`
      d
    end
  end
end
