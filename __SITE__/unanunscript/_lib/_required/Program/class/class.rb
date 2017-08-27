# encoding: UTF-8

class Unan
  class UUProgram

    extend  PropsAndBdMethods
    include PropsAndBdMethods

    # ---------------------------------------------------------------------
    #
    #  CLASSE 
    #
    # ---------------------------------------------------------------------
    class << self

      def base_n_table
        @base_n_table ||= [:unan, 'programs']
      end
    end #/ << self



  end #/ UUProgram
end #/ Unan
