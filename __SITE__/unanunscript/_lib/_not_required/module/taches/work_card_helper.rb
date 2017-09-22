# encoding: UTF-8

require './lib/extensions_sup/String.html'
require_folder './lib/utils/md_to_page'

class Unan
  class Abswork


    class << self

      # Retourne le code HTML de la carte pour le travail spécifié
      #
      # Noter que ça peut être n'importe quel travail, une tâche normale
      # comme un quiz ou une page de cours à lire.
      #
      # @param {User} auteur
      #               L'auteur du travail
      # @param {Hash} hwork
      #               Table des données du travail de l'auteur, telles que
      #               relevées dans la table.
      #               habswork
      # @param {Hash} Table des données absolues du travail.
      #               Note : on pourrait les prendre ici dans la table, mais il
      #               est préférable de toutes les relever d'un seul coup et de
      #               les envoyer ici à la méthode.
      def build_card_for_auteur auteur, hwork, habswork
        carte = String.new
        carte << div_points(habswork)
        carte << "#{habswork[:titre]}".in_div(class:'titre')
        case hwork[:status]
        when 0, 2, 4
          # = Non démarré =
          # Rappel : les valeurs 2 et 4 correspondent à un travail en dépassement. Ici,
          # c'est un travail qui n'a même pas été démarré.
          carte << start_form(hwork)
        when 1, 3, 5
          # = Travail courant =
          # 3 correspond à un travail démarré en dépassement et 5 en grand
          # dépassement.
          # Note : c'est seulement lorsque le travail est démarré qu'on peut en voir
          # le détail. Pour un quiz, il s'agit du quiz lui-même.
          carte << div_echeance(auteur, hwork, habswork)
          carte << end_form(hwork)
          carte << "#{MD2Page.transpile(nil,{code: habswork[:travail], dest: nil})}".in_div(class:'travail') 
          carte << section_details_tache(habswork)  # div.details
          carte << section_exemples(habswork)       # div.exemples
          carte << section_suggestions_lectures(habswork) # div.section_suggestions_lectures
          carte << section_autres_infos(hwork, habswork)  # div.autres_infos
        when 9
          # = Travail accompli =
          # Pour un travail accompli, rien n'a besoin d'être fait.
          # TODO Mais plus tard, on pourra mettre un lien pour voir ce travail
          # dans l'historique.
        end
        return "<li class=\"work\" id=\"work-#{hwork[:id]}\" data-id=\"#{hwork[:id]}\">#{carte}</li>"
      end

      # Retourne le code HTML pour le div contenant le nombre de points
      # du travail, ou la marque "suivant résultat" pour les quiz
      #
      def div_points habswork
        points =
          case task_type
          when 'quiz' then 'suivant résultat'
          else "#{habswork[:points]} points" 
          end
        "<div class=\"nbpoints\">#{points}</div>"
      end
      # Retourne le formulaire (bouton) pour démarrer le travail d'ID +work_id+
      # Le bouton est mis en rouge si le travail est en dépassement.
      #
      def start_form hwork
        linkclass = hwork[:status] > 0 ? 'red' : nil
        'Démarrer ce travail'
          .in_a(class: linkclass, href: "unanunscript/bureau/#{task_type}?op=start_work&wid=#{hwork[:id]}")
          .in_div(class:'buttons')
      end

      # Retourne le formulaire (bouton) pour marquer le travail fini
      def end_form hwork
        linkclass = hwork[:status] > 0 ? 'red' : nil 
        'Marquer ce travail fini'
          .in_a(class: linkclass, href: "unanunscript/bureau/#{task_type}?op=done_work&wid=#{hwork[:id]}")
          .in_div(class: 'buttons')
      end

      JOURS_SEMAINE = ['dimanche', 'lundi','mardi','mercredi','jeudi','vendredi','samedi']
      MOIS = ['', 'janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre']
      # Retourne le div qui indique l'échéance du travail
      def div_echeance auteur, hwork, habswork 

        # Démarrage du travail
        # ====================
        # À présent, la propriété `expected_at` contient la date de fin attendue,
        # en fonction du rythme. Elle est calculée à la création du travail relatif,
        # donc est toujours accessible et n'a plus besoin d'être calculée.

        # Ce travail est-il en dépassement ?
        now = Time.now.to_i
        en_depassement = hwork[:expected_at] < now 

        time_fin = Time.at(hwork[:expected_at])
        dateh_jour = time_fin.day
        dateh_jour_semaine = JOURS_SEMAINE[time_fin.wday]
        dateh_mois = MOIS[time_fin.month]
        dateh_fin  = "#{dateh_jour_semaine} #{dateh_jour} #{dateh_mois}"

        mess_duree_travail =
          if en_depassement
            # Quand l'auteur est en dépassement
            retard_jours = ((now - hwork[:expected_at]).to_f/ 1.jour).floor
            s = retard_jours > 1 ? 's' : ''
            "Vous êtes en dépassement de #{retard_jours} jour#{s}".in_div(class: 'depassement')+
              "Ce travail aurait dû être terminé #{dateh_fin} dernier.".in_div
          else
            # Quand l'auteur est dans les temps
        
            # "x jours" ou "x heures"
            xjours_ou_heures = duree_as_hours_or_days(hwork[:expected_at] - now)
            if xjours_ou_heures.match(/heure/)
              mess_until = 'aujourd’hui'
              mess_eche  = "dans #{xjours_ou_heures}"
            else
              # Date humaine de la fin du travail attendue
              mess_until = "dans #{xjours_ou_heures}"
              mess_eche  = "le #{dateh_fin}"
            end
            "Ce travail doit être terminé #{mess_eche} (#{mess_until})."
          end

        return mess_duree_travail.in_div(class:'dates')
      end

      # Retourne l'objet_id de la route, plutôt que la task-type dans l'absolu.
      # Cette propriété permet d'appeler l'url correcte pour démarrer ou finir
      # le travail.
      def task_type
        @task_type ||= site.route.objet_id || TASK_TYPE
      end



      # ---------------------------------------------------------------------
      #   Propriétés au format humain
      # ---------------------------------------------------------------------

      # Type de résultat au format humain
      # Rappel : type_resultat est une donnée sur 3 bit dont chaque bit
      # de 0 à 9 définit une valeur du travail :
      # Le bit 1 (0) concerne le support (par exemple : un document)
      # Le bit 2 (1) concerne le destinataire (p.e. soi-même ou un producteur)
      # Le bit 3 (2) concerne le niveau d'exigence attendu
      def human_type_resultat habswork
        typeres = habswork[:type_resultat]
        bit_res_support   = typeres[0].to_i
        bit_res_destina   = typeres[1].to_i
        bit_res_exigence  = typeres[2].to_i

        c = String.new
        if bit_res_destina > 0
          destina   = Unan::DESTINATAIRES[bit_res_destina][1]
          c << ('destinataire : '.in_span(class:'libelle')+destina.in_span)
        end
        if bit_res_support > 0
          support   = Unan::SUPPORTS_RESULTAT[bit_res_support][1]
          c << ('support : '.in_span(class:'libelle') + support.in_span)
        end
        if bit_res_exigence > 0
          if bit_res_exigence < 10
            exigence  = Unan::NIVEAU_DEVELOPPEMENT[bit_res_exigence][1]
            c << ('développement : '.in_span(class:'libelle') + exigence.in_span)
          else
            # ERREUR
            send_error_to_admin(
              from: "Méthode `Unan::Program::AbsWork#human_type_resultat` : bit_res_exigence ne devrait pas pouvoir être > 9.",
              extra: "User : #{user.infos_unan}"
            )
          end
        end
        return c.in_div
      end

      # ---------------------------------------------------------------------
      #   Builders HTML
      # ---------------------------------------------------------------------

      # {StringHTML} Retourne un lien permettant de lire le
      # travail.
      def lien_show titre_lien = nil, attrs = nil
        titre_lien ||= self.titre
        attrs ||= Hash.new
        ktype, context, objet_id = ktype_and_context
        attrs.merge!(href: "#{ktype}/#{objet_id}/show?in=#{context}")
        titre_lien.in_a(attrs)
      end

      def ktype_and_context
        return ['work', 'unan', id] if data_type_w.nil? # c'est une erreur, mais bon
        case data_type_w[:id_list]
        when :pages then ['page_cours', 'unan', item_id]
        when :quiz  then ['quiz', 'unan', item_id]
        when :forum then ['post', 'forum', item_id]
        else # :tasks
          ['abs_work', 'unan', id]
        end
      end

      # ---------------------------------------------------------------------
      #   Méthodes d'helper pour `as_card_relative`
      # ---------------------------------------------------------------------

      # Retourne la section DIV contenant les suggestions de
      # lecture (pages cours) s'il y en a
      def section_suggestions_lectures habswork
        habswork[:pages_cours_ids] != nil || (return '')
        pages_ids = habswork[:pages_cours_ids].as_list_ids
        # On doit charger les titres des pages pour les afficher
        hpagescours = Hash.new
        site.db.select(
          :unan,
          'pages_cours',
          "id IN (#{pages_ids.join(',')})",
          [:titre]
        ).each{|hpage| hpagescours.merge! hp[:id] => hp }
        # On fait la liste des pages (titres)
        listepages =
          pages_ids.collect do |pcid|
            titre = hpagescours[pcid][:titre]
            "– #{titre}".in_a(href:"unanunscript/pages_cours/#{pcid}", target: '_blank').in_div
          end.join

        s = pages_ids.count > 1 ? 's' : ''
        (
          "Suggestion#{s} de lecture#{s} : ".in_span(class:'libelle') +
          listepages
        ).in_div(class:'section_suggestions_lectures')
      end

      # Un lien pour soit marquer le travail démarré (s'il n'a pas encore été
      # démarré) soit pour le marquer fini (s'il a été fini). Dans les deux cas,
      # c'est un lien normal qui exécute une action avant de revenir ici.
      #
      # +started+ permet d'appeler la méthode lorsque c'est un travail
      # qui n'est pas démarré.
      # TODO Il faudra de toute façon repenser les choses ici puisqu'il est
      # absurde de parler de travail relatif lorsque c'est un travail qui
      # n'est pas démarré (et qui, donc, par définition, ne peut pas posséder
      # de travail relatif de l'auteur)
      def form_pour_marquer_started_or_fini started = true
        completed, started, this_pday =
          if started == false
            [false, false, self.pday]
            #  Note : self.pday a dû être défini à l'instanciation
          else
            [rwork.completed?, rwork.started?, rwork.indice_pday]
          end
        return '' if completed
        # this_pday != nil || raise('Le jour-programme ne devrait pas être nil (dans form_pour_marquer_started_or_fini)')
        if started
          'Marquer ce travail fini'.in_a(href:"work/#{rwork.id}/complete?in=unan/program&cong=taches")
        else
          'Démarrer ce travail'.in_a(class:'warning',href:"work/#{id}/start?in=unan/program&cong=taches&wpday=#{this_pday}")
        end.in_div(class:'buttons')
      end

      # Les détails de la tâche
      #
      def section_details_tache habswork
        (
          div_type_tache(habswork) +
          div_resultat(habswork)
        ).in_div(class:'section_details')
      end

      # Retourne la section contenant les exemples s'ils existent
      def section_exemples habswork
        habswork[:exemples] != nil || (return '')
        habswork[:exemples].as_list_ids.collect do |eid|
          "Exemple ##{eid}".in_a(href:"unanunscript/exemples/#{eid}", target:'_exemple_work_').in_span
        end.join.in_div(class:'section_exemples')
      end

      def div_type_tache habswork
        typeh_w = Unan::Abswork::TYPES[habswork[:type_w]][:hname]
        ('Type du travail : '.in_span(class:'libelle') + typeh_w.in_span).in_div(class: 'petit_air_autour')
      end

      # Le résultat attendu, c'est-à-dire ce que l'auteur doit produire au cours
      # de ce travail.
      def div_resultat habswork
        res = habswork[:resultat].nil_if_empty
        res != nil || (return '')
        c = String.new
        c << 'Résultat attendu'.in_span(class:'libelle')
        c << res.in_div(class: 'petit_air_autour retrait4')
        c << human_type_resultat(habswork)
        return c.in_div(class:'retrait4 cadre', style:'margin-bottom:4em')
      end

      # Retourne le DIV avec les liens vers des pages-cours s'il y
      # en a qui sont spécifiées.
      # Noter que ces pages ne sont pas les pages obligatoires pour
      # suivre le programme (celles qui sont en elles-mêmes des works)
      # mais les pages suggérées, souvent des pages Narration, en
      # rapport avec le travail courant.
      def div_pages_cours
        return '' if pages_cours_ids.empty?
        (
          'Suggestions de lecture : '.in_span(class:'libelle') +
          pages_cours_ids.collect do |pcid|
            pagec = Unan::Program::PageCours.get(pcid)
            pagec.titre.in_a(href:"page_cours/#{pcid}/show?in=unan").in_li
          end.join.in_ul
        ).in_span(class:'info block')
      end

      # +from+ Cf. l'explicaiton dans la méthode principale `as_card`
      def section_autres_infos hwork, habswork
        type = habswork[:type]
        points = habswork[:points]
        main_target_id   = type[2].to_i
        sub_target_id    = type[3].to_i
        hash_target = Unan.sujet_cible_of(type[2].to_i, type[3].to_i)

        narrative_target = "#{hash_target[:main_name]} #{hash_target[:hname]}"
        type_projet      = Unan::PROJET_TYPES[type[4].to_i][:hname]

        first_infos = [
          ['type projet', type_projet,        nil],
          ['sujet',        narrative_target,   nil],
          ['points',       points,             nil]
        ].collect do |libelle, valeur, unite|
          "#{libelle} : ".in_span(class:'libelle') + "#{valeur}"
        end.compact.join

        (
          first_infos +
          infos_durees_travail(hwork)
        ).in_div(class:'section_autres_infos')
      end


      # Prend un durée en secondes et retourne un texte humain en jours
      # ou en heures, comme "2 jours" ou "5 heures" 
      def duree_as_hours_or_days duree
        duree_hrs = duree / 3600
        if duree_hrs > 24
          # Durée à exprimer en jours
          duree_jrs = duree_hrs / 24
          s = duree_jrs == 1 ? '' : 's'
          "#{duree_jrs} jour#{s}"
        else
          # Durée exprimée en heures
          s = duree_hrs == 1 ? '' : 's'
          "#{duree_hrs} heure#{s}"
        end
      end

      # Renvoie des informations sur la durée, à savoir la durée totale pour
      # réaliser le travail, la durée déjà utilisée et la durée restante, si le
      # travail n'est pas en dépassement.
      def infos_durees_travail hwork
        hwork[:status] & 1 > 0 || (return '')

        pars = Array.new
        now = Time.now.to_i
        
        overtaken = hwork[:status] & (2|4) > 0

        if overtaken
          pars << ['duree restante', "<span class='red'>0 heures et 0 jours</span>"]
        else
          duree_totale = duree_as_hours_or_days(hwork[:expected_at] - hwork[:created_at])
          duree_worked = duree_as_hours_or_days(now - hwork[:started_at])
          duree_rested = duree_as_hours_or_days(hwork[:expected_at] - now)

          pars << ['durée totale', duree_totale]
          pars << ['durée travaillée', duree_worked]
          pars << ['durée restante', duree_rested]
        end

        pars.collect do |libelle, valeur|
          "#{libelle} : ".in_span(class:'libelle') + "#{valeur}"
        end.join
      end
      def buttons_edit
        user.admin? || (return '')
        (
          "[Edit Work##{id}]".in_a(href: "abs_work/#{id}/edit?in=unan_admin")
        ).in_div(class:'right tiny')
      end

    end #/<< self
  end #/AbsWork
end #/Unan
