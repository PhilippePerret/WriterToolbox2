# encoding: utf-8
class Analyse
  class << self

    # Méthode pour créer une nouvelle analyse
    # @param {User} analyste
    #               L'analyste qui veut initier cette analyse
    # @param {Hash} adata
    #               Les données pour l'analyse à initier
    #               Ce sont les champs du formulaire de création
    #
    def create_new analyste, adata
      # Produit une erreur si l'analyste n'en est pas un
      analyste_only
      # Produit une erreur si ce film est déjà analysé

      # Tout est OK, on peut initier l'analyse
      #
    end
  end #/<<self

  class Film
    class << self

      # Retourne le code d'un select avec tous les films du filmodico qui n'ont pas
      # été analysés.
      def menu_films_unanalysed
        request = <<-SQL
        SELECT f.titre, f.titre_fr, f.annee, f.id
          FROM films_analyses fa
          INNER JOIN filmodico f ON fa.id = f.id
          WHERE SUBSTRING(specs,1,1) = '0'
          ORDER BY f.annee DESC
        SQL
        site.db.use_database(:biblio)

        "<select name=\"analyse[film_id]\" id=\"analyse_film_id\">"+
        site.db.execute(request).collect do |hfilm|
          titre = hfilm[:titre].force_encoding('utf-8')
          hfilm[:titre_fr].nil_if_empty && titre << " (#{hfilm[:titre_fr].force_encoding('utf-8')})"
          "<option value=\"#{hfilm[:id]}\">#{hfilm[:annee]} #{titre}</option>"
        end.join +
        '</select>'
      end
    end #/<< self (Film::Analyse)
  end #/Film
end #/Analyse
