# encoding: utf-8
#
# Class Quiz::Question
# --------------------
# Module de traitement propre au calcul du quiz
# Permet de compléter la données @resultats[:reponses] du quiz avec
# toutes les informations sur chaque question.
#
class Quiz
  class Question

    # @param {Hash} ureponse
    #               Contient la propriété utile pour connaitre les points
    #               :choix      Index des réponses choisies par l'owner. Toujours
    #                           une liste Array, même pour un choix unique.
    #               Contient toutes les propriétés qu'il va falloir
    #               renseigner, à savoir :
    #               :points     Nombre de points marqués pour la question
    #               :points_max Nombre maximum de points qu'on pouvait marquer
    #                           pour la question.
    #               :bons_choix Les choix valides
    #               :best_choix Les meilleurs choix (quand choix multiples, tous
    #                           les choix au-dessus de 0)
    #
    def traite_reponse ureponse
      ureponse[:bons_choix] = Array.new
      points_max = 0     # le nombre de points qu'on pouvait gagner avec
                         # cette question.
      best_choix = nil   # index du meilleur choix
      best_points = 0    # meilleur points
      points = 0         # Points marqués pour la question (peut être négatif)
      points_par_reponses.each_with_index do |pts, index_choix|
        if pts > best_points
          best_points = pts
          best_choix  = index_choix
        end
        if pts > 0
          ureponse[:bons_choix] << index_choix
          points_max += pts
        end
        # Est-ce une réponse choisie ?
        if ureponse[:choix].include?(index_choix)
          points += pts # peut être négatif
        end
      end
      ureponse.merge!(
        points_max:   points_max,
        best_choix:   best_choix,
        best_points:  best_points,
        points:       points
      )

      return ureponse
    end

    # Retourne la liste des points par réponse.
    # Une liste comme : [0, 0, 10, -5]
    def points_par_reponses      
      @points_par_reponses ||=
        begin
          data[:reponses].split("\n").collect do |line_rep|
            lib, points, raison = line_rep.split(DELIM_REPONSE_DATA)
            points.to_i
          end
        end
    end

  end #/Question
end #/Quiz
