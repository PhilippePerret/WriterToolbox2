# encoding: utf-8
=begin

   Classe Forum::Sujet

=end
class Forum
  class Sujet

    attr_reader :id

    def initialize sid
      @id = sid
    end

    def route full = false, fin = false
      uri = "forum/sujet/#{self.id}"
      full === true && full = :online
      full == :online && uri = "http://#{site.configuration.url_online}/#{uri}"
      uri << "?from=#{fin ? '-1' : '1'}"
    end

    # Retourne un Hash des données du sujet courant, celui
    # dont on doit afficher la liste des messages
    def data
      @data ||=
        begin
          req = 'SELECT s.*, u.pseudo AS creator_pseudo FROM sujets s'+
                ' INNER JOIN `boite-a-outils_hot`.users u   ON s.creator_id = u.id'+
                " WHERE s.id = #{id}"
          site.db.use_database(:forum)
          site.db.execute(req).first
        end
    end
  end #/Sujet
end #/Forum
