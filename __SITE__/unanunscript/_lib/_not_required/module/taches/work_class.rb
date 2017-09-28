# encoding: utf-8
class OperationNotPermittedError < StandardError ; end

class Unan
  class Work
    class << self

      # Démarrer un travail
      #
      def start auteur, work_id
        base, table_works = [:users_tables, "unan_works_#{auteur.id}"]
        # BARRIERE : pas un auteur du programme
        is_auteur_unanunscript?(auteur)
        # BARRIÈRE : travail inconnu pour cet auteur
        hwork = get_and_check_work(auteur, table_works, work_id)
        hwork[:status] & 1 == 0 || begin
            if hwork[:started_at] > Time.now.to_i - 1800
              return # ne rien faire, le travail vient d'être démarré
            else
              raise(OperationNotPermittedError.new('Ce travail n’est pas à démarrer'))
            end
        end

        # Si on arrive ici, c'est que l'opération est possible. On peut démarrer
        # cette tâche.
        hwork[:status] |= 1 # pour conserver les éventuels dépassements

        site.db.update(
          base,
          table_works,
          {status: hwork[:status], started_at: Time.now.to_i},
          {id: work_id}
        )
        __notice("Travail démarré avec succès.")
      rescue OperationNotPermittedError => e
        debug e
        raise "Désolé, mais vous n'êtes pas en mesure d'accomplir cette opération."
      end

      # Marquer un travail fini
      #
      # @param {User} auteur
      #               L'auteur du travail
      # @param {Fixnum} work_id
      #                 ID unique du travail
      # @param {Hash}   options
      #                 Éventuellement des options
      #                 Par exemple, pour un quiz du programme, l'évaluation du
      #                 quiz appelle cette méthode avec {points: <nombre de points>}
      #                 pour substituer au nombre de points "normaux" le véritable
      #                 nombre de points en fonction des réponses données
      def done auteur, work_id, options = nil
        options ||= Hash.new
        base, table_works = [:users_tables, "unan_works_#{auteur.id}"]
        is_auteur_unanunscript?(auteur)
        hwork = get_and_check_work(auteur, table_works, work_id)

        if hwork[:status] == 9
          return __error("Ce travail est déjà marqué terminé.")
        elsif hwork[:status] & 1 == 0
          raise(OperationNotPermittedError.new('Ce travail n’est pas en cours.'))
        end

        # Nombre de points gagnés pour ce travail
        #
        # On conserve le nombre de points initialement attribués pour savoir
        # si l'auteur aurait dû en gagner mais qu'il a rendu le travail trop
        # tard.
        # 
        # Rappel : le nombre de points est défini à la création du travail, mais
        # il peut diminuer si le travail est exécuté en retard.
        # Rappel : il est envoyé par les options lorsque c'est un quiz
        won_points = points_init = options[:points] || hwork[:points] || 0
        
        debug "Points de départ dans Unan::Work::done : #{won_points}"

        # Si le travail est en dépassement, il faut conserver le nombre de jours
        # de dépassement. Ça ne sert pas encore pour le moment, mais ça pourra
        # servir ensuite lors de rapports ou autres.
        #
        # On en profite aussi pour calculer le nombre de points, car chaque
        # retard entraine une dégrèvement.
        #
        status = hwork[:status]
        depassement = status & (2|4) > 0
        if depassement
          # On calcule le dépassement exact avant de recalculer le
          # nombre de points qui seront attribués.
          duree_jours = hwork[:options][2..4].to_i(10)
          coef_duree  = 5.0 / auteur.program.rythme
          real_duree_seconds = duree_jours.jours.to_f / coef_duree
          expected_end = hwork[:started_at] + real_duree_seconds
          depassement_jours  = ((Time.now.to_i - expected_end) / 1.jour).ceil
          opts = hwork[:options].ljust(9,'0')
          opts[6..8] = depassement_jours.to_s.rjust(3,'0')
          hwork[:options] = opts
          won_points = points_recus_pour( hwork, won_points)
        end

        debug "Nombre de points finalement attribués : #{won_points}"

        # Rectification des points, on ne met jamais de points négatifs.
        won_points >= 0 || won_points = 0

        # Si on arrive ici, c'est que l'opération est possible. On peut arrêter
        # cette tâche en réglant sa date de fin et en attributant les points reçus.
        # On actualise aussi les options, qui peuvent contenir le nombre de jours
        # de dépassement s'il y en avait.
        site.db.update(
          base, table_works,
          {
            status:   9, 
            ended_at: Time.now.to_i, 
            points:   won_points,
            options:  hwork[:options]
          },
          {id: work_id}
        )

        # Si des points ont été attribués, il faut les ajouter au programme
        # lui-même
        if won_points > 0
          total_points = auteur.program.get(:points) + won_points
          auteur.program.set(points: total_points) 
        end

        # TODO En fonction du type (page de cours à lire par exemple), d'autres
        # opérations seront peut-être nécessaires.

        # Message de confirmation
        #
        # On indique aussi à l'auteur les points qu'il a gagné, si c'est le cas
        # Plus tard, on salue les "paliers" franchis (tous les milles, par exemple)
        __notice('Travail marqué fini.')
        if won_points > 0
          seulement = depassement ? ' seulement' : ''
          __notice("Vous gagnez#{seulement} #{won_points} points. Votre compte actuel est de #{total_points}.")
          # TODO Ici, il faudrait faire quelque chose si l'auteur vient de passer un certain
          # nombre de points (tous les 10000 ?). Il pourrait gagner des badges ou autre.
        end

        # En cas de dépassement, on indique à l'auteur le nombre de points qu'il
        # aurait pu gagner.
        #
        if depassement && won_points < points_init
          message_pre = won_points > 0 ? '' : "Vous ne marquez aucun point. "
          __notice("#{message_pre}Sans dépassement d'échéance, vous auriez pu marquer #{points_init} points.")
        end
      rescue OperationNotPermittedError => e
        debug e
        raise "Désolé, mais vous n'êtes pas en mesure d'accomplir cette opération."
      end


      # Produit une erreur si l'auteur n'est en fait pas un auteur
      # du programme UN AN UN SCRIPT.
      def is_auteur_unanunscript?(auteur)
        auteur.unanunscript? || raise(OperationNotPermittedError.new("Pas un auteur du programme."))
      end

      # Retourne le travail-relatif d'identifiant +work_id+ de l'auteur +auteur+
      # ou produit une erreur d'opération impossible.
      def get_and_check_work auteur, table_works, work_id
        hwork = site.db.select(:users_tables,table_works,{id: work_id}).first
        hwork != nil || raise(OperationNotPermittedError.new("Le travail spécifié n'existe pas."))
        return hwork 
      end

      # Retourne le nombre de points reçus pour l'accomplissement d'une
      # tache. Dans le cadre normal, ce nombre de points est celui défini
      # dans les données absolues du travail. Mais s'il y a dépassement, 
      # ce nombre de points diminue.
      #
      # Noter que +points+ n'est pas nécessairement le nombre de points consignés pour
      # mémoire dans +hwork+. Pour les quiz, ce nombre est souvent 0 quand il faut prendre
      # le nombre de points du quiz plutôt que du travail absolu. Dans ce cas, +points+
      # est celui reçu par le quiz au moment de l'évalusation.
      #
      def points_recus_pour hwork, points
        points > 0 || (return 0)
        fin_expected = hwork[:expected_at]
        fin_expected >= Time.now.to_i && (return points)
        retard = Time.now.to_i - fin_expected
        # On enlève 10 par jours (jours normaux, pas jour-programme)
        return points - (10 * (retard/1.jours + 1))
      end



    end #/<< self
  end #/Work
end #/Unan
