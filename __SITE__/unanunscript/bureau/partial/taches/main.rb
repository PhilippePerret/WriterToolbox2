# encoding: utf-8
=begin

Module principal qui gère le panneau des taches. Pour le moment, on met tout ici

=end
class Unan
  class AbsWork

    
    class << self

      # Démarre le travail absolu d'identifiant +awork_id+ pour le
      # programme +program+
      #
      # @usage
      #
      #     Unan::AbsWork.start_work prog, pday, wid
      # 
      # @return {Fixnum} ID
      #                  Identifiant du nouveau work créé
      #
      # Ce démarrage consiste à créer une donnée dans la table de
      # l'auteur avec les données requises
      #
      # Noter que le travail peut être démarré un autre jour que le
      # jour prévu mais que pour son enregistrement, c'est le pday
      # du travail absolu qui est choisi, que contient la donnée du
      # jour-programme en question, pas le jour-programme courant.
      # C'est la raison pour laquelle il faut fournir +abs_pday+
      #
      def start_work program, abs_pday, abswork_id
        site.db.insert(
          :users_tables,                      # la base
          "unan_works_#{program.auteur_id}",  # la table
          {
            program_id:   program.id,
            abs_work_id:  abswork_id,
            abs_pday:     abs_pday,
            status:       1, 
            options:      options_for_work(abswork_id), 
            points:       0
          }
        )
      end

      # Marquer le travail d'identifiant +work_id+ terminé
      #
      def finish_work program, work_id
        site.db.update(
          :users_tables,
          "unan_works_#{program.auteur_id}",
          {status: 9, ended_at: Time.now.to_i},
          {id: work_id}
        )
      end


      # -----------------------------------------------------------------------
      #
      #   MÉTHODES FONCTIONNELLES
      #   
      # -----------------------------------------------------------------------

      
      # Retourne la valeur d'option au démarrage du travail d'id +abswork_id+
      #
      def options_for_work abswork_id
        c = String.new
        c << typew_awork(abswork_id).to_s
        c << duree_awork(abswork_id).to_s
        return c
      end
      # Retourne le type de travail du travail absolu d'identifiant +abswork_id+
      def typew_awork abswork_id
        data_awork[abswork_id][:typew]
      end

      # Retourne la durée en nombre de jours-programme du travail absolu
      # d'identifiant +abswork_id+
      def duree_awork abswork_id
        data_awork[abswork_id][:duree]
      end


      # Retourne les données du travail absolu d'identifient +abswork_id+
      #
      def data_awork abswork_id
        @__data_awork ||= Hash.new
        @__data_awork[abswork_id] ||= 
          begin
            site.db.select(:unan,'absolute_works',{id: abswork_id}).first
          end
        @__data_awork[abswork_id]
      end
      
    end #/<< self AbsWork

  end #/Abswork


  class UUProgram
    def auteur_id
      @auteur_id ||= data[:auteur_id]
    end
  end
end #/Unan
