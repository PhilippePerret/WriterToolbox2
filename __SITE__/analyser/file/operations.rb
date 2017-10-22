# encoding: utf-8
class Analyse
  class AFile

    # Méthode principale qui reçoit la commande de l'opération
    #
    # Noter que l'opération est toujours (en tout cas jusq'à présent)
    # effectuée sur le fichier courant.
    #
    def do_operation ope
      
      ufiler.identified? || identification_required

      if ope != 'voir' && (ufiler.analyste? || ufiler.admin?) == false
        __error 'La seule action possible pour un simple inscrit et de visualiser cette page.'
        ope = 'voir'
      end
      
      # On charge certaines opérations pour les jouer
      # Pour les autres, elles sont traitées autrement, comme par exemple 'edit'
      # qui est géré simplement au moment d'afficher le contenu.
      
      case ope
      when 'save', 'publish', 'rem'
        require_lib("analyser/file:op_#{ope}")
        self.send("do_#{ope}".to_sym)
      end

    end

end #/AFile
end #/Analyse
