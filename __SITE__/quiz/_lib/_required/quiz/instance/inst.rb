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

  # Retourne true si c'est un quiz qu'on peut soumettre plusieurs
  # fois. La méthode est mise ici car elle sert à de nombreux endroits
  def reusable?
    data[:specs][14].to_i & 1 > 0 # il faut qu'il y ait 1
  end
  # Pour les main méthodes
  def folder        ; @folder       ||= File.join('.','__SITE__','quiz')  end
  # Pour les DB méthodes
  def base_n_table  ; @base_n_table ||= [:quiz, 'quiz']                   end
  
end #/Quiz
