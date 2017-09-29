# encoding: utf-8
class Forum
  class << self

    # Retourne le div HTML des boutons pour la page Home
    #
    # Noter que ces boutons dépendent du grade de l'user
    # @param {Symbol} where
    #                 Soit :top, soit :bottom
    #
    def boutons where
      bs = String.new
      user.grade > 4 &&  bs << simple_link('forum/sujet/new', 'Nouveau sujet')
      bs << simple_link('forum/sujet/list', 'Liste des sujets')
      return "<div class=\"forum_boutons #{where}\">#{bs}</div>"
    end
  end #/<< self Forum
end #/Forum
