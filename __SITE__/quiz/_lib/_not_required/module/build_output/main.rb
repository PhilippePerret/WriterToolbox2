# encoding: utf-8
#

# On aurait forcément besoin des méthodes HTML pratiques
require './lib/extensions_sup/String.html'


class Quiz

  # Construit la sortie pour le questionnaire,
  # enregistre le code dans la données :output
  # et le renvoie.
  #
  # Noter que ce code est totalement indépendant des résultats qui
  # ont pu être donnés par un user, mais les incorpore en produisant
  # un code ERB dynamique.
  #
  def build_output
    data[:questions_ids].as_id_list.collect do |question_id|
      Question.new(question_id, self).output
    end.join('').in_div(class: 'quiz', id: "quiz-#{id}")
  end

end #/Quiz
