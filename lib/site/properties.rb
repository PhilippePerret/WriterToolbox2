# encoding: UTF-8
class Site

  # @return {User} admin
  #         L'administrateur officiel du site
  def admin
    @admin ||= User.get(1)
  end

  # @return {String} url
  #         L'URL courante, en fonction du fait qu'on est en offline
  #         ou en online.
  def url
    configuration.send("url_#{offline? ? 'offline' : 'online'}")
  end

  # Juste pour la table des variables qui sont propres au site
  def id ; 0 end


end #/Site
