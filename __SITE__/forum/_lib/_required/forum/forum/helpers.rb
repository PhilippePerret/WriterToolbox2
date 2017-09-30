# encoding: utf-8
class Forum
  class << self

    # Retourne le div HTML des boutons pour la page Home
    #
    # On peut ajouter d'autres boutons simplement en utilisant
    # la méthode Forum.add_boutons_forum <code html boutons>
    #
    # Noter que ces boutons dépendent du grade de l'user
    # @param {Symbol} where
    #                 Soit :top, soit :bottom
    #
    def boutons where
      bs = String.new
      user.grade > 4 &&  bs << simple_link('forum/sujet/new', 'Nouveau sujet')
      bs << simple_link('forum/sujet/list', 'Liste des sujets')
      if @__boutons
        bs << @__boutons
      end
      return "<div class=\"forum_boutons #{where}\">#{bs}</div>"
    end


    # Pour ajouter des boutons au div des boutons
    def add_boutons_forum code_boutons
      @__boutons ||= String.new
      @__boutons << code_boutons
    end
  end #/<< self Forum
end #/Forum
