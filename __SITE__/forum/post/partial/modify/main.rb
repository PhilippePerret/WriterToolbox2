# encoding: utf-8
class Forum
  class Post

    def destroyed?
      @is_destroyed === nil && @is_destroyed = data[:options][1] == '1'
      @is_destroyed
    end

    # Retourne la version d'affichage du message lorsqu'il est détruit
    #
    def show_when_destroyed
      <<-HTML
      <div class="red cadre">Ce message a été détruit, il ne peut pas être modifié.</div>
      <section>#{data[:content]}</section>
      HTML
    end
  end #/Post
end #/Forum
