# encoding: utf-8
#
# Module chargé lorsque l'utilisateur soumet le quiz, pour
# enregistrer sa réponse.
#
class Quiz

  # Méthode principale d'évaluation du quiz
  def evaluation_quiz
    
    # Dans un premier temps, il faut s'assurer que l'user peut accomplir 
    # ce nouveau quiz et donc l'évaluer.
    evaluable? || return

    # On évalue vraiment le questionnaire, en regardant les résultats
    proceed_evaluation

    # Si on peut sauver les résultats
    saving_enabled? && save_resultats

  end

  # --------------------------------------------------------------------------------
  #
  #   MÉTHODES D'ÉVALUATION DU QUIZ
  #   
  # --------------------------------------------------------------------------------
  
  # Méthode principale procédant à l'évaluation et donc la génération
  # du résultat pour ce quiz.
  def proceed_evaluation
    debug "Quiz : #{param(:quiz).inspect}"   
    parse_ok = parse_param_quiz 
    debug "@resultats = #{@resultats.inspect}"
    parse_ok || return

  end


  # Méthode qui parse le paramètre :quiz pour en tire tous les éléments.
  # @return un Hash qui contient :
  #   {
  #     quiz_id:    L'ID du quiz dans le formulaire
  #     owner_id:   L'ID de l'user dans le formulaire (ou nil)
  #     not_evaluated:  Exceptionnement mis à true si quiz incorrect.
  #     reponses: {
  #       <id question> : [liste des choix] # Une liste, même avec Radio
  #       <id question> : [liste choix]
  #       etc.
  #     }
  #   }
  def parse_param_quiz
    q = param(:quiz)
    owid = q[:owner].nil_if_empty
    owid = owid.nil? ? nil : owid.to_i
    
    hres = {
      quiz_id:  q[:id].to_i,
      owner_id: owid,
      reponses: Hash.new     
    }

    # On récupère toutes les réponses
    # Rappel : elles sont reconnaissables car leurs clés commencent
    # par "qz-<quiz-id>"
    key_prefix = "qz-#{self.id}-"
    q.each do |key, value|
      key = key.to_s
      key.start_with?(key_prefix) || next
      qz, qzid, q, quid, r, rid = key.split('-')
      quid = quid.to_i
      hres[:reponses].key?(quid) || hres[:reponses].merge!(quid => Array.new)
      hres[:reponses][quid] << value.to_i
    end

    # Quelle que soit la suite à donner, on met la table des résultats
    # dans une propriété publique du questionnaire.
    # Cela permet, par exemple, de sélectionner à nouveau les questions déjà
    # répondues lorsqu'il manque des réponses et qu'on ne peut pas poursuivre
    @resultats = hres

    # Quelques checks avant de poursuivre
    params_valides?(hres) || 
      begin
        @resultats.merge!(not_evaluated: true) # pour ne pas affiche bon/bad
        return false
    end

    return hres
  end

  def params_valides?(hres)
    hres[:quiz_id] == self.id || raise('Ce quiz n’est pas valide…')
    hres[:owner_id] == owner.id || raise('Ce quiz n’a pas un propriétaire valide…')

    # Le nombre de réponses doivent correspondre exactement au nombre de questions
    nombre_reponses = hres[:reponses].keys.count
    nombre_questions = data[:specs][10..12].to_i(10)
    if nombre_questions == 0
      nombre_questions = data[:questions_ids].as_id_list.count
    end
    mess_error = 
      if nombre_reponses == 0
        'Il faut répondre aux questions'
      elsif nombre_reponses < nombre_questions
        'Il faut répondre à toutes les questions'
      else
        nil
      end
    mess_error == nil || (return __error "#{mess_error}, avant de soumettre ce quiz !")

    return true
  end

  # --------------------------------------------------------------------------------
  #
  #   MÉTHODES D'ÉTAT
  #   
  # --------------------------------------------------------------------------------


  # Retourne true si ce questionnaire peut être évalué
  #
  def evaluable?
    # Un utilisateur non identifié peut évaluer le
    # questionnaire tout le temps, puisque de toutes façons ses
    # résultats ne seront pas enregistrés
    owner.id != nil || (return true)

    # Si l'utilisateur a déjà fait ce questionnaire et que ce
    # n'est pas un questionnaire à usage multiple, on retourne
    # false en affichant un message d'erreur
    if deja_fait_par_owner? && !multiple?
      __error("C'est un quiz à usage unique et vous l’avez déjà soumis.")
      return false
    end

    # Si l'utilisateur a déjà fait ce questionnaire, qu'il est
    # à usage multiple, mais qu'il a été soumis il y a moins de
    # 5 minutes, on considère que c'est un rechargement de page
    if deja_fait_par_owner? && multiple? && last_time_recent?
      __error("Vous ne pouvez pas resoumettre le même quiz aussi vite…")
      return false
    end

    # Si on arrive ici c'est que tout est bon, on peut évaluer ce
    # quiz et donner le résultat
    return true
  end


  # Retourne true si l'owner a soumis le même quiz il y a moins
  # de 5 minutes
  def last_time_recent?
    where = "quiz_id = #{self.id} ORDER BY created_at DESC LIMIT 1"
    res = site.db.select(:users_tables,table_quiz_owner,where,[:id, :created_at]).first
    Time.now.to_i - res[:created_at] < 5 * 60
  end

  # Retourne true si l'owner a déjà fait ce quiz
  # Noter que cette méthode n'est appelée que si l'on s'est assurée
  # avant que l'owner n'était pas nil. Sinon, la question n'a pas
  # de sens
  def deja_fait_par_owner?
    site.db.count(:users_tables,table_quiz_owner,{quiz_id: self.id}) > 0
  end
  # Retourne true si on peut sauver les résultats
  #
  def saving_enabled?
    owner.id != nil || (return false)
     savable? || (return false)
  end

  # Retourne true si c'est un quiz qu'on peut soumettre plusieurs
  # fois
  def multiple?
    data[:specs][14].to_i & 1 > 0 # il faut qu'il y ait 1
  end
  # Retourne true si c'est un questionnaire dont il faut sauver
  # les résultats
  def savable?
    data[:specs][14].to_i & 2 == 0 # Il ne faut pas qu'il y ait 2
  end
  # Pour enregistrer les résultats
  #
  def save_resultats
    resultats_id = site.db.insert(:users_tables, table_quiz_owner, resultats)
  end
  # La table de l'user, dans laquelle sont enregistrés tous ses quiz
  # Attention : il faut forcément que l'user soit identifié
  def table_quiz_owner
    owner.id != nil || (return nil)
    "quiz_#{owner.id}"
  end
end
