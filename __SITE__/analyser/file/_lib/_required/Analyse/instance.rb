# encoding: utf-8
class Analyse

  # Retourne un lien (pour mail) conduisant au tableau de
  # bord de l'analyse.
  def as_full_link
    @as_link ||= full_link("analyser/dashboard/#{id}", "Analyse de “#{film.titre}”")
  end

end
