# encoding: utf-8
class Analyse
  class Analyste
    class << self

      # Retourne true s'il y a des candidats aux analyses
      def candidats?
        candidats.count > 0
      end

      def candidats
        @candidats ||= site.db.select(:hot,'users',"SUBSTRING(options,17,1) = '1'")
      end

    end #/<<self
  end #/Analyste
end #/Analyse
