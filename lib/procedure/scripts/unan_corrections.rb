# encoding: UTF-8
=begin

  Script permettant de corriger les données des tables UN AN UN SCRIPT

=end


=begin

  CORRECTION DES “” ajoutés autour des titres

=end


# # Liste des valeurs pour la requête préparée
# values = Array.new
# # Sélectionner les titres incorrects
# site.db.select(
#   :unan,
#   'absolute_works',
#   "titre LIKE '“%'",
#   [:id, :titre]
#   )
# .each do |habswork|
#   new_titre = habswork[:titre].sub(/“/,'').sub(/”/,'')
#   values << [new_titre, habswork[:id]]
# end
# # Requête préparée
# request = "UPDATE absolute_works SET titre = ? WHERE id = ?"
# site.db.use_database(:unan)
# site.db.execute(request, values)
# # Débug des valeurs corrigées
# debug "values corrigées = #{values.inspect}"
