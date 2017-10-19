# encoding: utf-8
class Analyse
  class << self

    # Retourne le code HTML du LI pour le film de donnée
    # +adata+ pour le lecteur +reader+
    #
    def as_li_for adata, reader
      #debug "reader(#{reader.pseudo}/#{reader.id}).analyste? #{reader.analyste?.inspect}"
      adata.merge!(reader: reader)
      <<-HTML
        <li class="analyse" id="analyse-#{adata[:id]}">
          <div class="fright buttons discret">
            #{reader.analyste? || reader.admin? ? bouton_contribuer(adata) : ''}
            #{bouton_lire(adata, reader)}
          </div>
          <div class="fright states tiny">
            #{analyse_states(adata)}
          </div>
          <span class="titre">#{titre_linked(adata)}</span>
      </li>
      HTML
    end

    # Code HTML du titre du film lié à sa fiche dans le
    # Filmodico
    def titre_linked adata
      titre = adata[:titre].force_encoding('utf-8')
      simple_link("filmodico/voir/#{adata[:id]}", titre, 'nodeco')
    end

    def bouton_contribuer adata
      if Analyse.has_contributor?(adata, adata[:reader].id)
        "<a class=\"vouscont\" href=\"analyser/dashboard/#{adata[:id]}\">vous contribuez</a>"
      else
        "<a href=\"analyser/postuler/#{adata[:id]}\">contribuer</a>"
      end
    end

    # Le bouton lire est affiché tout le temps lorsque c'est un analyste ou
    # un administrateur qui voit la liste des films, mais il ne l'est que
    # lorsque l'analyse est lisible dans le cas contraire.
    def bouton_lire adata, reader
      reader.analyste? || adata[:specs][4] == '1' || reader.admin? || (return '')
      "<a href=\"analyse/lire/#{adata[:id]}\">voir</a>"
    end

    def analyse_states adata
     <<-HTML
     <span class="creator" title="Initiateur de l'analyse">#{creator_linked(adata)}</span>
     <span title="Date de dernière modification">#{adata[:updated_at].as_human_date}</span>
     <span class="contributors" title="#{pseudos_contributors(adata)}">Ctbr: #{nombre_contributeurs(adata)}</span>
     HTML
    end

    # Retourne un lien vers le créateur de l'analyse
    def creator_linked adata
      # Le créator est le premier user de :contributors
      hcreator = adata[:contributors].first
      "<a href=\"user/profil/#{hcreator[:id]}\">#{hcreator[:pseudo]}</a>"
    end

    # Retourne le nombre de contributeur à l'analyse du film +film_id+
    def nombre_contributeurs adata
      adata[:contributors].count
    end


    # Liste des pseudos des contributeurs de l'analyse, tels que définis
    # dans la données :contributors
    def pseudos_contributors adata
      adata[:contributors].collect do |hcont|
        hcont[:pseudo]
      end.join(', ')
    end


  end #<<self
end #/Analyse
