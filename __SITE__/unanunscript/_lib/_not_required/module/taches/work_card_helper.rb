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
          carte << "#{MD2Page.transpile(nil,{code: habswork[:travail], dest: nil})}".in_div(class:'travail') 
          # carte << section_details_tache(habswork)  # div.details
          carte << ("Résultat attendu : ".in_span(class: 'libelle') + human_values['résultat attendu']).in_div(class: 'section_resultat_attendu')
          carte << section_exemples(habswork)       # div.exemples
          carte << section_suggestions_lectures(habswork) # div.section_suggestions_lectures
          carte << section_autres_infos(human_values) 
        when 9
          #
          # = Travail accompli =
          #
          # Pour un travail accompli, rien n'a besoin d'être fait.
          # TODO Mais plus tard, on pourra mettre un lien pour voir ce travail
          # dans l'historique.
        end
        return "<li class=\"work\" id=\"work-#{hwork[:id]}\" data-id=\"#{hwork[:id]}\">#{carte}</li>"
      end


      # Retourne le div des autres infos
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
      def div_points habswork
        points =
          case task_type
          when 'quiz' then 'suivant résultat'
          else "#{habswork[:points]} points" 
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
        'Marquer ce travail fini'.in_a(
            href: "unanunscript/bureau/#{task_type}?op=done_work&wid=#{hwork[:id]}"
        )
          #.in_div(class: 'buttons')
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

      # Retourne l'objet_id de la route, plutôt que la task-type dans l'absolu.
      # Cette propriété permet d'appeler l'url correcte pour démarrer ou finir
      # le travail.
      def task_type
        @task_type ||= site.route.objet_id || TASK_TYPE
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


      # Type de résultat au format humain
      # Rappel : type_resultat est une donnée sur 3 bit dont chaque bit
      # de 0 à 9 définit une valeur du travail :
      # Le bit 1 (0) concerne le support (par exemple : un document)
      # Le bit 2 (1) concerne le destinataire (p.e. soi-même ou un producteur)
      # Le bit 3 (2) concerne le niveau d'exigence attendu
      def human_type_resultat habswork
        return 'human type resultat'
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

        debug "hpagescours = #{hpagescours.inspect}"
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

      # Retourne la section contenant les exemples s'ils existent
      def section_exemples habswork
        habswork[:exemples] != nil || (return '')
        habswork[:exemples].as_id_list.collect do |eid|
          "Exemple ##{eid}".in_a(href:"unanunscript/exemples/#{eid}", target:'_exemple_work_').in_span
        end.join.in_div(class:'section_exemples')
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
