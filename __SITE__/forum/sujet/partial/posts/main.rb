# encoding: utf-8

class Forum
  class Sujets

    attr_reader :id

    def initialize sid
      @id = sid
    end

    # --------------------------------------------------------------------------------
    #
    #  Méthodes d'helper
    #
    # --------------------------------------------------------------------------------

    # Données du sujet (HTML)
    def encart_data
      <<-HTML
      <span class="titre">#{data[:titre]}</span>
      HTML
    end

    # Retourne le code HTML de la liste des messages du sujet
    def post_list from = 0, nombre = 20, options = nil
      from   = from.to_i
      nombre = nombre.to_i
      '[Liste des messages de ce sujet]'
    end

    # --------------------------------------------------------------------------------
    #
    #  @private (pas vraiment, mais bon...)
    #
    # --------------------------------------------------------------------------------

    def data
      @data ||=
        begin
          req = String.new
          req << "SELECT s.*, u.pseudo AS creator_pseudo"
          req << ' FROM sujets s'
          req << ' INNER JOIN `boite-a-outils_hot`.users u'
          req << '   ON s.creator_id = u.id'
          req << " WHERE s.id = #{id}"
          site.db.use_database(:forum)
          site.db.execute(req).first
        end
    end

  end #/Sujets
end #/Forum



def sujet
  @sujet ||= Forum::Sujets.new(site.route.objet_id)
end
