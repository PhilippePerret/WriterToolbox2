# encoding: utf-8
class Narration
  class << self

    # Définit le titre (avec les menus généraux) pour toutes les pages.
    # C'est impérativement la méthode qu'il faut utiliser.
    #
    # @param {Hash} options
    #               Permet de définir les options.
    #               À l'avenir permettra par exemple de précisier mieux
    #               le titre à donner à la page, pour l'historique notamment.
    def main_titre options = nil

      site.titre_page(
        simple_link('narration',"La collection Narration"),
        {
          subtitle: (options && options[:subtitle]),
          under_buttons: under_buttons      
        }
      )
    end

    def under_buttons
      ub = [
        simple_link('narration/livre', 'livres'),
        simple_link('narration/state', 'développement')
      ]

      user.admin? && ub << simple_link('admin/narration', 'administrer')

      return ub
    end
  end #/<< self
end #/Narration
