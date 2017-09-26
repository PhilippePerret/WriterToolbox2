# encoding: utf-8
#
# Module principal d'affichage d'un quiz
#
class Quiz
  class << self
    attr_accessor :current
  end #/<< self

  # Méthode appelée quand on soumet le questionnaire
  #
  # Elle appelle le module d'évaluation et évalue les réponses données.
  # Dans le meilleur des cas, un enregistrement est créé pour l'user
  # avec ses résultats.
  #
  def evaluate
    require_module 'evaluate'
    evaluation_quiz
  end

end #/Quiz

# Le quiz courant, défini par l'URL
# 
# Noter qu'il est toujours associé à l'utilisateur courant, quel qu'il soit,
# identifié ou non.
def quiz
  @quiz ||= 
    begin
      Quiz.current ||= Quiz.new(site.route.objet_id, user)
    end
end
