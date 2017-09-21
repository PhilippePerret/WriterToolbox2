# encoding: utf-8

=begin

  Module qui permet d'actualiser la table `unan_works_<id auteur>` de l'auteur +auteur+
  entre le jour-programme +pday_start+ jusqu'au jour-programme +pday_end+
=end

class Unan
  class Work
    class << self

      # Méthode appelée pour actualiser la table des works-relatifs de
      # l'auteur. Elle tient à jour la liste des travaux que l'auteur doit
      # exécuter, en jouant sur le statut (status) pour indiquer les travaux qui
      # sont à démarrer (travaux du jour) ou les travaux en dépassement et en
      # grand dépassement.
      # Cette méthode n'est appelée qu'une seule fois par jour-programme, lorsque
      # le jour-programme courant ne correspond pas au jour-programme des options
      # du programme.
      #
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

        # On relève les travaux relatifs existants déjà dans la période
        # données, afin de ne créer que ceux qui n'existent pas. Cette méthode
        # sert principalement lorsque le travail ne se fait pas régulièrement. Sinon,
        # les nouveaux travaux sont ajoutés regulièrement tous les jours.
        relworks_kpairs = Hash.new
        table_name = "unan_works_#{auteur.id}"
        whereclause = "abs_pday >= #{pday_start} AND abs_pday <= #{pday_end}"
        site.db.select(:users_tables,table_name,whereclause).each do |hwork|
          relworks_kpairs.merge!("#{hwork[:abs_pday]}-#{hwork[:abs_work_id]}" => true)
        end

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

        # On peut boucler sur toutes les données pdays pour récupérer tous les
        # identifiants de travaux de la période donnée.
        where = "id >= #{pday_start} AND id <= #{pday_end}"
        site.db.select(:unan,'absolute_pdays',where,[:id,:works]).each do |hpday|
          id_list = hpday[:works].as_id_list
          hpdays.merge!( hpday[:id] => id_list)
          abs_works_ids += id_list
        end

        # On relève les données des travaux absolus (:id, :item_id et :type_w)
        # On a aussi besoin de la durée (en jours) pour savoir si les travaux-relatifs
        # sont en dépassement d'échéance.
        habsworks = Hash.new
        site.db.select(:unan,'absolute_works',"id IN (#{abs_works_ids.join(', ')})",[:id, :item_id, :type_w, :duree])
          .each do |habswork|
          habsworks.merge!( habswork[:id] => habswork )
        end


        # On a tout ce qu'il faut maintenant pour créer les travaux relatifs dans
        # la table de l'auteur. Pour accélerer la procédure, on va le faire avec
        # une requête préparée.
        now = Time.now.to_i

        request = "INSERT INTO unan_works_#{auteur.id}"+
          " (expected_at, abs_work_id, abs_pday, item_id, options, points, created_at, updated_at,"+
          " status, program_id)" +
          " VALUES (?, ?, ?, ?, ?, 0, #{now}, #{now}, 0, #{auteur.program.id})"

        # Coefficiant durée, en fonction du rythme, pour calculer la date
        # de fin du travail attendue
        coefd = 5.0 / auteur.program.rythme

        # Il faut faire les values qui vont alimenter la requête préparée.
        array_values = Array.new
        hpdays.each do |pday_id, awork_ids|
          awork_ids.each do |awork_id|
            habswork = habsworks[awork_id]

            # Si ce travail absolu possède déjà un travail relatif, on peut
            # le passer.
            relworks_kpairs["#{pday_id}-#{awork_id}"] == nil || next

            # Calcul de la date de fin attendue. Elle dépend :
            # - de la durée du travail (absulte-work)
            # - du rythme de travail de l'auteur
            # - du jour-programme courant (program)
            # - du jour-programme du travail (pday) — qui n'est pas forcément le même que le
            #   jour-programme courant, car, pour le moment, le travail relatif peut être créé
            #   seulement lorsque l'auteur rejoint son bureau.
            #   Mais même lorsque le cronjob s'en occupera, on gardera cette procédure, pour
            #   les tests.
            duree_jours  = habswork[:duree]
            duree_real   = duree_jours.jours * coefd
            current_pday = auteur.program.current_pday
            work_pday    = pday_id
            days_ago     = current_pday - work_pday # peut-être 0, si aujourd'hui
            real_ago     = days_ago.jours * coefd
            maintenant   = Time.now.to_i
            real_depart  = maintenant - real_ago # Le timestamp du vrai départ du travail

            # On obtient finalement la date escomptée de fin du travail en fonction
            # du rythme du programme de l'auteur
            expected_at  = real_depart + duree_real

            # Les valeurs pour la requête préparée
            array_values << [expected_at, awork_id, pday_id, habswork[:item_id]||nil, options_for_work(habswork[:id])]

          end # / fin de boucle sur tous les ids abs-work du pday
        end # / fin de boucle sur tous les pdays voulus

        # Insertion de tous les travaux-relatifs qui doivent être créés.
        if array_values.count > 0
          site.db.use_database(:users_tables)
          site.db.execute(request, array_values)
        end

        # Ensuite, on doit regarder si des travaux sont en dépassement ou en
        # grand dépassement. Cf. la méthode pour le détail.
        check_depassements auteur.program

        # Si on arrive ici, c'est que tout s'est bien passé, on peut indiquer
        # dans le programme le dernier pday d'actualisation.
        opts = auteur.program.options
        opts[7..9] = pday_end.to_s.rjust(3,'0')
        auteur.program.set(options: opts)

        return true # Ne sert pas encore, pour le moment
      end


      # Méthode checkant les dépassements éventuel.
      # Un dépassement est "normal" lorsqu'il est inférieur à la durée du travail
      # et un travail est en "grand dépassement" lorsque son dépassement excède
      # sa durée.
      # Quand un travail est en dépassement, son statut (status) est passé à 3 et
      # lorsqu'il est en grand dépassement, son statut est passé à 5.
      #
      def check_depassements program
        auteur      = program.auteur
        rythme      = program.rythme
        coefduree   = 5.0 / rythme
        table_works = "unan_works_#{auteur.id}"
        
        # On commence par relever tous les travaux qui ne sont pas terminés (status=9)
        # ou en grand dépassement (status=5). Donc tous les travaux dont le statut est
        # inférieur à 5 (donc les )
        # Rappel : le status fonctionne par bit, c'est-à-dire que s'il ne contient pas
        # 1, c'est qu'il n'est pas démarré. Donc un status à 2 ou à 4 est un travail
        # en dépassement ou en grand dépassement qui n'a pas été démarré.

        # Puisque la durée en jour est inscrite dans les options du travail relatif,
        # on pourrait calculer l'opération pour ne relever que les travaux en dépassement. 
        # Ça donnerait quelque chose comme :
        # CAST(SUBSTRING(options,3,3) AS UNSIGNED)*coefduree + started_at || created_at > #{now}

        # Pour enregistrer les changements qui devront être faits
        # Chaque élément de cette liste sera une liste pour les "?" de la requête
        # préparée avec en première valeur le status, puis l'updated_at et en 
        # troisièmre valeur l'identifiant du travail relatif
        values = Array.new

        # Le temps actuel
        # Il sert pour savoir si le travail est en dépassement et pour
        # servir de valeur à l'updated_at des travaux modifiés
        now = Time.now.to_i

        whereclause = "status < 5"
        site.db.select(:users_tables,table_works,whereclause).each do |hwork|
          duree_jours = hwork[:options][2..4].to_i(10)
          real_duree_seconds  = (duree_jours * coefduree).to_i.jours

          start =
          if hwork[:started_at]
            hwork[:started_at]
          else
            # Si le travail n'a pas été démarré, le calcul de son départ
            # est plus compliqué. Il ne faut pas utiliser la valeur de `created_at`
            # car le travail a très bien pu être créé maintenant alors qu'il aurait
            # du être démarré avant. On se sert donc de la valeur de abs_pday pour
            # connaitre le jour-programme du travail et de la valeur du jour-programme
            # courant. On obtenir le nombre de jours de différence, qui, en fonction
            # du rythme, va indiquer le départ fictif du travail.
            #
            # De la même manière, le status sera 2 ou 4, pas 3 ou 5
            #
            nombre_jours = program.current_pday - hwork[:abs_pday]
            now - (nombre_jours.jours.to_f * coefduree).to_i
          end

          # La fin attendue pour le travail
          expected_end = start + real_duree_seconds
          depassement = now - expected_end

          # Si le travail n'est pas en dépassement, on peut tout de suite passer
          # au travail suivant.
          depassement <= 0 && next

          # Par exemple 0 (si non démarré), 1 (si démarré), 2 (si non démarré
          # mais déjà en dépassement), 3 (si démarré et en dépassement), 4 (si
          # non démarré et en grand dépassement), 5 (si démarré et en grand dépassement),
          # Ne peut pas être supérieur
          up = hwork[:status]

          # Le travail est en dépassement, on calcule la nouvelle valeur
          # qu'on doit donner à `status` en fonction du type de dépassement (grand
          # ou normal) et en fonction du fait que le travail est déjà commencé ou non.
          up |= depassement > real_duree_seconds ? 4 : 2

          # On ajoute ce changement
          values << [up, now, hwork[:id]]
        end #/fin de boucle sur tous les travaux relatifs retenus

        # S'il n'y a aucune valeur à changer, on peut s'en retourner tout de suite.
        values.count > 0 || return

        request = "UPDATE #{table_works} SET status = ?, updated_at = ? WHERE id = ?"
        site.db.use_database(:users_tables)
        site.db.execute(request, values)

      end



      # Retourne la valeur d'option au démarrage du travail d'id +abswork_id+
      #
      def options_for_work abswork_id
        typew = typew_awork(abswork_id)
        itype = Unan::Abswork::TYPES[typew][:itype]
        c = String.new
        c << typew.to_s.rjust(2,'0')
        c << duree_awork(abswork_id).to_s.rjust(3,'0')
        c << itype.to_s # sur un chiffre
        return c
      end
      # Retourne le type de travail du travail absolu d'identifiant +abswork_id+
      def typew_awork abswork_id
        data_awork(abswork_id)[:type_w]
      end

      # Retourne la durée en nombre de jours-programme du travail absolu
      # d'identifiant +abswork_id+
      def duree_awork abswork_id
        data_awork(abswork_id)[:duree]
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
          expected_at INTEGER(10),
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
