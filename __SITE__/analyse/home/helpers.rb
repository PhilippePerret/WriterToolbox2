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


      # On ne met plus de filtre sur le reader, maintenant : tout le
      # monde peut voir les films à partir du moment où ils sont 
      # analysés.
      where = "WHERE SUBSTRING(fa.specs,1,1) = '1'"
      
      lis_films = String.new
      request = <<-SQL
      SELECT f.id, f.titre, f.titre_fr, fa.specs, f.annee,
        fa.realisateur AS director
        FROM films_analyses fa
        INNER JOIN filmodico f ON fa.id = f.id
        #{where};
      SQL
      site.db.use_database(:biblio)
      site.db.execute(request)
        .each do |hfilm|
        lis_films << li_film(hfilm)
      end
      return "<ul id=\"analyse_list\">#{lis_films}</ul>"
    end
    
    def li_film hfilm
      <<-HTML
      <li class="film" id="film-#{hfilm[:id]}">
        <span class="titre">
          <a href="analyse/lire/#{hfilm[:id]}" class="nodeco">
            #{hfilm[:titre].force_encoding('utf-8')}
          </a>
        </span>
        <span class="annee">#{hfilm[:annee]}</span>
        <span class="director">#{only_name_of hfilm[:director]}</span>
      </li>
      HTML
    end

    def only_name_of patronyme
      patronyme.force_encoding('utf-8').split(' ').last
    end
  end #<< self
end #/Analyse
