# encoding: utf-8
#
# Méthodes d'instance de Forum::Post
#
class Forum
  class Post

    attr_reader :id


    # Instanciation  à l'aide de son ID.
    # Note : le message #post_id n'a pas forcément besoin d'exister
    def initialize post_id
      @id = post_id
    end


    def sujet_id ; @sujet_id ||= which_data[:sujet_id] end
    def user_id  ; @user_id  ||= which_data[:user_id]  end
    alias :auteur_id :user_id

    #-------------------------------------------------------------------------------- 
    #
    #   Méthodes pratiques
    #
    #-------------------------------------------------------------------------------- 

    # {User} Auteur du message
    def auteur ; @auteur ||= ::User.get(user_id) end
    def sujet  ; @sujet  ||= Forum::Sujet.get(sujet_id) end

    # Retourne la route au message
    # Attention, ça renvoie une route qui n'affiche QUE le message, par exemple
    # pour qu'un administrateur le valide ou le modifie. Pour une route dans le
    # sujet, utiliser la méthode `route_in_sujet`
    def route full = nil
      @route ||= "forum/post/#{self.id}"
      as_route_full(@route, full)
    end


    # Route dans le sujet. En fait, plutôt que de calculer où se trouverait
    # le message dans le sujet (quel panneau), ce qui dépendrait du nombre de messages
    # affiché par panneau, on demande simplement la liste du sujet en fournissant
    # l'identifiant du post. En retour, la liste va afficher un panneau contenant
    # ce post et des boutons pour remonter ou descendre.
    # @param {Symbol} full
    #                 Si :full, true ou :online,  on met l'adresse complète, online
    #                 Si :offline, adresse complète offline
    #
    def route_in_sujet full = nil
      @route_in_sujet ||= "forum/sujet/#{sujet_id}?pid=#{id}"
      as_route_full(@route_in_sujet, full)
    end

    # Pour ajouter la base de l'url si nécessaire
    def as_route_full r, full
      case full
      when true, :full, :online then "http://#{site.configuration.url_online}/#{r}"
      when :offline then "http://#{site.configuration.url_offline}/#{r}"
      else r
      end
    end

    # Les données utilisées, soit complètes soit mini
    # Le mieux, avant d'appeler un message, est de déterminer quelles données 
    # devront être chargées, soit mini soit entière, en appelant :
    #     `post.data_mini` ou `post.data`
    # Ensuite, il suffit d'utiliser `which_data` pour récupérer la donnée.
    # Noter que ça vaut pour les données générales du post, car pour les données
    # particulières telles que le :content ou le :vote, il faut obligatoirement
    # passer par @data.
    def which_data
      @data_mini || @data || data_mini
    end

    # Les données mini du message
    def data_mini
      @data_mini ||= site.db.select(:forum,'posts',{id: id}).first
    end

    # Les données complètes du message
    def data
      @data ||=
        begin
          request = <<-SQL
          SELECT p.*, p.user_id AS auteur_id
          , u.pseudo AS auteur_pseudo
          , c.content, c.created_at AS content_created_at, c.updated_at AS content_updated_at
          , c.modified_by AS content_modified_by
          , v.vote, v.upvotes, v.downvotes
          FROM posts p
          INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
          INNER JOIN posts_content c ON p.id = c.id
          INNER JOIN posts_votes v ON p.id = v.id
          WHERE p.id = #{self.id}
          LIMIT 1
          SQL
          site.db.use_database(:forum)
          site.db.execute(request).first
        end
    end
  end #/Post
end #/Forum
