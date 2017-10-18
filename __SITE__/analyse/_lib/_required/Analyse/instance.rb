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

  # retourne la liste des contributeurs, avec en premier le créateur
  # de l'analyse
  def contributors
    @contributors ||=
      begin
        if @complete_data
          @complete_data[:contributors]
        else
          request = <<-SQL
          SELECT upa.user_id AS id, upa.role,
          u.pseudo
            FROM user_per_analyse upa
            INNER JOIN `boite-a-outils_hot`.users u ON u.id = upa.user_id
            WHERE film_id = #{id}
            ORDER BY role DESC
          SQL
          site.db.use_database(:biblio)
          site.db.execute(request)
        end
      end
  end


  # Table de tous les fichiers d'analyse de l'analyse.
  # Chaque élément est un Hash contenant :
  # :id     {Fixnum} ID absolu du fichier (absolu au travers de TOUTES les analyses)
  # :titre  {String} Le titre du fichier (pas forcément unique du tout)
  # :specs  {Varchar} Les spécifications du fichier
  # :hname  {String} = titre, pour les selects construits avec build_select
  #
  def fichiers_analyse
    @fichiers_analyse ||=
      begin
        site.db.select(:biblio,'files_analyses',{film_id: id}, [:id, :titre, :specs])
          .collect { |hfile| hfile.merge!(hname: hfile[:titre]) }
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

# L'analyse courante, if any
def analyse ; Analyse.current end
