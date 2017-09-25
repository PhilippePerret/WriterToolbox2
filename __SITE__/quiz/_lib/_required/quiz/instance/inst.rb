# encoding: utf-8
class Quiz

  include PropsAndDbMethods

  # Identifiant unique du quiz dans la table 'quiz.quiz'
  attr_reader :id

  def initialize qid
    @id = qid
  end


  def base_n_table ; @base_n_table ||= self.class.base_n_table end

end #/Quiz
