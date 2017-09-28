# encoding: utf-8
#
# Module principal d'affichage d'un quiz
#
class Quiz
  class << self
    attr_accessor :current

    # List des quiz affichée lorsque l'URL est simplement 'quiz', sans
    # ID de quiz à afficher.
    def list
      '[Bientôt ici la liste des quiz]'
    end

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
  # Si c'est un quiz réutilisable, et que l'user l'a fait plusieurs fois,
  # on affiche un menu lui permettant de revoir un quiz en particulier.
  #
  def output

   data[:output] || 
     begin
       require_module 'build_output'
       data[:output] = build_output
   end

   # Si des résultats existent, on affiche la note obtenue 
   # (note : pour le moment, seulement la note obtenue)
   # Note : Il faut faire ce test avant de charger le module `filled` ou
   # `unfilled` qui se chargent en fonction de la présence ou non de résultat.
   if resultats == nil && owner && owner.id != nil && param(:operation) != 'redo'
     try_get_resultats_in_table_owner
   end
   
   # Si des résultats sont fournis, il faut charger le module qui va permettre
   # de renseigner à nouveau le questionnaire. Cf. le manuel.
   filled_folder = "#{resultats.nil? ? 'un' : ''}filled_quiz" 
   require_module filled_folder
   Dir["#{folder}/_lib/_not_required/module/#{filled_folder}/*.rb"].each{|m| load m}
   
   <<-HTML
   <form id="quiz_form-#{self.id}" class="quiz_form">
    <input type="hidden" name="operation" value="evaluate_quiz" />
    <input type="hidden" name="quiz[id]" id="quiz_id" value="#{self.id}" />
    <input type="hidden" name="quiz[owner]" id="quiz_owner" value="#{owner ? owner.id : ''}" />
    #{hidden_field_for_unan_work}
    #{bloc_note_finale}
    #{ERB.new(data[:output].force_encoding('utf-8')).result()}
    <div class="buttons">
      #{menu_old_owner_resultats}
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
        '<button id="redo_quiz" class="btn main" onclick="this.form.operation.value=\'redo\';this.form.submit()">Recommencer ce quiz</button>'
      else
        # Quiz non réutilisable, donc pas de bouton
        ''
      end
    else
      '<input type="submit" class="main btn" value="Soumettre ce quiz" />'
    end
  end

  # Méthode appelée quand on soumet le questionnaire
  #
  # Elle appelle le module d'évaluation et évalue les réponses données.
  # Dans le meilleur des cas, un enregistrement est créé pour l'user
  # avec ses résultats.
  #
  # Noter que cette méthode peut être aussi appelée pour une ré-évaluation
  # d'un quiz réutilisable.
  #
  def evaluate
    require_module 'evaluate'
    evaluation_quiz
  end

  # Appelée quand on clique sur le bouton 'Recommencer ce quiz'
  # Seuls quelques contrôles sont nécessaires ici.
  def redo
    owner.id != nil || raise('Pas cool, d’essayer de pirater ce site…')
    data[:specs][14].to_i & 1 > 0 || raise('Ce quiz ne peut pas être recommencé.')
  end



  # Méthode qui tente de récupérer un résultat enregistré dans la base de données,
  # dans la table de l'owner, qui doit être identifié.
  # On ne doit venir ici que si l'owner est identifié et si ce n'est pas une
  # évaluation du quiz courant.
  #
  # Si l'opération est 'revoir', on prend la valeur de param(:quiz)[:resultats_id]
  # qui définit l'identifiant de l'enregistrement des résultats précédents de ce
  # quiz, lorsqu'il y en a plusieurs.
  #
  def try_get_resultats_in_table_owner
    begin
      where =
        if param(:operation) == 'revoir'
          {id: param(:quiz)[:resultats_id].to_i}
        else
          "quiz_id = #{id} ORDER BY created_at DESC LIMIT 1"
        end
      res = site.db.select(:users_tables,"quiz_#{owner.id}",where).first
    rescue Mysql2::Error => e
      # Survient lorsque l'user n'a pas encore de table
      return
    end
    res = JSON.parse(res[:resultats], symbolize_names: true)
    # Il faut remettre les identifiants des questions (:"12" => 12)
    reps = Hash.new 
    res[:reponses].each do |quid_symstr, qudata|
      reps.merge!(quid_symstr.to_s.to_i => qudata)
    end
    res[:reponses] = reps

    # On met les résultats dans la propriété du quiz
    @resultats = res
  end

  # Retourne le champ hidden pouvant contenir la propriété wid si
  # c'est un quiz appelé pour le programme UN AN UN SCRIPT
  def hidden_field_for_unan_work
    param(:wid) || (return '')
    "<input type=\"hidden\" name=\"wid\" value=\"#{param :wid}\" />"
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
