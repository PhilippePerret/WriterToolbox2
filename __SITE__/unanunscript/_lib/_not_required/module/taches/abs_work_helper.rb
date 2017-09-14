# encoding: UTF-8

require './lib/extensions_sup/String.html'
require_folder './lib/utils/md_to_page'

class Unan
  class Abswork


    class << self

      # Retourne le code HTML de la carte pour le travail spécifié
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

        carte << "<div class=\"nbpoints\">#{habswork[:points]} points</div>"
        carte << "#{habswork[:titre]}".in_div(class:'titre')
        case hwork[:status]
        when 0 # not started
          carte << start_form(hwork)
        when 1 # current
          carte << div_echeance(auteur, hwork, habswork)
          carte << end_form(hwork[:id])
        when 9 # done
        end
        carte << "#{MD2Page.transpile(nil,{code: habswork[:travail], dest: nil})}".in_div(class:'travail') 
        # carte << details_tache
        # carte << section_exemples
        # carte << suggestions_lectures
        return "<li class=\"work\" id=\"work-#{habswork[:id]}\">#{carte}</li>"
      end

      # Retourne le formulaire (bouton) pour démarrer le travail d'ID +work_id+
      # Le bouton est mis en rouge si ce travail aurait dû être démarré depuis
      # plus de trois jours programme.
      # TODO Dans l'idéal, il faudrait tenir compte du rythme du programme (mais alors,
      # il faudrait envoyer plus de données ou utiliser une instance — ce que je vais
      # bien finir par refaire…)
      def start_form hwork
        linkclass = (Time.now.to_i - hwork[:created_at] > 5.jours) ? 'red' : ''
        'Démarrer ce travail'
          .in_a(class: linkclass, href: "unanunscript/bureau/taches?op=start_work&wid=#{hwork[:id]}")
          .in_div(class:'buttons')
      end

      # Retourne le formulaire (bouton) pour marquer le travail fini
      def end_form work_id
        'Marquer ce travail fini'
          .in_a(href: "unanunscript/bureau/taches?op=done_work&wid=#{work_id}")
          .in_div(class: 'buttons')
      end

      # Retourne le div qui indique l'échéance du travail
      def div_echeance auteur, hwork, habswork 

        # Démarrage du travail
        # Attention : le travail peut ne pas avoir été démarré, dans lequel cas
        # il n'a pas de valeur pour started_at. Mais normalement, un travail non
        # démarré ne peut pas passer par ici
        coef_duree = 5.0 / auteur.program.rythme
        work_start_time  = hwork[:started_at]
        work_expected_at = (work_start_time + habswork[:duree].jours)/coef_duree
        date_fin = Time.at(work_expected_at).strftime('%d %m')

        # Ce travail est-il en dépassement ?
        en_depassement = work_expected_at < Time.now.to_i
        mess_duree_travail =
          if en_depassement
            # Quand l'auteur est en dépassement
            duree_depassement = Time.now.to_i - work_expected_at
            retard_jours = (duree_depassement / 1.jour).round
            x = retard_jours > 1 ? 's' : ''
            "Vous êtes en dépassement de #{retard_jours} jour#{s}".in_div(class: 'depassement')+
              "Ce travail aurait dû être accompli le #{date_fin}.".in_div
          else
            # Quand l'auteur est dans les temps
            dans_x_jours = ((work_expected_at - Time.now.to_i)/1.jour).round
            s = dans_x_jours > 1 ? 's' : ''
            "Ce travail doit être accompli le #{date_fin} (dans #{dans_x_jours} jour#{s})"
          end

        return mess_duree_travail.in_div(class:'dates')
      end

    end #/<< self

    # ---------------------------------------------------------------------
  #   Propriétés au format humain
  # ---------------------------------------------------------------------

  def human_type_w
    @human_type_w ||= data_type_w[:hname]
  end

  def human_narrative_target
    @human_narrative_target ||= Unan::SujetCible.new(narrative_target).human_name
  end

  # Type de résultat au format humain
  # Rappel : type_resultat est une donnée sur 3 bit dont chaque bit
  # de 0 à 9 définit une valeur du travail :
  # Le bit 1 (0) concerne le support (par exemple : un document)
  # Le bit 2 (1) concerne le destinataire (p.e. soi-même ou un producteur)
  # Le bit 3 (2) concerne le niveau d'exigence attendu
  def human_type_resultat
    bit_res_support   = type_resultat[0].to_i
    bit_res_destina   = type_resultat[1].to_i
    bit_res_exigence  = type_resultat[2].to_i

    c = String.new
    if bit_res_destina > 0
      destina   = Unan::DESTINATAIRES[bit_res_destina][1]
      c << ('destinataire : '.in_span(class:'libelle')+destina.in_span).in_span
    end
    if bit_res_support > 0
      support   = Unan::SUPPORTS_RESULTAT[bit_res_support][1]
      c << ('support : '.in_span(class:'libelle') + support.in_span).in_span
    end
    if bit_res_exigence > 0
      if bit_res_exigence < 10
        exigence  = Unan::NIVEAU_DEVELOPPEMENT[bit_res_exigence][1]
        c << ('développement : '.in_span(class:'libelle') + exigence.in_span).in_span
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
  def suggestions_lectures
    return '' if pages_cours_ids.empty?
    where = "id IN (#{pages_cours_ids.join(',')})"
    hpagescours = Hash.new
    Unan.table_pages_cours.select(where: where, colonnes:[:titre]).each do |hpage|
      hpagescours.merge! hpage[:id] => hpage
    end
    listepages =
      pages_cours_ids.collect do |pcid|
        titre = hpagescours[pcid][:titre]
        "#{DOIGT}#{titre}".in_a(href:"page_cours/#{pcid}/show?in=unan")
      end.pretty_join.in_span

    s = pages_cours_ids.count > 1 ? 's' : ''
    (
      "Suggestion#{s} de lecture#{s} : ".in_span(class:'libelle') +
      listepages
    ).in_div(class:'suggestions_lectures')
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
  def details_tache
    return '' if rwork.completed?
    (
      div_type_tache +
      div_resultat
    ).in_div(class:'details')
  end

  # Retourne la section contenant les exemples s'ils existent
  def section_exemples
    return '' if exemples.empty?
    exemples_ids.collect do |eid|
      "Exemple ##{eid}".in_a(href:"exemple/#{eid}/show?in=unan", target:'_exemple_work_').in_span
    end.join.in_div(class:'exemples')
  end

  def div_type_tache
    ('Type : '.in_span(class:'libelle') + human_type_w.in_span).in_div(class: 'petit_air_autour')
  end
  def div_resultat
    # Pour gérer l'erreur quand resultat est false et qu'il ne
    # connait donc pas la méthode empty?
    if resultat === false
      send_error_to_admin(
        exception:  "`resultat` est false dans Unan::Program::AbsWork#div_resultat",
        extra:      "AbsWork ID : #{id.inspect} / work ID : #{rwork.id.inspect}",
        from:       "#{__FILE__}:#{__LINE__}"
      ) rescue nil
      return ''
    end
    return '' if resultat.empty?
    c = String.new
    c << 'Résultat attendu'.in_span(class:'libelle')
    c << resultat.in_div(class:'petit_air_autour retrait4')
    c << human_type_resultat
    return c.in_div(class:'retrait4 cadre', style:'margin-bottom:4em')
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper pour `as_card`
  # ---------------------------------------------------------------------

  # ATTENTION !!! Cette méthode ne sert absolument pas à afficher
  # la carte pour l'auteur UNAN. Elle sert pour l'administration.
  # Pour voir la carte affichée pour l'auteur, voir la méthode
  # `as_card_relative`
  #
  def div_travail
    item_link = if item_id
      chose, human_chose = case true
      when page_cours?  then ['page_cours', 'la page de cours']
      when quiz?        then ['quiz', 'le questionnaire']
      when forum?       then ['forum', 'le message forum']
      else ['task', 'tâche']
      end
      " (voir #{human_chose} ##{item_id})".in_a(href:"#{chose}/#{item_id}/show?in=unan", target:"_show_#{chose}_")
    else
      ''
    end

    (
      travail_formated.in_div(class:'travail') +
      item_link                       +
      div_exemples    +
      div_pages_cours
    ).in_div(class:'details')
  end

  def travail_formated
    @travail_formated ||= travail.formate_balises_propres
  end

  # Retourne le code HTML pour le div contenant les exemples,
  # à placer dans la carte du work. Chaque exemple est un lien
  # permettant de l'afficher.
  def div_exemples
    return '' if exemples_ids.empty?

    (
      'Exemples :'.in_span(class:'libelle') +
      exemples_ids.collect do |exid|
        "Exemple ##{exid}".in_a(href:"exemple/#{exid}/show?in=unan")
      end.pretty_join
    ).in_span(class:'info block')
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
  def autres_infos_travail from = nil
    s_duree = duree > 1 ? "s" : ""
    first_infos = [
      ['type projet', type_projet[:hname],      nil],
      ['sujet',       human_narrative_target,   nil],
      ['points',      points,                   nil]
    ].collect do |libelle, valeur, unite|
      ("#{libelle} :".in_span(class:'libelle') + "#{valeur}#{unite}").in_span(class:'info')
    end.compact.join

    (
      first_infos +
      infos_durees_travail(from)
    ).in_div(class:'autres_infos')
  end
  # +from+ Cf. l'explication dans la méthode principale `as_card`
  def infos_durees_travail from = nil
    pars = Array.new
    s_duree = duree > 1 ? 's' : ''
    if user.program && user.program.rythme != 5
      duree_reelle = user.program.pduree2rduree(duree)
      pars << ['durée', duree, "&nbsp;jr#{s_duree}-programme"]
      pars << ['durée réelle', duree_reelle]
    else
      pars << ['durée', duree, "&nbsp;jour#{s_duree}"]
    end
    from.nil? || begin
      pars << ['pdays travaillés', from ]
      pars << ['pdays restant', duree - from]
    end
    pars.collect do |libelle, valeur, unite|
      ("#{libelle} : ".in_span(class:'libelle') + "#{valeur}#{unite || ''}").in_span(class:'info')
    end.join
  end
  def buttons_edit
    user.admin? || (return '')
    (
      "[Edit Work##{id}]".in_a(href: "abs_work/#{id}/edit?in=unan_admin")
    ).in_div(class:'right tiny')
  end

end #/AbsWork
end #/Unan
