# encoding: utf-8
class Analyse
  class << self


    # Pour simplifier l'affichage du titre principal.
    def main_title options = nil
      site.titre_page(simple_link("analyser", 'Contribuer')+' aux '+simple_link('analyse/home',"analyses de films"))
    end

    # Retourne TRUE si l'user +user_id+ contribue à l'analyse
    # du film d'ID +film_id+, et FALSE dans le cas contraire.
    #
    # @param {Hash|Fixnum} adata
    #                      Soit les données complète de l'analyse
    #                      Soit l'ID de l'analyse
    #                      Soit les données incomplètes (sans :contributors), mais
    #                      avec l'ID du film (i.e. de l'analyse)
    def has_contributor?(adata, user_id)
      if adata.is_a?(Hash) && adata[:contributors]
        if adata.key?(:contributors)
          adata[:contributors].each do |hcont|
            hcont[:id] == user_id && (return true)
          end
          return false
        else
          film_id = adata[:id]
        end
      else
        film_id = adata
      end
      return site.db.count(
        :biblio,
        'user_per_analyse',
        {film_id: film_id, user_id: user_id}
      ) > 0
    end
  end #/<<self
end #/Analyse

