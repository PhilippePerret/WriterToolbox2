# encoding: utf-8
class Quiz

  include PropsAndDbMethods
  include MainSectionMethods

  # Le délimiteur de données dans les réponses des questions
  DELIM_REPONSE_DATA = ':::'


  # Identifiant unique du quiz dans la table 'quiz.quiz'
  attr_reader :id

  # {User} Peut-être l'user pour lequel on affiche ce questionnaire, qui l'a
  # peut-être déjà fait. Sert à afficher ses résultats.
  attr_reader :owner

  # {Hash} Soit le résultat actuel au cours de la soumission du quiz, soit
  # la donnée récupérée d'un ancien quiz.
  # Voir le fichier Reponses.md pour le détail.
  attr_reader :resultats

  def initialize qid, owner = nil
    @id     = qid
    if owner != nil
      owner.is_a?(Fixnum) && owner = User.new(owner)
      owner.is_a?(User) || raise("Le second argument doit être NIL ou l'user.")
    end
    @owner  = owner
  end

  # Retourne le code HTML du quiz, en le construisant si nécessaire.
  #
  # @param {Hash} resultats
  #               Les résultats à afficher éventuellement.
  #               
  def output
   data[:output] || 
     begin
       require_module 'build_output'
       data[:output] = build_output
   end

   debug "[Quiz#output] @resultats = #{resultats.inspect}"
   debug "resultats.nil? est #{resultats.nil?.inspect}"
   # Si des résultats sont fournis, il faut charger le module qui va permettre
   # de régler à nouveau le questionnaire. Sinon, on charge le module par défaut
   # qui ne produit rien.
   # Noter que des résultats sont toujours fournis lorsqu'on vient de soumettre
   # le questionnaire.
   filled_folder = "#{resultats.nil? ? 'un' : ''}filled_quiz" 
   require_module filled_folder
   Dir["#{folder}/_lib/_not_required/module/#{filled_folder}/*.rb"].each{|m| load m}
   
   <<-HTML
   <form id="quiz_form-#{self.id}" class="quiz_form">
    <input type="hidden" name="operation" value="evaluate_quiz" />
    <input type="hidden" name="quiz[id]" id="quiz_id" value="#{self.id}" />
    <input type="hidden" name="quiz[owner]" id="quiz_owner" value="#{owner.id}" />
    #{ERB.new(data[:output].force_encoding('utf-8')).result()}
    <div class="buttons">
      <input type="submit" class="main btn" value="Soumettre ce quiz" />
    </div>
   </form>
   HTML
  end

  # Pour les main méthodes
  def folder        ; @folder       ||= File.join('.','__SITE__','quiz')  end
  # Pour les DB méthodes
  def base_n_table  ; @base_n_table ||= [:quiz, 'quiz']                   end
  
end #/Quiz
