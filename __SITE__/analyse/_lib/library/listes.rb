# encoding: utf-8
#
# Librairie pour le traitement des analyses comme liste
#
# C'est une librairie car ce n'est pas le cas le plus courant
# de gérer toutes les analyses.
#
class Analyse
  class << self

    # Renvoie la liste de toutes les analyses répondant au
    # filtre +filtre+
    #
    # @return Une liste de Hash de données
    #         En plus des données normales des films (:titre, :titre_fr, etc.),
    #         on trouve la données :
    #         :contributors   Qui est une liste (Array) de Hash contenant les
    #                         information minimales sur les contributeurs, i.e.:
    #                         :id     ID du contributeur (dans boite-a-outils_hot.users)
    #                         :pseudo Pseudo du contributeur (id.)
    #                         :role   Rôle du contributeur (dans user_per_analyse)
    #
    # @param {Hash} filtre
    #
    #               :which
    #                   Déterminer les analyses à afficher. Les valeurs peuvent
    #                   être :
    #                   :current    Les analyses à en cours
    #                   :all        Toutes les analyses
    #                   TODO Plus tard, on pourra avoir aussi :
    #                   :user       Les analyses auxquelles contribue l'user courant
    #                   Mais il faut encore poursuivre la réflexion car comment voir
    #                   par exemple les analyses courantes de l'user ou toutes ses
    #                   analyses => Il faut un autre paramètre au filtre.
    #
    #               :not_analysed 
    #
    #                   Si TRUE, on ne prend que les films non analysés. FALSE par 
    #                   défaut, donc il n'est nécessaire de le préciser que pour 
    #                   le mettre à TRUE.
    #
    def all filtre = nil
      filtre ||= Hash.new

      # Pour construire la clause WHERE

      where = Array.new

      specs_pattern = '_'*32

      # Par défaut, c'est un film analysé qu'on cherche
      specs_pattern[0] = filtre[:not_analysed] === true ? '0' : '1'
      
      
      # S'il faut seulement les films en cours d'analyse
      filtre[:which] == :current && specs_pattern[5] = '1'

      # Finalisation de la pattern pour :specs
      specs_pattern.gsub!(/_+$/,'')
      specs_pattern += '%'
      where << "fa.specs LIKE '#{specs_pattern}'"

      where = where.join(' AND ')
      request = <<-SQL
      SELECT fa.*,
        f.titre, f.titre_fr, f.annee
        FROM films_analyses fa
        INNER JOIN filmodico f ON f.id = fa.id
        WHERE #{where}
        SQL

      site.db.use_database(:biblio)
      analyses = site.db.execute(request)

      # On relève les contributeurs pour les mettres dans chaque analyse
      # de film.

      request = <<-SQL
      SELECT film_id
        , GROUP_CONCAT(CONCAT(user_id,':',u.pseudo,':',upa.role) ORDER BY upa.role DESC SEPARATOR '---') AS idnames

        FROM user_per_analyse upa
        INNER JOIN films_analyses fa ON fa.id = upa.film_id
        INNER JOIN `boite-a-outils_hot`.users u ON upa.user_id = u.id
        WHERE #{where}
        GROUP BY film_id
      SQL

      data_contribs = Hash.new
      site.db.execute(request).each do |hcontribs|
        contributors =
          hcontribs[:idnames].split('---').collect do |paire|
            id, pseudo, role = paire.split(':')
            {id: id.to_i, pseudo: pseudo, role: role.to_i}
          end
        film_id = hcontribs.delete(:film_id)
        data_contribs.merge!(
          film_id => contributors
        )
      end

      analyses.each do |analyse|
        analyse.merge! contributors: data_contribs[analyse[:id]]
      end

      return analyses
    end

  end #/<< self
end #/Analyse
