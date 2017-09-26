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
    quiz_str = String.new

    # Le titre du quiz
    quiz_str << "<h3 class=\"titre\">#{data[:titre]}</h3>"

    # L'indication, si elle existe
    if data[:description]
      quiz_str << data[:description].in_div(class: 'description')
    end

    # La liste des questions
    quiz_str += questions_ids_for_quiz.collect do |question_id|
      Question.new(question_id, self).output
    end.join('')
      
    # On le met dans son DIV
    quiz_str = quiz_str.in_div(class: 'quiz', id: "quiz-#{id}")


    # On l'enregistre dans la table pour s'en souvenir plus
    # tard
    set(output: quiz_str)

    # On peut retourner la donnée construite, qui sera aussitôt
    # mise dans data[:output]
    return quiz_str
  end

  # Retourne la liste {Array} des identifiants des questions
  # à afficher pour ce quiz.
  # Rappel : les questions peuvent être affichées dans le
  # désordre et en nombre limité
  #
  def questions_ids_for_quiz
    ids = data[:questions_ids].as_id_list

    nombre_max = data[:specs][10..12].to_i(10)
    debug "data[:specs] = #{data[:specs].inspect}"

    if data[:specs][9] == '1' || nombre_max > 0 
      ids = ids.shuffle.shuffle.shuffle
    end

    if nombre_max != 0
      ids = ids[0..nombre_max-1]
    end
    
    return ids
  end

end #/Quiz
