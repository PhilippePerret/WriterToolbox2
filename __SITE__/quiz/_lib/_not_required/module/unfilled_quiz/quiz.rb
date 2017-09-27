# encoding: utf-8
class Quiz
  # --------------------------------------------------------------------------------
  #
  #   CLASSE
  #
  # --------------------------------------------------------------------------------

  class << self

    # Retourne l'instance Quiz du quiz pour le visiteur courant
    def [] quiz_id
      @allquiz ||= Hash.new
      @allquiz[quiz_id] ||= Quiz.new(quiz_id, user.id)
      @allquiz[quiz_id]
    end

  end #/<< self
  
  # --------------------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # --------------------------------------------------------------------------------

  # Retourne le code HTML pour le bloc de note finale.
  # S'il n'y a pas de résultat (rappel : ce module est chargé quand c'est
  # le cas) alors il n'y a pas de bloc
  def bloc_note_finale
    return ''
  end

  # Le menu des quiz déjà soumis, si c'est un quiz réutilisable et que
  # l'owner courant, identifié, l'a soumis plusieurs fois
  # Si ce module est chargé, c'est qu'il n'y a encore aucun résultat
  # pour ce quiz (donc aucun menu)
  def menu_old_owner_resultats
    ''  
  end
  
  # Les méthodes qui vont permettre de régler les valeurs du questionnaire
  # quand le questionnaire n'a pas encore été répondu

  # Renvoie la class pour le DIV de la question d'identifiant +question_id+
  def class_question question_id
    return 'question'
  end

  # Renvoie la class pour le LI de la réponse d'index +index_reponse+ pour la
  # question d'identifiant +question_id+
  def class_li_reponse question_id, index_reponse
    '' 
  end

  # Aucune réponse n'ayant encore été données, on retourne toujours ''  
  def code_checked question_id, index_reponse
    ''
  end
end #/Quiz
