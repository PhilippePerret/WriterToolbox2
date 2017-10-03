=begin

  Fichier principal du support pour le forum

=end

# Méthode qui récrée intégralement les données du forum
#
# S'arranger pour ne pas l'appeler chaque fois. L'appeler une première fois
# en début de test, au début de la journée, puis garder ces données.
#
# - crée 4 auteurs en plus des 3 toujours présents, administrateurs
# - crée 50 sujets
# - crée entre 10 et 100 messages par sujet
#
def reset_all_data_forum
  puts "JE RECRÉE TOUTES LES DONNÉES FORUM"
  # Effacement de toutes les tables
  forum_truncate_all_tables
  truncate_table_users

  ids_auteurs = [1,2,3]
  @drene = create_new_user(pseudo: 'René', sexe: 'H', password: 'motdepasserene', mail_confirmed: true)
  @rene = User.get(@drene[:id])
  ids_auteurs << @rene.id
  @dlise = create_new_user(pseudo: 'Lise', sexe: 'F', password: 'motdepasselise', mail_confirmed: true)
  @lise = User.get(@dlise[:id])
  ids_auteurs << @lise.id
  @dbenoit = create_new_user(pseudo: 'Benoit', sexe: 'H', password: 'motdepassebenoit', mail_confirmed: true)
  @benoit = User.get(@dbenoit[:id])
  ids_auteurs << @benoit.id
  @dmaude = create_new_user(pseudo: 'Maude', sexe: 'F', password: 'motdepassemaude', mail_confirmed: true)
  @maude  = User.get(@dmaude[:id])
  ids_auteurs << @maude.id
  # On fait des auteur avec des grand bien particuliers

  @dApprentiSurveilled = create_new_user(pseudo: 'ApprentiSurveillé', grade_forum: 3, sexe: 'H', password: 'motdepasse', mail_confirmed: true)
  @apprentiSurveilled = User.get(@dApprentiSurveilled[:id])
  ids_auteurs << @apprentiSurveilled.id


  @dSimpleRedactrice = create_new_user(pseudo: 'SimpleRedactrice', grade_forum: 4, sexe: 'F', password: 'simpleredactrice', mail_confirmed: true)
  @simpleRedactrice = User.get(@dSimpleRedactrice[:id])
  ids_auteurs << @simpleRedactrice.id

  @dRedacteur = create_new_user(pseudo: 'Redacteur', grade_forum: 5, sexe: 'H', password: 'vrairedacteur', mail_confirmed: true)
  @redacteur = User.get(@dRedacteur[:id])
  ids_auteurs << @redacteur.id

  @dRedacteurEmerite = create_new_user(pseudo: 'RédacteurEmérite', grade_forum: 6, sexe: 'H', password: 'motdepasse', mail_confirmed: true)
  @redacteurEmerite = User.get(@dRedacteurEmerite[:id])
  ids_auteurs << @redacteurEmerite.id

  @dRedactriceConfirmee = create_new_user(pseudo: 'RédactriceConfirmée', grade_forum: 7, sexe: 'F', password: 'motdepasse', mail_confirmed: true)
  @redactriceConfirmee = User.get(@dRedactriceConfirmed[:id])
  ids_auteurs << @redactriceConfirmee.id

  @dMaitreRedacteur = create_new_user(pseudo: 'MaitreRédacteur', grade_forum: 8, sexe: 'H', password: 'motdepasse', mail_confirmed: true)
  @maitreRedacteur = User.get(@dMaitreRedacteur[:id])
  ids_auteurs << @maitreRedacteur.id

  @dExperteEcriture = create_new_user(pseudo: 'ExpertEcriture', grade_forum: 9, sexe: 'F', password: 'motdepasse', mail_confirmed: true)
  @experteEcriture = User.get(@dExperteEcriture[:id])
  ids_auteurs << @experteEcriture.id

  # Création de 50 sujets
  forum_create_sujets 50, {validate: true, auteurs: ids_auteurs}
  # Pour chaque sujet, on va créer de 10 à 100 messages
  # La table @nombre_posts_by_sujet contiendra en clé l'ID du sujet et
  # en valeur son nombre de messages
  params = {
    validate:   true,
    votes:      true,
    authors:    ids_auteurs,
    moderators: [1, 3]
  }
  @nombre_posts_by_sujet = Hash.new
  @all_sujets = all_sujets_forum.shuffle # mélangé (pour public)

  liste_hsujets_non_publics = Array.new

  @all_sujets.each do |hsujet|
    nombre_messages = rand(10..100)
    forum_create_posts( hsujet[:id], nombre_messages, params )
    @nombre_posts_by_sujet.merge!(hsujet[:id] => nombre_messages)
    if liste_hsujets_non_publics.count < 20
      liste_hsujets_non_publics << hsujet
    end
  end
  puts "@nombre_posts_by_sujet = #{@nombre_posts_by_sujet.inspect}"

  liste_hsujets_non_publics.each do |hs|
    s = hs[:specs]
    s[5] = '4'
    site.db.update(:forum,'sujets',{specs: s},{id: hs[:id]})
  end
end

def forum_truncate_all_tables
  site.db.use_database :forum
  forum_tables.each do |table_name|
    site.db.execute("TRUNCATE TABLE #{table_name};")
  end
end


def forum_tables
  @forum_tables ||= ['sujets', 'posts', 'posts_content', 'posts_votes', 'users', 'follows']
end
