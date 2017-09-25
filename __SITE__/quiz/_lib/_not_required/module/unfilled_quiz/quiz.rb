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
      @allquiz[quiz_id] ||= Quiz.new(quiz_id, user_id)
      @allquiz[quiz_id]
    end

  end #/<< self
  
  # --------------------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # --------------------------------------------------------------------------------

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
