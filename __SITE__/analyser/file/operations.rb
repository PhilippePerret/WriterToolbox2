# encoding: utf-8
class Analyse
  class AFile
    class << self


      def do_operation ope, analyste
        # Le minimum, c'est que l'user soit identifié
        analyste.identified? || identification_required
        # Le minimum aussi, c'est qu'il soit analyse, sauf pour voir la page
        if ope != 'voir' && analyste.analyste? == false
          __error 'La seule action possible pour un simple inscrit et de visualiser cette page.'
          ope = 'voir'
        end
      end

    end #/<< self
  end #/AFile
end #/Analyse
