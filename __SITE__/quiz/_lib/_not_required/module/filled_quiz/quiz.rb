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

  # Les méthodes qui vont permettre de régler les valeurs du questionnaire

  # Renvoie la class pour le DIV de la question d'identifiant +question_id+
  #
  # Peut avoir trois valeurs différentes :
  # - la question n'a pas été répondue        => ''
  # - la question a été correctement répondue => 'bon'
  # - la question n'a pas reçue une réponse correcte => 'bad'
  #
  # On ajoute aussi toujours 'question' au div
  def class_question question_id
    c = ['question']
    
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
    '' 
  end

  # Renvoie '' ou 'checked=CHECKED' pour indiquer que la réponse d'index
  # +index_reponse+ de la question d'identifiant +question_id+ a été cochée/choisie
  # lors du remplissage du questionnaire.
  #
  def code_checked question_id, index_reponse
    ''
  end
end #/Quiz
