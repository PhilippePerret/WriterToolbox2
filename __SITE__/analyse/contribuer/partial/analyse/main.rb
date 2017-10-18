# encoding: utf-8
class Analyse
  class << self

    def proposition_contribution film_id, candidat
      require_lib('analyse/contribuer:proposition')
      do_proposition_contribution film_id, candidat
    end

  end #/<< self
end #/Analyse
