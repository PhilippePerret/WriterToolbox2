# encoding: UTF-8
=begin

Script qui calcule le nombre de points max sur une question pour
le mettre dans les specs (5 à 7e bit).

=end

values = Array.new
site.db.select(:quiz,'questions',nil,[:reponses,:specs,:id]).each do |hquestion|
  reps = hquestion[:reponses]

  choix_multiple = hquestion[:specs][0] == 'c'

  max_points = 0
  reps.split("\n").each do |rep|
    lib, points, rien = rep.split(':::')
    points = points.to_i
    # Suivant la nature de la question (choix multiple ou non), on prend
    # seulement la valeur ou on l'ajoute
    if choix_multiple && points > 0
      max_points += points
    elsif points > max_points
      max_points = points
    end
  end
  # On met dans les specs
  specs = hquestion[:specs].ljust(7,'0')
  specs[4..6] = max_points.to_s.rjust(3,'0')
  values << [specs, hquestion[:id]]
  debug "#{values.last.inspect}"
end

request = 'UPDATE questions SET specs = ? WHERE id = ?'
# site.db.use_database(:quiz)
# site.db.execute(request, values)
