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
  # puts "JE RECRÉE TOUTES LES DONNÉES FORUM"
  puts "*** Nécessité de recréer toutes les données FORUM ***"
  # Effacement de toutes les tables
  require_support_db_for_test
  forum_truncate_all_tables
  truncate_table_users

  ids_auteurs = [1,2,3]
  @drene = create_new_user(pseudo: 'René', sexe: 'H', password: 'motdepasserene')
  @rene = User.get(@drene[:id])
  ids_auteurs << @rene.id
  @dlise = create_new_user(pseudo: 'Lise', sexe: 'F', password: 'motdepasselise')
  @lise = User.get(@dlise[:id])
  ids_auteurs << @lise.id
  @dbenoit = create_new_user(pseudo: 'Benoit', sexe: 'H', password: 'motdepassebenoit')
  @benoit = User.get(@dbenoit[:id])
  ids_auteurs << @benoit.id
  @dmaude = create_new_user(pseudo: 'Maude', sexe: 'F', password: 'motdepassemaude')
  @maude  = User.get(@dmaude[:id])
  ids_auteurs << @maude.id
  # On fait des auteur avec des grand bien particuliers

  @dApprentiSurveilled = create_new_user(pseudo: 'ApprentiSurveillé', grade: 3, sexe: 'H', password: 'motdepasse')
  @apprentiSurveilled = User.get(@dApprentiSurveilled[:id])
  ids_auteurs << @apprentiSurveilled.id


  @dSimpleRedactrice = create_new_user(pseudo: 'SimpleRedactrice', grade: 4, sexe: 'F', password: 'simpleredactrice')
  @simpleRedactrice = User.get(@dSimpleRedactrice[:id])
  ids_auteurs << @simpleRedactrice.id

  @dRedacteur = create_new_user(pseudo: 'Rédacteur', grade: 5, sexe: 'H', password: 'vrairedacteur')
  @redacteur = User.get(@dRedacteur[:id])
  ids_auteurs << @redacteur.id

  @dRedacteurEmerite = create_new_user(pseudo: 'RédacteurEmérite', grade: 6, sexe: 'H', password: 'motdepasse')
  @redacteurEmerite = User.get(@dRedacteurEmerite[:id])
  ids_auteurs << @redacteurEmerite.id

  @dRedactriceConfirmee = create_new_user(pseudo: 'RédactriceConfirmée', grade: 7, sexe: 'F', password: 'motdepasse')
  @redactriceConfirmee = User.get(@dRedactriceConfirmee[:id])
  ids_auteurs << @redactriceConfirmee.id

  @dMaitreRedacteur = create_new_user(pseudo: 'MaitreRédacteur', grade: 8, sexe: 'H', password: 'motdepasse')
  @maitreRedacteur = User.get(@dMaitreRedacteur[:id])
  ids_auteurs << @maitreRedacteur.id

  @dExperteEcriture = create_new_user(pseudo: 'ExperteEcriture', grade: 9, sexe: 'F', password: 'motdepasse')
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
