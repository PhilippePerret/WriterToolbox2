# encoding: utf-8
class Analyse
  class << self


    # Analyse courante, définie par le objet_id de l'url ou
    # explicitement par Analyse.current=
    #
    # On définit également le `uanalyser` de l'analyse, c'est-à-dire
    # l'user courant, pour simplifier les checks de statut.
    #
    def current
      @current ||= 
        begin
          if site.route.objet_id.is_a?(Fixnum)
            new(site.route.objet_id, user)
          else
            nil
          end
        end
    end
    
    # Définition explicite de l'analyse courante
    def current= a
      @current = a
    end

  end #/<< self
end #/Analyse
