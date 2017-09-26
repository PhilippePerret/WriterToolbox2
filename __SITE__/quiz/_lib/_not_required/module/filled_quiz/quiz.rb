# encoding: utf-8
class Quiz
  
  # --------------------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # --------------------------------------------------------------------------------

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
