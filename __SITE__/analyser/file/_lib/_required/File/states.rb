# encoding: utf-8
class Analyse
  class AFile

    # TRUE si le fichier peut être lu (et seulement lu dans la partie
    # analyse) par n'importe quel inscrit.
    # C'est le 4e bit des specs du fichier
    
    def visible_par_inscrit?
      @is_visible_par_inscrit.nil? && @is_visible_par_inscrit = data[:specs][3] == '1'
      @is_visible_par_inscrit
    end

  end #/AFile
end #/Analyse
