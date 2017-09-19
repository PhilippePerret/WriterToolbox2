# encoding: utf-8

=begin

  Module qui permet d'actualiser la table `unan_works_<id auteur>` de l'auteur +auteur+
  entre le jour-programme +pday_start+ jusqu'au jour-programme +pday_end+
=end

class Unan
  class Work
    class << self

      # @param {User}   Auteur
      #                 Doit être un auteur du programme
      # @param {Fixnum} pday_start
      #                 Le jour-programme de départ. Correspond normalement
      #                 au dernier jour d'actualisation de la table, consigné
      #                 dans les bits 8 à 10 des options du programme.
      # @param {Fixnum} pday_end
      #                 Le jour-programme de fin. Correspond normalement au
      #                 jour-programme courant de l'auteur.
      def update_table_works_auteur auteur, pday_start, pday_end

        auteur.is_a?(User) || raise(ArgumentError.new "La méthode `update_table_works_auteur` attend un User en premier argument.")
        auteur.unanunscript? || raise(ArgumentError.new "#{auteur.pseudo} ne suit pas le programme UN AN UN SCRIPT.")
        pday_start.is_a?(Fixnum) || raise(ArgumentError.new "Le pday de départ doit être spécifié par un nombre (Fixnum)")
        pday_end.is_a?(Fixnum) || raise(ArgumentError.new "Le pday de fin doit être spécifié par un nombre (Fixnum)")


        # Il faut d'abord s'assurer que la table existe.
        # On la crée le cas échéant.
        ensure_table_works_exists(auteur)

        # Une fois que la table est créée, on peut synchroniser
        # ses données pour que tous les travaux absolus possèdent
        # leur work-relative dans la table.
        #
        # Dans un premier temps, on relève tous les IDs des travaux absolus
        # des jours-programme demandés.
        # Ensuite, on charge les propriétés :id et :typew de ces travaux
        # absolus pour renseigner les work-relatifs qu'on crée dans la
        # table de l'auteur. Le :typew, qui permet de connaitre le type du
        # travail relatif sans charger le travail absolu, est consigné dans
        # les deux premiers bits de l'option du travail relatif

        hpdays = Hash.new
        # Ce sera une table avec en clé le pday et en valeur
        # la liste des identifiants des travaux absolus. On mettre également
        # tous les ids dans une simple liste pour pouvoir charger toutes leurs
        # données d'un seul coup :
        abs_works_ids = Array.new

        # On peut boucler sur toutes les données pdays
        where = "id >= #{pday_start} AND id <= #{pday_end}"
        site.db.select(:unan,'absolute_pdays',where,[:id,:works]).each do |hpday|
          id_list = hpday[:works].as_id_list
          hpdays.merge!( hpday[:id] => id_list)
          abs_works_ids += id_list
        end

        # On relève les données des travaux absolus (:id, :item_id et :type_w)
        habsworks = Hash.new
        site.db.select(:unan,'absolute_works',"id IN (#{abs_works_ids.join(', ')})",[:id, :item_id, :type_w])
          .each do |habswork|
          habsworks.merge!( habswork[:id] => habswork )
        end


        # On a tout ce qu'il faut maintenant pour créer les travaux relatifs dans
        # la table de l'auteur. Pour accélerer la procédure, on va le faire avec
        # une requête préparée.
        now = Time.now.to_i

        request = "INSERT INTO unan_works_#{auteur.id}"+
          " (abs_work_id, abs_pday, item_id, options, points, created_at, updated_at,"+
          " status, program_id)" +
          " VALUES (?, ?, ?, ?, 0, #{now}, #{now}, 0, #{auteur.program.id})"

        array_values = Array.new
        hpdays.each do |pday_id, awork_ids|
          awork_ids.each do |awork_id|
            habswork = habsworks[awork_id]

            # Les valeurs pour la requête préparée
            array_values << [awork_id, pday_id, habswork[:item_id]||nil, options_for_work(habswork[:id])]

          end # / fin de boucle sur tous les ids abs-work du pday
        end # / fin de boucle sur tous les pdays voulus

        site.db.use_database(:users_tables)
        site.db.execute(request, array_values)

        # Si on arrive ici, c'est que tout s'est bien passé, on peut indiquer
        # dans le programme le dernier pday d'actualisation.
        opts = auteur.program.options
        opts[7..9] = pday_end.to_s.rjust(3,'0')
        auteur.program.set(options: opts)

        return true # Ne sert pas encore, pour le moment
      end


      # Retourne la valeur d'option au démarrage du travail d'id +abswork_id+
      #
      def options_for_work abswork_id
        typew = typew_awork(abswork_id)
        c = String.new
        c << typew.to_s.rjust(2,'0')
        c << duree_awork(abswork_id).to_s.rjust(3,'0')
        c << Unan::Abswork::TYPES[typew][:itype] # sur un chiffre
        return c
      end
      # Retourne le type de travail du travail absolu d'identifiant +abswork_id+
      def typew_awork abswork_id
        data_awork[abswork_id][:type_w]
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
        @__data_awork[abswork_id] ||= site.db.select(:unan,'absolute_works',{id: abswork_id}).first
        @__data_awork[abswork_id]
      end
      # S'assure que la table des works-relatifs de l'auteur +auteur+
      # existe et la crée le cas échéant.
      def ensure_table_works_exists(auteur)
        auteur.is_a?(User) || raise(ArgumentError.new('La méthode `ensure_table_works_exists` attend un User.'))
        debug "-> ensure_table_works_exists"
        begin
          site.db.count(:users_tables,"unan_works_#{auteur.id}")
        rescue Mysql2::Error => e
          if e.message.match(/Table(.*?)doesn't exist/)
            create_table_works(auteur)
          else
            # Une autre erreur non gérée.
            raise e
          end
        end
      end
      # Création de la table works pour l'auteur +auteur+
      def create_table_works auteur
        auteur.is_a?(User) || raise(ArgumentError.new('La méthode `create_table_works` attend un User.'))
        debug "-> create_table_works"
        table_name = "unan_works_#{auteur.id}"
        site.db.use_database(:users_tables)
        site.db.query(<<-SQL)
        CREATE TABLE #{table_name}(
          id INTEGER AUTO_INCREMENT,
          program_id INTEGER NOT NULL,
          abs_work_id INTEGER NOT NULL,
          abs_pday INTEGER(4) NOT NULL,
          item_id INTEGER,
          status INTEGER(1) DEFAULT 0,
          options VARCHAR(32) DEFAULT '',
          points INTEGER(3) DEFAULT 0,
          started_at INTEGER(10),
          ended_at INTEGER(10),
          updated_at INTEGER(10),
          created_at INTEGER(10) NOT NULL,
          PRIMARY KEY (id)
        );
        SQL

      end
    end #<< self
  end #/Work
end #/Unan
