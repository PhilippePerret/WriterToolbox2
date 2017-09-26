# encoding: UTF-8
=begin

  Grand script de récupération des quiz
  -------------------------------------

  Rappel : avant, on fonctionnait en plusieurs bases, maintenant tous
  les quiz sont rassemblés dans une base unique, `boite-a-outils_quiz`.

=end

# Les anciens quiz à récupérer :
# quiz_biblio
# quiz_unan

all_quiz = Array.new
all_quiz += site.db.select(:quiz_biblio,'quiz').collect do |hquiz|
  specs =
    case  hquiz[:groupe]
    when 'scenodico'  then '001'
    when 'filmodico'  then '002'
    end
  hquiz.merge!(specs: specs.ljust(16,'0'))
  hquiz[:id] += 20
  hquiz
end
all_quiz += site.db.select(:quiz_unan,'quiz').collect do |hquiz|
  hquiz.merge!(specs: '003'.ljust(16,'0'))
  # Pour les quiz UAUS, on ajoute 50 à l'identifiant des questions
  # debug "Ancienne liste : #{hquiz[:questions_ids]}"
  qids = hquiz[:questions_ids].as_id_list.collect{|id| id + 50}
  hquiz[:questions_ids] = qids.join(' ')
  # debug "Nouvelle liste : #{hquiz[:questions_ids]}"
  # Terminer par (collect)
  hquiz
end

=begin

Modification des options.
La propriété `options` des anciens `quiz` est remplacée par `specs` mais les
décalages de bit ne sont plus les mêmes.
On trouve ci-dessous la correspondance : la clé est l'ancien décalage dans options
# Valeurs des bits d'options avant :
OPTIONS = {
  0 => {hname: 'courant', description: '1: quiz courant, 0: pas courant', newBit: 8},
  1 => {hname: 'aléatoire', description: '1: questions dans un ordre aléatoire, 0: questions dans ordre prédéfini', newBit: 9},
  2 => {hname: 'Centaine du nombre max de questions ou -', description: nil, newBit: 10},
  3 => {hname: 'Dizaine du nombre max de questions ou -', description: nil, newBit: 11},
  4 => {hname: 'Unité du nombre max de questions ou 0', description: nil, newBit: 12},
  5 => {hname: 'Hors de liste', description: '1: hors des listes — par exemple les quiz de test ou du programme UNAN', newBit: nil},
  6 => {hname: 'Réutilisable', description: 'Pour le programme UNAN, un test réutilisable permet d’être fait autant de fois qu’on veut, mais ne génère pas de point.', newBit: 14}
}

specs[newBit] = options[oldID]

=end
bit_option_to_bit_specs = {
  0 => 8, 1 => 9, 2 => 10, 3 => 11, 4 => 12, 6 => 14 # 5 est volontairement oublié
}
all_quiz.each do |hquiz|
  # Le type
  hquiz[:specs][0] = hquiz[:type].to_s
  # Les options
  opts = hquiz[:options]
  bit_option_to_bit_specs.each do |oldb, newb|
    hquiz[:specs][newb] = opts[oldb] || '0'
  end
  hquiz[:output] = nil
  # On peut supprimer les options et autres valeurs inutiles
  hquiz.delete(:type)
  hquiz.delete(:options)
  hquiz.delete(:groupe)

end

# Les nouvelles propriétés des quiz :
# titre, specs, questions_ids, description, created_at, updated_at


debug "ALL QUIZ : #{all_quiz.inspect}"



# TODO Il reste encore les IDS de questions à modifier, entendu que pour le
# moment, elles sont enregistrées dans des tables différentes mais que
# maintenant qu'elles vont être dans une nouvelle table unique elles vont
# modifier leur identifiant. La solution serait d'incrémenter ces identifiants
# d'une valeur unique.
# Pour les questions qui viennent de quiz_unan, il faut ajouter 50 à l'identifiant
all_questions = Array.new
all_questions += site.db.select(:quiz_biblio,'questions').collect do |hquestion|
  specs =
    case hquestion[:groupe]
    when 'scenodico' then '001'
    when 'filmodico' then '002'
    else ''
    end.ljust(16,'0')
  hquestion.merge!(specs: specs)

  # Terminer par : (pour la collecte)
  hquestion
end
all_questions += site.db.select(:quiz_unan,'questions').collect do |hquestion|
  hquestion[:id] += 50

  hquestion.merge!(specs: '003'.ljust(16,'0'))

  # Terminer par : (pour la collecte)
  hquestion
end


all_questions.each do |hquestion|
  type = hquestion[:type] || ''
  case type[1]
  when 'c', 'r' then true
  else raise("Le choix multiple/unique est mauvaise (devrait être c ou r, est #{type[1]})")
  end
  alignement =
    case type[2]
    when 'v', 'c' then 'c'
    when 'h','l'  then 'l'
    when 'm'      then 'm'
    else raise("La valeur d'alignement est mauvaise. Devrait être c, l ou m, est #{type[2]}")
    end
  hquestion[:specs][0] = type[1]
  hquestion[:specs][1] = alignement

  # Pour calculer la valeur max de points
  choix_multiple = type[1] == 'c'

  raison = hquestion.delete(:raison)

  # Nombre de points max pour la question
  max_points = 0

  # IL faut modifier toutes les réponses pour les mettre dans un autre format
  # qui prendra moins de place
  reponses = JSON.parse(hquestion[:reponses])
  # Si une raison est donnée, on la met dans la réponse qui vaut le plus
  # de points.
  pts_max_reponse   = -1
  ind_max_reponse = nil
  reponses.each_with_index do |hreponse, ireponse|
    points_rep = hreponse['pts'].to_i
    if points_rep > pts_max_reponse
      # Cette réponse a le max de points pour le moment
      pts_max_reponse = points_rep
      ind_max_reponse = ireponse
    end

    if choix_multiple && points_rep > 0
      max_points += points_rep
    end

  end

  unless choix_multiple
    max_points = pts_max_reponse
  end

  if raison
    # ind_max_reponse contient l'index de la réponse qui a le
    # plus de points, on met la raison dedans. Penser quand même que
    # ça peut être une question à choix multiple
    reponses[ind_max_reponse].merge!('raison' => raison)
  end

  hquestion[:reponses] =
    reponses.collect do |hreponse|
      rai = hreponse['raison']
      "#{hreponse['lib']}:::#{hreponse['pts']}#{rai.nil? ? '' : ':::'+rai}"
    end.join("\n")


  # On met le max de points dans les specs
  hquestion[:specs][4..6] = max_points.to_s.rjust(3,'0')

  hquestion.delete(:groupe)
  hquestion.delete(:type)


  debug "\nQUESTION ##{hquestion[:id]} = #{hquestion.inspect}"

  # raison && break # pour des essais

end

### Ici, normalement, je suis prêt à tout récupérer

# # ---------------------------------------------------------------------
# #   ON ENREGISTRE LES QUIZ
# # ---------------------------------------------------------------------
# all_quiz.each do |hquiz|
#   site.db.insert(:quiz,'quiz',hquiz)
# end

#
# # ---------------------------------------------------------------------
# #   ON ENREGISTRE LES QUESTIONS
# # ---------------------------------------------------------------------
# all_questions.each do |hquestion|
#   site.db.insert(:quiz, 'questions', hquestion)
# end
