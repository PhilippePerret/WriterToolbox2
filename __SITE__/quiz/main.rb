# encoding: utf-8
#
# Module principal d'affichage d'un quiz
#
class Quiz
  class << self
    attr_accessor :current
  end #/<< self

  # Retourne le code HTML du quiz, en le construisant si nécessaire.
  #
  # Situations possibles de l'affichage
  # -----------------------------------
  #   - Quiz sans résultat, par exemple lorsque l'utilisateur arrive
  #     sur le quiz.
  #   - Quiz avec un résultat incomplet qui vient d'être produit.
  #   - Quiz avec un résultat qui vient d'être produit avec un remplissage
  #     complet du quiz
  #   - Quiz avec un résultat qu'on recharge depuis la table.
  #
  def output

   data[:output] || 
     begin
       require_module 'build_output'
       data[:output] = build_output
   end

   # Si des résultats sont fournis, il faut charger le module qui va permettre
   # de régler à nouveau le questionnaire. Sinon, on charge le module par défaut
   # qui ne produit rien.
   # Noter que des résultats sont toujours fournis lorsqu'on vient de soumettre
   # le questionnaire.
   filled_folder = "#{resultats.nil? ? 'un' : ''}filled_quiz" 
   require_module filled_folder
   Dir["#{folder}/_lib/_not_required/module/#{filled_folder}/*.rb"].each{|m| load m}
   
   # Si des résultats existent, on affiche la note obtenue et le commentaire
   # (note : pour le moment, seulement la note obtenue)
   if resultats == nil && owner.id != nil && param(:operation) != 'redo'
     try_get_resultats_in_table_owner
   end
   
   <<-HTML
   <form id="quiz_form-#{self.id}" class="quiz_form">
    <input type="hidden" name="operation" value="evaluate_quiz" />
    <input type="hidden" name="quiz[id]" id="quiz_id" value="#{self.id}" />
    <input type="hidden" name="quiz[owner]" id="quiz_owner" value="#{owner.id}" />
    #{bloc_note_finale}
    #{ERB.new(data[:output].force_encoding('utf-8')).result()}
    <div class="buttons">
      #{bouton_soumission}
    </div>
   </form>
   HTML
  end

  # Retourne le code HTML pour le bouton à afficher
  def bouton_soumission
    if resultats && !resultats[:not_evaluated]
      # S'il y a des résultats, on peut vouloir soit recommencer ce
      # quiz si c'est possible, soit ne rien faire si ce quiz n'est faisable
      # qu'une seule fois
      if data[:specs][14].to_i & 1 > 0
        # C'est un quiz réutilisable
        '<a class="main btn" href="?operation=redo">Refaire</a>'
      else
        # Quiz non réutilisable, donc pas de bouton
        ''
      end
    else
      '<input type="submit" class="main btn" value="Soumettre ce quiz" />'
    end
  end

  # Retourne le code HTML de la note finale, si le résultat existe
  def bloc_note_finale
    resultats && !resultats[:not_evaluated] || (return '')
    nfinale = resultats[:note_finale]
    class_encart =
      if nfinale < 80
        'bad'
      elsif nfinale < 120
        'med'
      else
        'bon'
      end
    (
      resultats[:date].in_span(class: 'date') +
      "#{resultats[:note_finale].to_f/10} / 20".sub(/\.0/,'').sub(/\./,',').in_span(class: 'note_finale')+
      ("Points : #{resultats[:total_points]} / #{resultats[:total_points_max]}").in_span(class:'points')
    ).in_div(class: "encart_note_finale #{class_encart}quiz").in_div(class: 'quiz_header')
    
  end
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

  # Méthode qui tente de récupérer un résultat enregistré dans la base de données,
  # dans la table de l'owner, qui doit être identifié.
  # On ne doit venir ici que si l'owner est identifié et si ce n'est pas une
  # évaluation du quiz courant
  #
  def try_get_resultats_in_table_owner
    begin
      where = "quiz_id = #{id} ORDER BY created_at DESC LIMIT 1"
      res = site.db.select(:users_tables,"quiz_#{owner.id}",where).first
    rescue Mysql2::Error => e
      return
    end
    @resultats = JSON.parse(res[:resultats], symbolize_keys: true)
    debug "@resultats depuis la base : #{resultats.inspect}"
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
