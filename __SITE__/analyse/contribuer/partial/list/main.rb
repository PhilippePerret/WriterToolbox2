# encoding: utf-8
class Analyse
  class << self

    # Retourne le code HTML du LI pour le film de donnée
    # +adata+ pour le lecteur +reader+
    #
    def as_li_for adata, reader
      adata.merge!(reader: reader)
      titre = adata[:titre].force_encoding('utf-8')
      <<-HTML
        <li class="analyse" id="analyse-#{adata[:id]}">
          <div class="fright buttons discret">
            #{bouton_contribuer(adata)}
            #{bouton_lire(adata)}
          </div>
          <div class="fright states tiny">
            #{analyse_states(adata)}
          </div>
          <span class="titre">#{titre}</span>
      </li>
      HTML
    end

    def bouton_contribuer adata
      if Analyse.has_contributor?(adata[:id], adata[:reader].id)
        '<span class="minuscule">vous<br>contribuez</span>'
      else
        "<a href=\"analyse/contribuer/#{adata[:id]}\">contribuer</a>"
      end
    end
    def bouton_lire adata
      "<a href=\"analyse/lire/#{adata[:id]}\">voir</a>"
    end

    def analyse_states adata
     <<-HTML
     <span title="Initiateur de l'analyse">#{User.pseudo_linked(adata[:creator_id])}</span>
     <span title="Date de dernière modification">#{adata[:updated_at].as_human_date}</span>
     <span title="Nombre de contributeurs">Ctbr: #{nombre_contributeurs(adata[:id])}</span>
     HTML
    end

    # Retourne un lien vers le créateur de l'analyse
    def creator_linked
      # Pour trouver le créateur de l'analyse (qui doit toujours exister), on 
      # doit chercher l'user dans user_per_analyse en lien avec le film et qui
      # a 1 dans son rôle.
      # Pour le relever au cours de la relève des données du film, on peut faire
      # INNER JOIN user_per_table upt ON fa.id = upt.film_id
      # avec en colonne à remonter : upt.user_id AS contributors
      
    end

    # Retourne le nombre de contributeur à l'analyse du film +film_id+
    def nombre_contributeurs film_id
      site.db.count(:biblio,'user_per_analyse',{film_id: film_id})
    end

    # Méthode qui retourne TRUE si l'user +user_id+ contribue à l'analyse
    # du film d'ID +film_id+, et FALSE dans le cas contraire.
    def has_contributor?(film_id, user_id)
      site.db.count(:biblio,'user_per_analyse',{user_id: user_id, film_id: film_id}) > 0
    end
  end #<<self
end #/Analyse
