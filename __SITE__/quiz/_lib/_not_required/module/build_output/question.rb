# encoding: utf-8
#
# Extension de la class Quiz::Question qui permet de construire la
# sortie (output) du questionnaire.
#
# Noter que pour le moment, on n'a besoin de cette classe que pour la
# construction du questionnaire, ce qui explique que c'est ici qu'est
# initialiser une question.
#
class Quiz
  class Question

    include PropsAndDbMethods

    attr_reader :id
    attr_reader :quiz

    # Instanciation de la question
    #
    # @param {Fixnum} qid
    #                 Identifiant unique de la question
    #
    # @param {Quiz}   quiz
    #                 Éventuellement, le quiz pour lequel la question doit
    #                 être instancié. Sert pour nommer les identifiants du
    #                 code HTML produit par `output`
    def initialize qid, quiz = nil
      @id   = qid
      @quiz = quiz
    end

    # Retourne le code HTML de la question, entièrement formaté
    def output
      (
        question.in_div(class: 'libelle')+
        reponses_output
      ).in_div(id: dom_id, class: div_class)
    end

    # La classe du div de la question.
    # Si un quiz est fourni (car normal), c'est un code ERB qui est inséré, pour
    # pouvoir régler la classe de la question en fonction de son succès, de son échec,
    # ou du fait qu'elle n'a pas encore été répondue.
    def div_class
      quiz != nil || (return 'question')
      "<%= Quiz[#{quiz.id}].class_question(#{id}) %>"
    end

    # {String} Identifiant pour le DOM, qui sera aussi utilisé pour les
    # réponses
    def dom_id
      @dom_id ||= "qz-#{quiz ? quiz.id : 0}-q-#{id}" 
    end


    # Code HTML du UL des réponses possibles
    def reponses_output
      # TODO Faut-il mélanger les réponses ou les garder dans le même ordre ?
      reps = reponses.collect{|r|r}
      if specs[3] != '1' # Ordre réponses fixe
        reps = reponses.shuffle.shuffle
      end
      # TODO Faut-il afficher les réponses en ligne ou en colonne ? (ça joue
      # simplement sur la class du UL)
      class_ul = ['reponses']
      class_ul << specs[1] # c:colonne, l:ligne, m:menu
      reps.collect do |reponse|
        reponse.output
      end.join('').in_ul(class: class_ul.join(' '))
    end


    # Réinitialisation de la donnée (utile principalement pour les tests)
    def reset
      @question = nil
      @specs    = nil
      @reponses = nil
    end
    

    # Propriétés de la question
    def question  ; @question ||= data[:question]   end
    def specs     ; @specs    ||= data[:specs]      end

    
    # Retourne la liste des réponses, comme des instances de
    # Quiz::Question::Reponse
    def reponses
      @reponses ||=
        begin
          index_reponse = -1
          data[:reponses].split("\n").collect do |line_reponse|
            index_reponse += 1
            Reponse.new(line_reponse, index_reponse, self)
          end
        end
    end
    
    def base_n_table ; @base_n_table ||= [:quiz, 'questions'] end

  end #/Question
end #/Quiz
