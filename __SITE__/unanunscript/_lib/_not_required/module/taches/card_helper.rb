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
      # 
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
        carte << div_points(hwork)
        carte << "#{habswork[:titre]}".in_div(class:'titre')
        case hwork[:status]
        when 0, 2, 4
          #
          # = Non démarré =
          #
          # Rappel : les valeurs 2 et 4 correspondent à un travail en dépassement. Ici,
          # c'est un travail qui n'a même pas été démarré.
          carte << start_form(hwork)
        when 1, 3, 5
          #
          # = Travail courant =
          #
          # 3 correspond à un travail démarré en dépassement et 5 en grand
          # dépassement.
          # Note : c'est seulement lorsque le travail est démarré qu'on peut en voir
          # le détail. Pour un quiz, il s'agit du quiz lui-même.

          # Toutes les valeurs humaines. C'est une table qui contient en clé le
          # libellé (à mettre dans un span libelle) et en valeur la valeur humaine, telle qu'elle
          # doit être affichée
          human_values = define_all_human_values(habswork, hwork) 

          carte << div_echeance(auteur, hwork, habswork)
          carte << section_travail(hwork, habswork) 
          carte << section_resultat_attendu(human_values)
          carte << section_exemples(habswork)       # div.exemples
          carte << section_suggestions_lectures(habswork) # div.section_suggestions_lectures
          carte << section_autres_infos(human_values) 
        when 9
          #
          # = Travail accompli =
          #
          # Pour un travail accompli, rien n'a besoin d'être fait.
          carte << lien_revoir_ce_travail(hwork)
        end
        return "<li class=\"work\" id=\"work-#{hwork[:id]}\" data-id=\"#{hwork[:id]}\">#{carte}</li>"
      end


      
      # Retourne l'objet_id de la route, plutôt que la task-type dans l'absolu.
      # Cette propriété permet d'appeler l'url correcte pour démarrer ou finir
      # le travail.
      def task_type
        @task_type ||= site.route.objet_id || TASK_TYPE
      end

      # Retourne le nombre 1 à 4 (parfois 0) qui correspond à l'itype de la
      # tâche : 
      # 1 = :task
      # 2 = page de cours soit narration soit unan
      # 3 = quiz
      # 4 = forum
      def itype hwork
        hwork[:options][5].to_i
      end

      # Renvoie la section de travail
      # Elle varie en fonction du type de la tâche et peut nécessiter, comme pour
      # les quiz, de requérir un autre module.
      def section_travail hwork, habswork
        case itype(hwork)
        when 1 # task
          "#{MD2Page.transpile(nil,{code: habswork[:travail], dest: nil})}".in_div(class:'section_travail') 
        when 2 # page
          page_narration_id = hwork[:options][9..12].to_i(10)
          is_page_narration = page_narration_id > 0
          lien_vers_page =
            if is_page_narration
              href = "narration/page/#{page_narration_id}"
              "Lire la page dans la collection Narration".in_a(href: href)
            else
              href = "unanunscript/page_cours/#{hwork[:item_id]}?wid=#{hwork[:id]}"
              "Lire cette page du programme".in_a(href: href)
            end
          lien_vers_page.in_div(class: 'section_travail')
        when 3 # quiz
          "Procéder au quiz “#{habswork[:titre]}”"
            .in_a(id: "lk_work-#{hwork[:id]}", href: "quiz/#{hwork[:item_id]}?wid=#{hwork[:id]}")
            .in_div(class: 'section_travail')
        when 4 # forum
          ''
        else
          ''
        end
      end


      # Le résultat attendu, littéralement et humainement.
      #
      def section_resultat_attendu human_values
        res = human_values['résultat attendu']
        res != nil || (return '')
        ("Résultat attendu : ".in_span(class: 'libelle') + res.in_div(class: 'contents'))
            .in_div(class: 'section_resultat_attendu infos_sup')
      end


      # Retourne le div des autres infos
      # C'est, pour le moment, la ligne inférieure des fiches travaux, qui reprend l'intégralité
      # des informations.
      def section_autres_infos human_values
        autres_infos =
          [
            'type du travail', 'destinataire', 'support', 'développement'
        ].collect do |key|
          human_values[key] || next
          ("#{key} ".in_span(class: 'libelle') + human_values[key])
        end.compact.join('')

        autres_infos +=
          ['type de projet', 'cible travail', 'points'
        ].collect do |key|
          human_values[key] || next
          ("#{key} ".in_span(class: 'libelle') + human_values[key])
        end.compact.join('')

        autres_infos.in_div(class: 'section_autres_infos')
      end

      # Retourne le code HTML pour le div contenant le nombre de points
      # du travail, ou la marque "suivant résultat" pour les quiz
      #
      def div_points hwork
        points =
          case task_type
          when 'quiz' then 
            # Pour un quiz, l'indication du nombre de points varie
            # suivant le fait que c'est un travail achevé ou non. Si c'est
            # un travail achevé, on connait déjà le nombre de points qu'à
            # gagné l'auteur, donc on peut l'afficher. Dans le cas contraire, si
            # c'est un quiz courant, on indique simplement 'suivant résultat'
            if hwork[:status] == 9
              "#{hwork[:points]} points"
            else
              'suivant résultat'
            end
          else
            "#{hwork[:points]} points" 
          end
        "<div class=\"nbpoints\">#{points}</div>"
      end


      # Méthode pratique 
      # Renvoie true si le travail +hwork+ est en dépassement
      def overtaken? hwork
        return hwork[:status] & (2|4) > 0
      end

      # Retourne le formulaire (bouton) pour démarrer le travail d'ID +work_id+
      # Le bouton est mis en rouge si le travail est en dépassement.
      #
      def start_form hwork
        linkclass = overtaken?(hwork) ? 'red' : nil
        'Démarrer ce travail'
          .in_a(class: linkclass, href: "unanunscript/bureau/#{task_type}?op=start_work&wid=#{hwork[:id]}")
          .in_div(class:'buttons')
      end

      # Retourne le formulaire (bouton) pour marquer le travail fini
      def end_form hwork
        nom_bouton = 
          case itype(hwork)
          when 1
            'Marquer ce travail fini'
          when 2
            'Marquer cette page lue'
          else
            'Marquer ce travail fini'
          end
        nom_bouton.in_a(href: "unanunscript/bureau/#{task_type}?op=done_work&wid=#{hwork[:id]}")
      end

      # Retourne le bouton dans son div pour revoir le travail achevé
      def lien_revoir_ce_travail hwork
        case itype(hwork)
        when 1 then 'Revoir ce travail'
        when 2 then 'Relire cette page'
        when 3 then 'Revoir ce quiz'
        else 'Revoir ce travail'
        end.in_a(
          href: "unanunscript/history/#{hwork[:id]}"
        ).in_div(class: 'buttons')
      end

      JOURS_SEMAINE = ['dimanche', 'lundi','mardi','mercredi','jeudi','vendredi','samedi']
      MOIS = ['', 'janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre']


      # Retourne le div contenant :
      #   - l'indication de l'échéance (passée ou future)
      #   - le temps restant ou dépassé
      #   - le bouton pour marquer le travail fini
      #
      # Note : ce div remplace le div qui contenait seulement le bouton 
      # pour marquer le travail fini.
      #
      def div_echeance auteur, hwork, habswork 

        now = Time.now.to_i

        # Ce travail est-il en dépassement ?
        depassement = overtaken?(hwork)

        time_fin = Time.at(hwork[:expected_at])
        dateh_jour = time_fin.day
        dateh_jour_semaine = JOURS_SEMAINE[time_fin.wday]
        dateh_mois = MOIS[time_fin.month]
        dateh_fin  = "#{dateh_jour_semaine} #{dateh_jour} #{dateh_mois}"

        if depassement
          # Quand l'auteur est en dépassement
          retard_jours = ((now - hwork[:expected_at]).to_f/ 1.jour).floor
          s = retard_jours > 1 ? 's' : ''
          depash = "Vous êtes en dépassement de #{retard_jours} jour#{s}".in_div(class: 'depassement')
          resteh = ''
          echeah = "Ce travail aurait dû être terminé #{dateh_fin} dernier."
        else
          # Quand l'auteur est dans les temps
          # On écrit juste un texte précisant la date précise de fin
          # et un cadre indiquant clairement le nombre de jours ou
          # d'heures restantes.

          xjours_ou_heures = duree_as_hours_or_days(hwork[:expected_at] - now)
          depash = ''
          resteh = "#{'dans'.in_span(class: 'tiny')} #{xjours_ou_heures}".in_div(class: 'reste')
          echeah = "Ce travail doit être terminé le #{dateh_fin}."
        end

        (
          depash +
          end_form(hwork) +
          resteh +
          echeah.in_div(class: 'echeh') +
          '<div style="clear:both"></div>'
        ).in_div(class: "dates#{depassement ? ' overtaken' : ''}")

      end


      # ---------------------------------------------------------------------
      #   Propriétés au format humain
      # ---------------------------------------------------------------------

      def define_all_human_values habswork, hwork
        
        # La table qui sera retournée
        h = Hash.new

        # Le résultat attendu, littéraire
        h.merge!('résultat attendu' => habswork[:resultat])

        typeres = habswork[:type_resultat]
        bit_res_support   = typeres[0].to_i
        bit_res_destina   = typeres[1].to_i
        bit_res_exigence  = typeres[2].to_i

        if bit_res_destina > 0
          h.merge!('destinataire' => Unan::DESTINATAIRES[bit_res_destina][1])
        end
        if bit_res_support > 0
          h.merge!('support' => Unan::SUPPORTS_RESULTAT[bit_res_support][1])
        end
        if bit_res_exigence > 0
          h.merge!('développement' => Unan::NIVEAU_DEVELOPPEMENT[bit_res_exigence][1])
        end

        h.merge!('type du travail' => Unan::Abswork::TYPES[habswork[:type_w]][:hname])

        type = habswork[:type]
        main_target_id   = type[2].to_i
        sub_target_id    = type[3].to_i
        hash_target = Unan.sujet_cible_of(type[2].to_i, type[3].to_i)

        narrative_target = "#{hash_target[:main_name]} #{hash_target[:hname]}"
        type_projet      = Unan::PROJET_TYPES[type[4].to_i][:hname]

        h.merge!('type de projet' => type_projet)
        h.merge!('cible travail' => narrative_target)
        h.merge!('points' => "#{habswork[:points]}")

        return h
      end


      # Retourne la section DIV contenant les suggestions de
      # lecture (pages cours) s'il y en a
      def section_suggestions_lectures habswork
        habswork[:pages_cours_ids] != nil || (return '')
        pages_ids = habswork[:pages_cours_ids].as_id_list
        # On doit charger les titres des pages pour les afficher
        hpagescours = Hash.new
        site.db.select(
          :unan,
          'pages_cours',
          "id IN (#{pages_ids.join(',')})",
          [:id, :titre]
        ).each{|hp| hpagescours.merge! hp[:id] => hp }

        # On fait la liste des pages (titres)
        listepages =
          pages_ids.collect do |pcid|
            titre = hpagescours[pcid][:titre]
            "#{titre}".in_a(href:"unanunscript/pages_cours/#{pcid}", target: '_blank').in_li
          end.join.in_ul(class: 'suggestions_lectures')

        s = pages_ids.count > 1 ? 's' : ''
        (
          "Suggestion#{s} de lecture#{s} : ".in_span(class:'libelle') +
          listepages.in_div(class: 'contents')
        ).in_div(class:'section_suggestions_lectures infos_sup')
      end

      # Retourne la section contenant les exemples s'ils existent
      def section_exemples habswork
        habswork[:exemples] != nil || (return '')
        (
          'Exemples'.in_span(class: 'libelle') +
          habswork[:exemples].as_id_list.collect do |eid|
            "Exemple n°#{eid}".in_a(href:"unanunscript/exemples/#{eid}", target:'_exemple_work_').in_span
          end.join.in_div(class: 'contents')
        ).in_div(class:'section_exemples infos_sup')
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
        
        if overtaken?(hwork)
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
