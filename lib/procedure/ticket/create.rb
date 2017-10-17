# encoding: UTF-8
class Ticket
  class << self

    attr_accessor :id   # ID du ticket créé
    attr_accessor :url  # URL du ticket créé
    attr_accessor :link # Lien pour jouer le ticket créé

    def create tdata
      tdata.is_a?(Hash) ||
        raise(ArgumentError.new("Le premier argument doit être un Hash des données !"))
      ( tdata.key?(:code) && tdata[:code].is_a?(String) ) ||
        raise(ArgumentError.new("Il faut définir le code du ticket !"))
      a_title = tdata.delete(:a_title) || 'Jouer ce ticket'
      a_class = tdata.delete(:a_class)
      require 'securerandom'
      self.id = SecureRandom.hex
      tdata.merge!(id: self.id)
      tdata[:user_id] ||= user.id
      site.db.insert(:hot,'tickets',tdata)
      # Les éléments utiles
      self.url  = "http://#{site.configuration.url_online}?tckid=#{self.id}"
      self.link = simple_link(self.url, a_title, a_class)
    end


  end #/<< self

end #/Ticket
