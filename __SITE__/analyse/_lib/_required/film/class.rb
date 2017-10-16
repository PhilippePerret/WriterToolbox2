# encoding: utf-8
class Analyse
  class Film
    class << self

      # Le film courant
      # Défini par l'objet_id de la route lorsque c'est un Fixnum
      attr_reader :current

      def set_current film_id
        @current = new(film_id)
      end

    end #/<< self
  end #/Film
end #/Analyse
