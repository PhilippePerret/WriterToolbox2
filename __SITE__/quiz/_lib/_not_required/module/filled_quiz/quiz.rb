# encoding: utf-8
class Quiz
  
  # --------------------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # --------------------------------------------------------------------------------


  # Retourne le code HTML de la note finale, si le résultat existe
  #
  # Note : c'est la version de la méthode quand des résultats existent,
  # et qu'ils sont évalués (rappel : ils ne sont pas évalués lorsque le
  # formulaire a été rempli de façon incomplète)
  def bloc_note_finale
    resultats[:not_evaluated] && (return '')
    nfinale = resultats[:note_finale]
    class_encart =
      if nfinale < 80
        'bad'
      elsif nfinale < 120
        'med'
      else
        'bon'
      end
    (
      resultats[:date].in_span(class: 'date') +
      "#{resultats[:note_finale].to_f/10} / 20".sub(/\.0/,'').sub(/\./,',').in_span(class: 'note_finale')+
      ("Points : #{resultats[:total_points]} / #{resultats[:total_points_max]}").in_span(class:'points')
    ).in_div(class: "encart_note_finale #{class_encart}quiz").in_div(class: 'quiz_header')
    
  end

  # Le menu des quiz déjà soumis, si c'est un quiz réutilisable et que
  # l'owner courant, identifié, l'a soumis plusieurs fois
  #
  def menu_old_owner_resultats
    reusable? || (return '') 
    owner.id != nil || (return '')
    begin
      # On met dans un test car la table de l'user n'existe pas forcément
      quizes = site.db.select(:users_tables,"quiz_#{owner.id}",{quiz_id: id})
    rescue Mysql2::Error => e
      return ''
    end
    quizes.count > 1 || (return '')
    # Si l'on arrive jusqu'ici, c'est que l'user courant a déjà réaliser plusieurs
    # évaluations enregistrées du quiz courant, et qu'il faut donc lui préparer
    # un menu pour en revoir.
    select_id = "all_owner_resultats-#{owner.id}"
    "<select id=\"#{select_id}\" class=\"all_owner_resultats\">"+
    quizes.collect do |hresultats|
      "<option value=\"#{hresultats[:id]}\">Réponses du #{hresultats[:date]}</option>"
    end.join('') +
    '</select>'+
    '<button class="btn small" onclick="this.form.operation.value=\'revoir\';this.form.submit()">Revoir</button>'
  end
  # Les méthodes qui vont permettre de régler les valeurs du questionnaire

  # Renvoie la class pour le DIV de la question d'identifiant +question_id+
  #
  # Peut avoir trois valeurs différentes :
  # - la question n'a pas été répondue        => ''
  # - la question a été correctement répondue => 'bon'
  # - la question n'a pas reçue une réponse correcte => 'bad'
  # - la question a été oubliée                      => 'unanswered'
  # On ajoute aussi toujours 'question' au div
  #
  def class_question question_id
    c = ['question']
    
    # Si on ne doit pas afficher les résultats bon/mauvais, on ne fait rien.
    # Cela arrive par exemple lorsque le quiz n'a pas été rempli entièrement
    if resultats[:not_evaluated]
      if false == resultats[:reponses].key?(question_id)
        c << 'unanswered'
      end
    else
      hrep = resultats[:reponses][question_id]
      c << (hrep[:points] == hrep[:points_max] ? 'bon' : 'bad')
    end

    return c.join(' ')
  end

  # Renvoie la class pour le LI de la réponse d'index +index_reponse+ pour la
  # question d'identifiant +question_id+
  #
  # Peut avoir 3 valeurs différentes :
  # 
  # - la question n'a pas été répondue                => ''
  # - C'est une réponse choisie, mais elle est fausse => 'badchoix'
  # - C'est une réponse choisie, et est elle bonne    => 'bonchoix'
  # - Ça n'est pas une réponse choisie                => ''
  def class_li_reponse question_id, index_reponse
    if resultats[:not_evaluated]
      ''
    else
      hrep = resultats[:reponses][question_id]
      is_owner_choix = hrep[:choix].include?(index_reponse)
      is_bon_choix   = hrep[:bons_choix].include?(index_reponse)
      if is_owner_choix && is_bon_choix
        'bonchoix'
      elsif is_owner_choix && !is_bon_choix
        'badchoix'
      elsif is_bon_choix && !is_owner_choix
        'bonchoixmissing'
      elsif !is_bon_choix && !is_owner_choix 
        ''
      end
    end
  end

  # Renvoie '' ou 'checked=CHECKED' pour indiquer que la réponse d'index
  # +index_reponse+ de la question d'identifiant +question_id+ a été cochée/choisie
  # lors du remplissage du questionnaire.
  #
  def code_checked question_id, index_reponse
    ck = resultats[:reponses][question_id] && resultats[:reponses][question_id][:choix].include?(index_reponse)
    ck ? ' checked="CHECKED"' : ''
  end
end #/Quiz
