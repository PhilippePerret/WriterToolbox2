# encoding: utf-8
debug "-> #{__FILE__}"
class Forum
  class Sujet
    class << self

    # Retourne true si l'user +user+ suit le sujet +sujet_id+
    def user_suit_sujet? user, sujet_id
      site.db.count(:forum,'follows',{user_id: user.id, sujet_id: sujet_id}) == 1
    end

    end #/<< self
  end #/Sujet

  class Post
    class << self

      # Ajoute le message d'identifiant +post_id+ à l'user +user+
      #
      # La méthode vérifie que le message appartienne bien à l'auteur
      # spécifié.
      #
      # @param {User|Fixnum}  user
      #                       L'auteur du message ou son ID
      # @param {Fixnum}       post_id
      #                       ID du message.
      def add_post_to_user user, post_id
        user_id = user.is_a?(User) ? user.id : user
        user_id.is_a?(Fixnum) || raise(ArgumentError.new('Il faut spécifié l’user du post.'))
        post_id.is_a?(Fixnum) || raise(ArgumentError.new('Il faut spécifié l’ID (Fixnum) du message.'))
        hpost = site.db.select(:forum,'posts',{id: post_id},[:user_id]).first
        hpost != nil || raise(ArgumentError.new("L’ID #{post_id} ne correspond pas à un message existant."))
        if hpost[:user_id] == user_id
          huser = site.db.select(:forum,'users',{id: user_id}).first
          if huser.nil
            # <= C'est le tout premier message de l'auteur
            # => Il faut lui créer une donnée complète et l'insérer
            site.db.insert(
              :forum, 'users',
              {id: user_id, count: 1, last_post_id: post_id, options: '0'*8}
            )
          else
            # <= Ce n'est pas le premier message de l'auteur
            # => Il faut simplement imcrémenter ses messages
            site.db.update(
              :forum, 'users',
              {count: huser[:count] + 1, last_post_id: post_id},
              {id: user_id}
            )
          end
        else
          raise ArgumentError.new("Le message n’appartient pas à cet auteur.")
        end
      end
    end #/<< self Forum::Post

    attr_reader :id

    def initialize id
      @id = id
    end


    # Les données du message dans les tables
    def data
      @data ||=
        begin
          request = <<-SQL
          SELECT c.content, p.user_id AS auteur_post_id, u.pseudo AS auteur_post_pseudo
          FROM posts p
          INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
          INNER JOIN posts_content c ON p.id = c.id
          WHERE p.id = #{id}
          SQL
          site.db.use_database(:forum)
          site.db.execute(request).first
        end
    end

  end #/Post
end #/Forum

# Instance {Forum::Post} du message courant, précisé dans l'url
def post
  @post ||= Forum::Post.new(site.route.objet_id)
end
