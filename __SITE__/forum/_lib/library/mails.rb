# encoding: utf-8
=begin
  Librairie pour les mails (à commencer par l'envoi de
  messages aux administrateurs, lors de validations requises)

  @usage :

        require_lib 'forum:mails'
=end
class Forum
  class << self

    # Pour faire une annonce à tous les administrateurs du site, par
    # exemple pour valider un message
    #
    # @param {Hash} data_mail
    #               Les données du mail, avec notamment :subject et :message
    #               :message sera considéré comme un template déserbé avec l'administrateur
    #               bindant. Cela permet notamment de régler le pseudo des administrateurs ou
    #               le féminin/masculin, grâce à des codes comme "Cher administrat<%=f_rice%>"
    def message_to_admins data_mail
      require_folder './lib/procedure/user/send_mail'
      data_mail.key?(:from) || data_mail.merge!(from: site.configuration.mail)
      message_template = data_mail.delete(:message)
      data_mail[:message] = nil
      site.db.select(
        :hot,'users',
        "(CAST(SUBSTRING(options,1,1) AS UNSIGNED) & 1) OR CAST(SUBSTRING(options,2,1) AS UNSIGNED) > 6",
        [:id, :pseudo, :mail]
      ).each do |hadmin|
        #debug "Administrateur contacté : #{hadmin.inspect}"
        admin = User.get(hadmin[:id])
        data_mail.merge!(message: ERB.new(message_template).result(admin.bind))
        Mailer.send_mail_to_user(admin, data_mail)
      end
    end


  end #/self Forum
end #/Forum

