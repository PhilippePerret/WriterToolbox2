# encoding: utf-8
class Analyse
  class << self

    # Retourne la liste UL des films analysés pour le niveau de
    # l'user +reader+
    # @param {User} reader
    #               L'utilisateur qui visite la section des analyses de
    #               film. Ça peut être un simple visiteur, un inscrit,
    #               un analyste, etc.
    def list_for reader
      where =
        case 
        when !reader.identified? then '100'
        when reader.suscriber?  then '1'
        else '11'
        end
      where = "WHERE SUBSTRING(fa.specs,1,#{where.length}) = '#{where}'"
      debug "where = #{where}"
      lis_films = String.new
      request = <<-SQL
      SELECT f.id, f.titre, f.titre_fr, fa.specs
        FROM films_analyses fa
        INNER JOIN filmodico f ON fa.id = f.id
        #{where};
      SQL
      site.db.use_database(:biblio)
      site.db.execute(request)
        .each do |hfilm|
        lis_films << "<li class=\"film\" id=\"film-#{hfilm[:id]}\">#{hfilm[:titre]}</li>"
      end
      return "<ul id=\"analyse_list\">#{lis_films}</ul>"
    end
  end #<< self
end #/Analyse
