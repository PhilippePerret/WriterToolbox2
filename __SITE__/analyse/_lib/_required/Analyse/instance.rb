# encoding: utf-8
class Analyse

  attr_reader :id

  # Instanciation d'une nouvelle analyse
  #
  # Noter qu'une `analyse` ressemble à un film, mais que ça n'est
  # pas tout à fait la même chose. Par exemple, l'analyse à un `creator` (celui
  # qui a créé l'analyse), elle a des contributors (ceux qui contribue à cette
  # analyse), tout ce que n'a pas le film, qui ne contient que les informations
  # sur le film.
  #
  # En revanche, analyse et film partagent absolument le même ID.
  #
  def initialize film_id
    @id = film_id
  end

end
