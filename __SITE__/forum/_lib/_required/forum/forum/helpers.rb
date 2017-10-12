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
      
      # Les boutons qu'on va trouver sur toutes les pages

      bs << simple_link('forum/sujet/list', 'Liste des sujets')
      case
      when user.grade > 4
        bs << simple_link('forum/sujet/new', 'Nouveau sujet/nouvelle question')
      else
        # Noter qu'on met toujours ce bouton, mais si l'auteur n'est pas identifié/inscrit
        # on lui proposera de s'inscrire pour pouvoir poser sa question.
        bs << simple_link('forum/sujet/new', "Nouvelle question", 'exergue')
      end

      # Les boutons qui peuvent être ajoutés ponctuellement
      # Par convention, ils se trouvent toujours à droite des autres

      @__boutons && bs << @__boutons
      return "<div class=\"forum_boutons #{where}\">#{bs}</div>"
    end


    # Pour ajouter des boutons au div des boutons
    def add_boutons_forum code_boutons
      @__boutons ||= String.new
      @__boutons << code_boutons
    end
  end #/<< self Forum
end #/Forum
