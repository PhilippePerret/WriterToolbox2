# encoding: utf-8
=begin

Module principal qui gère le panneau des taches. Pour le moment, on met tout ici

=end
class Unan
  class Abswork

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
      # Depuis la version 2.0 du boa, le travail est créé dès le
      # jour-programme de la visite de l'auteur, avec un status à 0.
      #
      def start_work program, work_id 
        site.db.update(
          :users_tables,                      # la base
          "unan_works_#{program.auteur_id}",  # la table
          {status: 1, started_at: Time.now.to_i},
          {id: work_id}
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


    end #/<< self AbsWork

  end #/Abswork


  class UUProgram
    def auteur_id
      @auteur_id ||= data[:auteur_id]
    end
  end
end #/Unan
