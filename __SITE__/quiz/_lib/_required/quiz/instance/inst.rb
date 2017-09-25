# encoding: utf-8
class Quiz

  include PropsAndDbMethods
  include MainSectionMethods

  # Identifiant unique du quiz dans la table 'quiz.quiz'
  attr_reader :id

  # {User} Peut-être l'user pour lequel on affiche ce questionnaire, qui l'a
  # peut-être déjà fait. Sert à afficher ses résultats.
  attr_reader :owner

  def initialize qid, owner = nil
    @id     = qid
    @owner  = owner
  end

  # Retourne le code HTML du quiz, en le construisant si nécessaire.
  #
  # @param {Hash} resultats
  #               Les résultats à afficher éventuellement.
  #               
  def output resultats = nil
   data[:output] || 
     begin
       require_module 'build_output'
       data[:output] = build_output
   end

   # Si des résultats sont fournis, il faut charger le module qui va permettre
   # de régler à nouveau le questionnaire. Sinon, on charge le module par défaut
   # qui ne produit rien.
   require_module "#{resultats.nil? ? 'un' : ''}filled_quiz"
   
   deserb(data[:output])
  end

  def folder        ; @folder       ||= File.join('.','__SITE__','quiz')  end
  def base_n_table  ; @base_n_table ||= self.class.base_n_table           end


  
end #/Quiz
