# encoding: utf-8
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

      # Traiter le code du message avant son enregistrement
      #
      # La méthode est mise ici car elle doit servir aussi bien le module answer
      # que le module modify mais également à la création d'un sujet, puisqu'il
      # faut également créer un message.
      #
      # @usage      Forum::Post.traite_before_save(content)
      # 
      def traite_before_save contenu
        contenu.gsub!(/<.*?>/,'')     # toutes les balises <...>
        contenu.gsub!(/\r/,'')
        contenu.gsub!(/\n[  \t]+/,"\n")   # tous les lignes pas vraiment vides
        contenu.gsub!(/\n\n+/m,"\n\n") # Triples RC et plus

        # On remplace les double-retours chariot
        contenu = contenu.split("\n\n").collect{|p|"<p>#{p.strip}</p>"}.join('')
        # On finit par les RC simples (noter qu'il ne faut surtout pas le
        # faire avant les doubles RC, sinon tous les toucles RC seraient
        # remplacés...)
      contenu.gsub!(/\n/,'<br>')
      return contenu
    end
    

    end #/<< Post
  end #/Post
end #/Forum
