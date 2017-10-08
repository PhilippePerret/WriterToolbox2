# encoding: utf-8
class Forum
  class Post
    class << self

      # Met en forme le :content du message +hpost+ et le retourne
      # @param {Hash} hpost
      #               Doit contenir :
      #                 :content      Le contenu du message
      #                 :id           l'identifiant du message
      def mise_en_forme_post_content hpost
        c = hpost[:content]
        if c.match(/\[USER#/)
          # <= Il y a des citations dans le message, on les met en forme
          # => On doit les mettre en forme
          c.gsub!(/\[USER#(.*?)\](.*?)\[\/USER#\1\]/m){
            <<-HTML
              <div class="post_citation">
                <div class="auteur-citation">#{$1} a dit :</div>
                <p>#{$2}</p>
              </div>
            HTML
          }
        end
        # Pour les styles de base
        c.gsub!(/\[(i|b|u|del|ins|center|strong)\](.*?)\[\/\1\]/, '<\1>\2</\1>')
        # Pour les liens
        # Les liens vers les pages du site lui-même, de la forme :
        # [BOA=route/to/page]titre du lien[/BOA]
        c.gsub!(/\[BOA=(.*?)\](.*?)\[\/BOA\]/,'<a href="\1">\2</a>')
        return c
      end
    end #/<< self
  end #/Post
end #/Forum
