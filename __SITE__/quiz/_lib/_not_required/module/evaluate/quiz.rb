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
    # C'est avec cette méthode que sera produit @resultats, la donnée
    # contenant les résultats.
    proceed_evaluation || return

    # On procède au calcul de la note et à l'affinement des résultats
    # avec, notamment, le remplissage des données de chaque question pour 
    # pouvoir attribuer une note générale et un nombre de points
    calcul_resultat || return

    # Note : on ne construit pas l'encart pour le résultat, pour 
    # permettre d'ajuster l'affichage suivant les versions.

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
  #
  # @return true si tout s'est bien passé, false dans le cas contraire
  # Le "cas contraire", c'est surtout lorsque le quiz n'a pas été entièrement
  # rempli.
  def proceed_evaluation
    parse_ok = parse_param_quiz 
    return parse_ok
  end


  # --------------------------------------------------------------------------------
  #
  #   MÉTHODES DE CALCUL DU QUIZ
  #   
  # --------------------------------------------------------------------------------

  # Méthode principale procédant au calcul du quiz
  #
  # @return true si tout s'est bien passé, false dans le cas contraire
  #
  def calcul_resultat

    # Ajout d'autres propriétés
    resultats.merge!(
      nombre_questions: resultats[:reponses].keys.count,
      total_points:     0,        # Le nombre total de points de l'owner
      total_points_max: 0         # Le nombre total de points gagnables
    )

    # Boucle sur chaque réponse
    resultats[:reponses].each do |quid, qudata|
      qu = Question.new(quid)
      resultats[:reponses][quid] = qu.traite_reponse(qudata)
      # Incrémentation du total des points
      resultats[:total_points]      += resultats[:reponses][quid][:points]
      resultats[:total_points_max]  += resultats[:reponses][quid][:points_max]
    end
    
    calcul_note_finale

    debug "@resultats après calcul : #{resultats.inspect}"
    return true
  end


  # Calcul de la note finale. Elle sera mise dans les résultats.
  # Noter qu'elle est multipliée par dix, donc pour obtenir la vraie note
  # sur 20, il faut diviser la note par 10.
  def calcul_note_finale
    points = resultats[:total_points]
    maxpts = resultats[:total_points_max]
    is_pos = points >= 0
    is_pos || points = -points
      
    # Calcul précis de la note finale
    note = ((20.0 * points / maxpts).round(1) * 10).to_i
    resultats[:note_finale] = note # noter qu'elle est multipliée par 10
    
  end

  # --------------------------------------------------------------------------------
  #
  #   MÉTHODES D'ENREGISTREMENT
  #   
  # --------------------------------------------------------------------------------
  # Pour enregistrer les résultats
  #
  def save_resultats
    # Il faut s'assurer que la table de user existe.
    begin
      site.db.count(:users_tables, table_quiz_owner)
    rescue Mysql2::Error => e
      if e.message.match(/Table(.*?)doesn't exist/)
        create_table_owner
        retry
      else
        # Une autre erreur non gérée.
        raise e
      end
    end
    data2save = Hash.new
    not_saved_props = [:not_evaluate, :evaluating, :quiz_id, :owner_id]
    resultats.each do |prop, propvalue|
      not_saved_props.include?(prop) && next
      data2save.merge!(prop => propvalue)
    end
    newdata = {
      quiz_id:   resultats[:quiz_id], 
      user_id:   owner.id, 
      note:      resultats[:note_finale],
      resultats: data2save.to_json
    }
    resultats_id = site.db.insert(:users_tables, table_quiz_owner, newdata)
  end

  def create_table_owner
    request = <<-SQL
    CREATE TABLE quiz_#{owner.id}
    (
      id INTEGER AUTO_INCREMENT,
      user_id INTEGER,
      quiz_id INTEGER NOT NULL,
      resultats BLOB NOT NULL,
      note INTEGER(3) NOT NULL,
      options VARCHAR(8) DEFAULT '00000000',
      updated_at INTEGER(10),
      created_at INTEGER(10),
      PRIMARY KEY (id)
    );

    SQL
    site.db.use_database(:users_tables)
    site.db.execute(request)
  end
  # --------------------------------------------------------------------------------
  #
  #   SOUS-MÉTHODES D'ÉVALUATION DU QUIZ
  #   
  # --------------------------------------------------------------------------------

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
  #   Le hash de la question (hquestion) contient :
  #   {
  #     choix: Liste des choix,
  #     points: nil, # sera renseigné plus tard
  #     points_max: nil # idem
  #     bons_choix: nil # idem
  #     best_choix: nil # idem
  #   }
  def parse_param_quiz
    q = param(:quiz)
    owid = q[:owner].nil_if_empty
    owid = owid.nil? ? nil : owid.to_i
    
    hres = {
      date:     Time.now.strftime('%d %m %Y - %H:%M'),
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
      hres[:reponses].key?(quid) || hres[:reponses].merge!(quid => {choix:Array.new,points:nil,points_max:nil,bons_choix:nil,best_choix:nil})
      hres[:reponses][quid][:choix] << value.to_i
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
    begin
      where = "quiz_id = #{self.id} ORDER BY created_at DESC LIMIT 1"
      res = site.db.select(:users_tables,table_quiz_owner,where,[:id, :created_at]).first
      Time.now.to_i - res[:created_at] < 5 * 60
    rescue Mysql2::Error => e
      return false
    end
  end

  # Retourne true si l'owner a déjà fait ce quiz
  # Noter que cette méthode n'est appelée que si l'on s'est assurée
  # avant que l'owner n'était pas nil. Sinon, la question n'a pas
  # de sens
  def deja_fait_par_owner?
    begin
      site.db.count(:users_tables,table_quiz_owner,{quiz_id: self.id}) > 0
    rescue Mysql2::Error => e
      return false
    end
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

  # La table de l'user, dans laquelle sont enregistrés tous ses quiz
  # Attention : il faut forcément que l'user soit identifié
  def table_quiz_owner
    owner.id != nil || (return nil)
    "quiz_#{owner.id}"
  end
end
