# encoding: utf-8
class Analyse
  class AFile

    # Méthode principale qui reçoit la commande de l'opération
    def do_operation ope
      # Le minimum, c'est que l'user soit identifié
      ufiler.identified? || identification_required
      # Le minimum aussi, c'est qu'il soit analyse, sauf pour voir la page
      if ope != 'voir' && ufiler.analyste? == false
        __error 'La seule action possible pour un simple inscrit et de visualiser cette page.'
        ope = 'voir'
      end
    end

end #/AFile
end #/Analyse
