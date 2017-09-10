# encoding: utf-8
#
class Scenodico
  class Lettre

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
      id > 0 && id < 27 || raise("Cette lettre est introuvable.")
    end

    # La lettre (de A à Z) à laquelle correspond l'ID
    def char
      @char ||= (id + 64).chr # => de A à Z 
    end

    # La liste des mots de la lettre voulue
    #
    # @return {Array de Hash} contenant {:id, :mot}
    def mots
      @mots ||=
        begin
          site.db.select(:biblio,'scenodico',"mot LIKE '#{char}%' ORDER BY mot ASC", [:id, :mot])
        end
    end


    # --------------------------------------------------------------------------------
    #
    #   MÉTHODES D'HELPER
    #
    # --------------------------------------------------------------------------------

    # Retourne le code HTML du listing des mots de la lettre courante
    #
    def listing_mots
      '<ul class="listing" id="scenodico">'+
        mots.collect do |hmot|
        "<li><a href=\"scenodico/mot/#{hmot[:id]}\">#{hmot[:mot]}</a></li>"
        end.join('')+
          '</ul>'
    end


    def base_n_table ; @base_n_table ||= [:biblio,'scenodico'] end

  end #/ Lettre
end #/Scenodico


# Méthodes d'helpers
class Site

  # Retourne le code HTML de toutes les lettres pour choisir les listings
  def alphabet
    c = lettre.char
    '<div id="alphabet_scenodico" class="alphabet">' +
    (65..90).collect do |charid|
      char = charid.chr
      "<a href=\"scenodico/list/#{charid - 64}\"#{char == c ? ' class="selected"' : ''}>#{char}</a>"
    end.join('') +
      '</div>'
  end

end


# La lettre courante (A par défaut)
def lettre
  @lettre ||= Scenodico::Lettre.new(site.route.objet_id || 1)
end
