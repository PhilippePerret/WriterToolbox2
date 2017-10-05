# encoding: utf-8
class Forum
  class Sujet

    TYPES_S = {
      0 => {hname: 'Non défini', value: 0},
      1 => {hname: 'Sujet général d’écriture', value: 1},
      2 => {hname: 'Question technique d’écriture', value: 2},
      9 => {hname: 'Autre sujet', value: 0}
    }

    class << self

      # Retourne l'instance Forum::Sujet du sujet d'ID +sujet_id+
      # sans refaire l'instance si elle existe déjà.
      # Note : le sujet n'a pas besoin d'exister déjà.
      def get sujet_id
        @sujets ||= Hash.new
        @sujets[:sujet_id] ||= new(sujet_id)
        return @sujets[sujet_id]
      end

    end #/<< self Sujet
  end #/Sujet
end #/Forum
