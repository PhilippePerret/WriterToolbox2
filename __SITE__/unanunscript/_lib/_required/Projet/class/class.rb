# encoding: UTF-8


class Unan
  class UUProjet

    extend  PropsAndDbMethods
    include PropsAndDbMethods

    # ---------------------------------------------------------------------
    #
    #   CLASSE
    #   
    # ---------------------------------------------------------------------

    class << self


      def base_n_table
        @base_n_table ||= [:unan, 'projets']
      end

    end #/ << self (UUProjet)


  end #/ UUProjet
end #/ Unan
