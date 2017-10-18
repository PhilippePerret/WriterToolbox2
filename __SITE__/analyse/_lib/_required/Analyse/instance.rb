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

  # Spécifications de l'analyse
  def specs
    @specs ||=
      begin
        if @complete_data
          @complete_data[:specs]
        else
          data[:specs]
        end
      end
  end

  # Instance {Analyse::Film} du film de l'analyse
  def film
    @film ||= Analyse::Film.new(id)
  end

  # Instance {User} du créateur de l'analyse
  def creator
    @creator ||= User.get(creator_id)
  end

  # Data minimum de l'analyse
  def data
    @data ||=
      begin
        site.db.select(:biblio,'films_analyses',{id: id})[0]
      end
  end

  # ID de l'user créateur de l'analyse.
  def creator_id
    @creator_id ||=
      begin
        if @complete_data
          @complete_data[:contributors][0][:id]
        else
          site.db.select(
            :biblio,'user_per_analyse',
            "film_id = #{id} AND role & 32 LIMIT 1",
            [:user_id]
          )[0][:user_id]
        end
      end
  end
end
