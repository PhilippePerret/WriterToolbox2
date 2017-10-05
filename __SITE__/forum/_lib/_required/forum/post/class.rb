# encoding: utf-8
# debug "-> #{__FILE__}"
class Forum
  class Post
    class << self

      # Retourne l'instance {Forum::Post} du message d'identifiant
      # +post_id+ sans refaire l'instance si elle existe déjà
      def get post_id
        @posts ||= Hash.new
        @posts[post_id] ||= new(post_id)
        return @posts[post_id]
      end


    end #/<< Post
  end #/Post
end #/Forum
