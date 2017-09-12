# encoding: UTF-8

class Unan
  class UUProjet

    include PropsAndDbMethods

    attr_reader :id

    # Instanciation du projet d'identifiant +pid+ ou instanciation
    # simple, sans ID
    #
    def initialize pid = nil
      @id = pid
    end

    def base_n_table ; self.class.base_n_table end

  end #/UUProjet
end #/Unan
