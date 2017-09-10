=begin

  Méthodes communes pour les tests concernant les bases de données

  Pour pouvoir utiliser ces méthodes, la feuille de tests doit appeler
  la méthode en haut de page :

    require_db_support

  db_prepare <requete>

    Préparation d'une requête. Retourne le statement à utiliser.
    Par exemple :
      db_client.query('use `boite-a-outils_hot`')
      sta = db_prepare('SELECT * FROM users WHERE id = ?')
      res = sta_execute(12)

  truncate_table_users

    Vide la table hot.users en gardant seulement les administrateurs.
    L'appel de cette méthode crée automatiquement la sauvegarde des
    données si nécessaire, mais ne force pas leur rechargement en fin
    de test.
    Détruit également toutes les données dans boite-a-outils_users_tables,
    ainsi que tous les programmes UAUS qui, en toute logique, doivent être
    vides.

=end
require 'mysql2'
# ---------------------------------------------------------------------
#
#     MÉTHODES D'INITIALISATION DES BASES DE DONNÉES MYSQL
#
# Ces méthodes permettent de repartir d'une configuration de MySql
# absolument vierge, avec seulement les databases créées, mais sans
# autres tables que hot.users avec Phil comme administrateur.
#
# Noter que ces méthodes supprimeront TOUTES LES TABLES de TOUTES
# LES BASES. Pour garder certaines tables, il faut mettre leur
# nom dans les options, dans la propriété :except :
#     options = {except: ['cnarration', 'unan']}
# Noter cependant que dans ce cas, le test devra au préalable recharger
# toutes les données qui ont pu être supprimées avant.
#
# @usage
#
#     before :all do
#       init_db_for_test[( options )]
#     end
#     after :all do
#       reset_db_after_test
#     end
#
# NE SURTOUT PAS OUBLIER LE AFTER :ALL (qui recharge toutes les
# données).
#
# En cas d'oubli ou de problème, on peut aller dans le dossier
#  ~/xbackups/ et lire le fichier READ ME pour récupérer les données
# précédentes.
#
# ---------------------------------------------------------------------

require_lib_site

# ---------------------------------------------------------------------
#
#     MÉTHODES POUR LES TESTS
#
# ---------------------------------------------------------------------

# Vidage de la table des actualités
def truncate_table_updates
  site.db.use_database(:cold)
  site.db.execute('TRUNCATE TABLE updates;')
end

def truncate_table_variables user_id # ou 0 pour le site
  site.db.use_database(:users_tables)
  site.db.execute("TRUNCATE TABLE variables_#{user_id}")
end

# Vidage de la table des tickets
def truncate_table_tickets
  site.db.use_database(:hot)
  site.db.execute('TRUNCATE TABLE tickets;')
end

# Détruit tous les users, sauf les administrateurs (de 1 à 50) et met
# le prochain ID à 51.
# Détruit également toutes les tables qui peuvent être associées
def truncate_table_users

  # On commence par faire un backup de toutes les données actuelles,
  # mais seulement si ce backup "du jour" n'a pas encore été fait.
  backup_all_data_si_necessaire

  db_client.query('use `boite-a-outils_hot`;')
  db_client.query('DELETE FROM users WHERE id > 9;')
  db_client.query('ALTER TABLE users AUTO_INCREMENT=51;')

  db_client.query('use `boite-a-outils_users_tables`;')
  db_client.query('SHOW TABLES;').each do |row|
    table_name = row.values.first
    if table_name.start_with?('variables_')
      if table_name.split('_')[1].to_i < 10
        next
      end
    end
    db_client.query("DROP TABLE #{table_name};")
    puts "Table `#{table_name}` détruite"
  end

  # Destruction de tous les projets et tous les programmes
  db_client.query('use `boite-a-outils_unan`;')
  db_client.query('DELETE FROM programs;')
  db_client.query('ALTER TABLE programs AUTO_INCREMENT=1;')
  db_client.query('DELETE FROM projets;')
  db_client.query('ALTER TABLE projets AUTO_INCREMENT=1;')

  # Destruction de tous les résultats de tous les quiz
  db_client.query('SHOW DATABASES;').each do |row|
    dbname = row.values.first
    dbname.start_with?('boite-a-outils_quiz') || next
    db_client.query("use `#{dbname}`;")
    db_client.query('DELETE FROM resultats;')
    db_client.query('ALTER TABLE resultats AUTO_INCREMENT=1;')
  end

  # Destruction de tous les tickets
  db_client.query('use `boite-a-outils_hot`;')
  db_client.query('DELETE FROM tickets;')
  db_client.query('ALTER TABLE tickets AUTO_INCREMENT=1;')


end

# Méthode qui resette les tables tests de la base de données
def init_db_for_test options = nil

  # Si options définit la propriété `except` avec des bases à conserver,
  # il faut au préalable recharger toutes les données.
  if options && options.key?(:except) && options[:except].count > 0
    File.exist?(backup_all_data_filepath) && db_retrieve_all_data
  else
    options ||= {}
    options.merge!(except: [])
  end

  backup_all_data_si_necessaire

  begin
    db_client.query('SET FOREIGN_KEY_CHECKS=1;')

    db_client.query('SHOW DATABASES;').each do |row|
      dbname = row['Database'] || row[:Database]
      dbname.start_with?('boite-a-outils_') || next

      # Si c'est une base à passer, on la passe
      dbname_tested = dbname.sub(/^boite-a-outils_/,'')
      options[:except].include?(dbname_tested) && next

      # On détruit la table et on la reconstruit aussitôt (vide)
      begin
        db_client.query("DROP DATABASE `#{dbname}`;")
        db_client.query("CREATE DATABASE `#{dbname}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
      rescue Exception => e
        puts "Impossible de vider la base de données `#{dbname}`… #{e.message}"
      end
    end
  rescue Exception => e
    puts e
  ensure

    db_client.query('SET FOREIGN_KEY_CHECKS=1;')

    begin
      # On crée à présent les données minimales, c'est-à-dire la table des
      # user avec un administrateur.
      table_users = site.dbm_table(:hot, 'users')
      table_users.insert({
        id: 1,
        pseudo:     'Phil',
        mail:       'phil@laboiteaoutilsdelauteur.fr',
        patronyme:  'Philippe Perret',
        cpassword:  'f8249542b30c37e5021db2d02a86bb44',
        salt:       'marion',
        options:    '79100000000000000000000000000000',
        sexe:       'H',
        created_at: 1453317001,
        updated_at: Time.now.to_i
      })
    rescue Exception => e
      puts "Malheureusement, la donnée Phil n'a pas pu être créée…"
      puts e
    end
  end

  db_client.close
end


# ---------------------------------------------------------------------
#
#     MÉTHODES FONCTIONNELLES
#
# ---------------------------------------------------------------------
def db_use db_name
  db_client.query("use `#{configuration_site.db_bases_prefix}_#{db_name}`")
end

def db_query request
  db_client.query(request).map{|row|row}
end

def db_prepare requete
  db_client.prepare(requete)
end

def db_exec_statement statement, values
  statement.execute(*values).map{|row|row}
end
alias :db_execute_statement :db_exec_statement

def db_client
  @db_client ||= begin
    dclient = {:host => db_data_offline[:host],:username => db_data_offline[:username],:password   => db_data_offline[:password]}
    c = Mysql2::Client.new(dclient)
    c.query_options.merge!(:symbolize_keys => true)
    c
  end
end

# Fichier du jour qui contiendra toutes les données de toutes les bases
def backup_all_data_filename
  @backup_all_data_filename ||= "all_dbs_#{Time.now.strftime('%Y-%m-%d')}.sql"
end
def backup_all_data_filepath
  @backup_all_data_filepath ||= File.join(Dir.home,'xbackups',backup_all_data_filename)
end

# return {Hash} Les données de connextion à MySQl en local
def db_data_offline
  @db_data_offline ||= begin
    require './__SITE__/_config/data/secret/mysql.rb'
    DATA_MYSQL[:offline]
  end
end

# Méthode faisant un backup des données narrations
def backup_narration
  File.exist?(backup_narration_filepathofday) || begin
    # Avant de procéder au backup, on s'assure que l'autoincrément est bon
    db_use(:cnarration)
    last_id = db_client.query('SELECT id FROM narration ORDER BY id DESC LIMIT 1;').first.values.first
    db_client.query("ALTER TABLE narration AUTO_INCREMENT=#{last_id};")
    puts "last_id Narration : #{last_id}"
    puts "Appeler la méthode `retreive_data_narration` pour récupérer les données narration"
    `mkdir -p ~/xbackups;cd ~/xbackups;mysqldump -u root -p#{db_data_offline[:password]} --databases 'boite-a-outils_cnarration' > #{backup_narration_filenameofday}`
    puts "= Backup complet des données exécuté dans #{backup_narration_filepathofday} ="
  end
  puts "\nRécupérer les données initiales de Narration en appelant la méthode\n`retreive_data_narration` à la fin de la session de test\n(chercher 'retreive_data_narration' dans le spec_helper.rb).\n"
end

def retreive_data_narration
  File.exist?(backup_narration_filepathofday) && begin
    `cd ~/xbackups;mysql -u root -p#{db_data_offline[:password]} < #{backup_narration_filepathofday}`
  end
end

def backup_narration_filenameofday
  @backup_narration_filenameofday ||= begin
    "narration_bckup_#{Time.now.strftime('%Y-%m-%d')}.sql"
  end
end
def backup_narration_filepathofday
  @backup_narration_filepathofday ||= begin
    File.join(Dir.home,'xbackups',backup_narration_filenameofday)
  end
end

# ---------------------------------------------------------------------
#
#   BACKUP DE LA TABLE BIBLIO (Scénodico, Filmodico, etc.)
#
# ---------------------------------------------------------------------
def backup_base_biblio
  File.exist?(backup_biblio_filepath_of_day) || begin
    puts "Appeler la méthode `retreive_base_biblio` pour récupérer les données Biblio"
    `mkdir -p ~/xbackups;cd ~/xbackups;mysqldump -u root -p#{db_data_offline[:password]} --databases 'boite-a-outils_biblio' > #{backup_biblio_filepath_of_day}`
    puts "= Backup complet des données exécuté dans #{backup_biblio_filepath_of_day} ="
  end
  puts "\nRécupérer les données initiales de la base Biblio en appelant la méthode\n`retreive_base_biblio` à la fin de la session de test\n(chercher 'retreive_base_biblio' dans le spec_helper.rb).\n"

end
def retreive_base_biblio
  File.exist?(backup_biblio_filepath_of_day) && begin
    `cd ~/xbackups;mysql -u root -p#{db_data_offline[:password]} < #{backup_biblio_filepath_of_day}`
  end
end
def backup_biblio_filepath_of_day
  @backup_biblio_filepath_of_day ||= begin
    File.join(Dir.home,'xbackups',backup_biblio_filename_of_day)
  end
end
def backup_biblio_filename_of_day
  @backup_biblio_filename_of_day ||= begin
    "biblio_bckup_#{Time.now.strftime('%Y-%m-%d')}.sql"
  end
end


# Sauf toutes les données de toutes les bases si nécessaire
# "Si nécessaire" signifie : s'il n'existe pas un fichier du jour contenant
# déjà toutes les données.
def backup_all_data_si_necessaire
  File.exist?(backup_all_data_filepath) || begin
    `mkdir -p ~/xbackups;cd ~/xbackups;mysqldump -u root -p#{db_data_offline[:password]} --all-databases > #{backup_all_data_filename}`
    puts "= Backup complet des données exécuté dans #{backup_all_data_filepath} ="
  end
end

# Recharge toutes les données des bases de données
# Note : peut être appelé à la fin de tous les tests comme à l'intérieur
# d'un test
def db_retrieve_all_data
  File.exist?(backup_all_data_filename) && begin
    `cd ~/xbackups;mysql -u root -p#{db_data_offline[:password]} < #{backup_all_data_filename}`
  end
end


# À la fin des tests, on peut remettre toutes les données des
# databases
# Note : on peut aussi les recharger quand l'option :except est défini, pour
# conserver certaines bases.
def reset_db_after_test
  db_retrieve_all_data
end
