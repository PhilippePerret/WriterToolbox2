# encoding: utf-8
class OperationNotPermittedError < StandardError ; end

class Unan
  class Work
    class << self

      # Démarrer un travail
      #
      def start auteur, work_id
        base, table = [:users_tables, "unan_works_#{auteur.id}"]
        # BARRIERE : pas un auteur du programme
        is_auteur_unanunscript?(auteur)
        # BARRIÈRE : travail inconnu pour cet auteur
        hwork = get_and_check_work(auteur, table, work_id)
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
          table,
          {status: hwork[:status], started_at: Time.now.to_i},
          {id: work_id}
        )
        __notice("Travail démarré avec succès. Bon courage, #{auteur.pseudo}&nbsp;!")
      rescue OperationNotPermittedError => e
        debug e
        raise "Désolé, mais vous n'êtes pas en mesure d'accomplir cette opération."
      end

      # Marquer un travail fini
      #
      def done auteur, work_id
        base, table = [:users_tables, "unan_works_#{auteur.id}"]
        is_auteur_unanunscript?(auteur)
        hwork = get_and_check_work(auteur, table, work_id)
        hwork[:status] & 1 > 0 ||
          begin
            # Deux raisons peuvent faire passer par ici : le travail est déjà marqué
            # comme terminé et il l'est marqué depuis longtemps. Ou alors l'auteur
            # a rechargé malencontreusement sa page (dans la demi-heure précédente)
            if hwork[:status] == 9 && (hwork[:ended_at] > Time.now.to_i - 1800)
              return # on s'en retourne sans rien faire
            else
              raise(OperationNotPermittedError.new('Ce travail n’est pas en cours.'))
            end
        end

        # Si le travail est en dépassement, il faut conserver le nombre de jours
        # de dépassement. Ça ne sert pas encore pour le moment, mais ça pourra
        # servir ensuite lors de rapports ou autres.
        status = hwork[:status]
        if status & 2 > 0 || status & 4 > 0
          duree_jours = hwork[:options][2..4].to_i(10)
          coef_duree  = 5.0 / auteur.program.rythme
          real_duree_seconds = duree_jours.jours.to_f / coef_duree
          expected_end = hwork[:started_at] + real_duree_seconds
          depassement_jours  = ((Time.now.to_i - expected_end) / 1.jour).ceil
          opts = hwork[:options].ljust(9,'0')
          opts[6..8] = depassement_jours.to_s.rjust(3,'0')
          hwork[:options] = opts
        end


        # Si on arrive ici, c'est que l'opération est possible. On peut arrêter
        # cette tâche en réglant sa date de fin et en attributant les points reçus.
        # On actualise aussi les options, qui peuvent contenir le nombre de jours
        # de dépassement s'il y en avait.
        site.db.update(
          base, table,
          {
            status:   9, 
            ended_at: Time.now.to_i, 
            points:   points_recus_pour(hwork), 
            options:  hwork[:options]
          },
          {id: work_id}
        )

        # TODO En fonction du type (page de cours à lire par exemple), d'autres
        # opérations seront peut-être nécessaires.

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
      def get_and_check_work auteur, table, work_id
        hwork = site.db.select(:users_tables,table,{id: work_id}).first
        hwork != nil || raise(OperationNotPermittedError.new("Le travail spécifié n'existe pas."))
        return hwork 
      end

      # Retourne le nombre de points reçus pour l'accomplissement d'une
      # tache. Dans le cadre normal, ce nombre de points est celui défini
      # dans les données absolues du travail. Mais s'il y a dépassement, 
      # ce nombre de points diminue.
      def points_recus_pour hwork
        habswork = site.db.select(:unan,'absolute_works',{id: hwork[:abs_work_id]},[:points, :duree]).first
        points = habswork[:points] || 0
        points > 0 || (return 0)
        fin_expected = hwork[:started_at] + habswork[:duree].jours
        fin_expected >= Time.now.to_i && (return points)
        retard = Time.now.to_i - fin_expected
        # On enlève 10 par jours (jours normaux, pas jour-programme)
        return points - (10 * (retard/1.jours + 1))
      end



    end #/<< self
  end #/Work
end #/Unan
