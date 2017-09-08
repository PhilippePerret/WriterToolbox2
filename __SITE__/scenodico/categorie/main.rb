# encoding: utf-8
class Scenodico
  class Categorie

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
    end

    # Le nom de la catégorie, tel qu'affiché
    def displayed_name
      categorie.data[:hname].downcase
    end
    # Retourne le code HTML de la liste des mots, formatés
    def liste_mots
      @liste_mots ||=
        begin
          # On passe d'abord tous les mots en minuscule, sauf le premier
          mots.each { |m| m[:mot] = m[:mot].downcase }
          mots[0] && mots[0][:mot] = mots[0][:mot].titleize
          # On peut ensuite construire la liste lié
          mots.collect do |hmot|
            "<a href=\"scenodico/mot/#{hmot[:id]}\">#{hmot[:mot]}</a>"
          end.join(', ') + '.'
        end
    end

    # Retourne la liste Array de tous les mots.
    # Chaque élément est un hash contenant seulement {:id, :mot}
    def mots
      @mots ||=
        begin
          site.db.select(:biblio,'scenodico',"categories LIKE '%#{data[:cate_id]}%' ORDER BY mot ASC",[:id, :mot])
        end
    end

    def base_n_table ; @base_n_table ||= [:biblio,'categories'] end

  end #/Categorie
end #/Scenodico


# La catégorie courante
def categorie
  @categorie ||= Scenodico::Categorie.new(site.route.objet_id || 1)
end
