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
  # @param {Fixnum} film_id
  #                 ID du film (dans le filmodico, par exemple), qui est
  #                 le même ID que l'analyse.
  #
  # @param {User}   current_user
  #                 Instance de l'user courant. Le mieux est de fixer cette
  #                 valeur afin de simplifier toutes les méthodes de check 
  #                 du statut de l'utilisateur qui visite l'analyse.
  #                 Pour le moment, ça ne devrait être utile que pour la 
  #                 partie `analyser`, donc on fait un check de l'objet de
  #                 la route, mais ensuite, si les méthodes s'avèrent utiles
  #                 également dans la partie `analyse` (consultation), on 
  #                 pourra rapatrier les librairies UAnalyser et UFiler des
  #                 librairies requises de `analyser`.
  #
  def initialize film_id, current_user = nil
    @id = film_id
    current_user.nil? || site.route.objet == 'analyse' || define_uanalyser(current_user)
    debug "current_user est de classe #{current_user.class}"
    debug "Objet de la route : #{site.route.objet.inspect}"
    debug "À l'instanciation de l'analyse, @uanalyser à la classe #{@uanalyser.class}."
  end

  # L'user quelconque qui visite l'analyse
  def define_uanalyser who
    @uanalyser = UAnalyser.new(self, who)
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

end #/Analyse
