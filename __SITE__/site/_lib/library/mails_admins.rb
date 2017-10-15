# encoding: UTF-8
=begin

  @usage
      require_lib 'site:mails_admins'
      mail_to_admins(data_mail[, options])

=end

class Site
  # Pour faire une annonce à tous les administrateurs du site, par
  # exemple pour valider un message
  #
  # @param {Hash} data_mail
  #               Les données du mail, avec notamment :subject et :message
  #               :message sera considéré comme un template déserbé avec l'administrateur
  #               bindant. Cela permet notamment de régler le pseudo des administrateurs ou
  #               le féminin/masculin, grâce à des codes comme "Cher administrat<%=f_rice%>"
  # @param {Hash} options
  #               Pour définir d'autres choses, comme par exemple le fait qu'on
  #               doive également contacter les administrateurs du forum
  #               :forum        Si true, il faut contacter aussi les user du
  #                             forum qui ont un grade d'administrateur.
  #
  def mail_to_admins data_mail, options = nil
    require_folder './lib/procedure/user/send_mail'
    data_mail.key?(:from) || data_mail.merge!(from: site.configuration.mail)
    message_template = data_mail.delete(:message)
    data_mail[:message] = nil

    where_clause = "(CAST(SUBSTRING(options,1,1) AS UNSIGNED) & 1)"
    if options && options[:forum]
      where_clause << " OR CAST(SUBSTRING(options,2,1) AS UNSIGNED) > 6"
    end
    site.db.select(:hot,'users',where_clause,[:id, :pseudo, :mail])
      .each do |hadmin|
      #debug "Administrateur contacté : #{hadmin.inspect}"
      admin = User.get(hadmin[:id])
      data_mail.merge!(message: ERB.new(message_template).result(admin.bind))
      Mailer.send_mail_to_user(admin, data_mail)
    end
  end

end
