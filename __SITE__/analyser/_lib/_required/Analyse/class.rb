# encoding: utf-8
class Analyse
  class << self


    # Pour simplifier l'affichage du titre principal.
    def main_title options = nil
      titre_et_title = site.titre_page(<<-HTML)
      #{simple_link('analyser','Contribuer')}
      aux
      #{simple_link('analyse/home','analyses de films')}
      <span class="tiny">[#{simple_link('aide?p=analyse%2Fcontribuer','→ aide','exergue')}]</span>
      HTML
    end

    # Pour éjecter (plutôt violemment un user).
    # Méthode mise ici car nécessaire souvent pour faire barrière
    #
    # @param {String} mess
    #                 Le message pour préciser la raison (ou nil)
    # @param {Bool}   redirige
    #                 Si TRUE (défaut), l'user est redirigé vers l'accueil.
    #                 Sinon, on affiche simplement l'erreur, c'est une éjection plus
    #                 douce de l'opération courante.
    def eject_user mess = nil, redirige = true
      mess = "Vous n’êtes pas en mesure d’accomplir cette opération#{mess.nil? ? '' : ' : '+mess}…"
      if redirige
        redirect_to('home', [mess, :error])
      else
        return __error(mess)
      end
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

