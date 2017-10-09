=begin

  Pour utiliser ces méthodes de test, ajouter cette ligne en haut des feuilles
  de test :

    require_db_support

=end


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
  db_client.query('use `boite-a-outils_users_tables`')
  db_client.query('SHOW TABLES;').each do |row|
    tblname = row.values.first
    tblname.start_with?('quiz_') || next
    db_client.query("DROP TABLE #{tblname};")
  end

  # Destruction de tous les tickets
  db_client.query('use `boite-a-outils_hot`;')
  db_client.query('DELETE FROM tickets;')
  db_client.query('ALTER TABLE tickets AUTO_INCREMENT=1;')

  # Destruction de toutes les tables de forum
  require './spec/support/forum/main.rb'
  db_client.query('use `boite-a-outils_forum`;')
  forum_tables.each do |table_name|
    db_client.query("TRUNCATE TABLE IF EXISTS #{table_name}")
  end

end


def db_get_user_by_pseudo pseudo
  db_client.query('use `boite-a-outils_hot`;')
  statement = db_client.prepare('SELECT * FROM users WHERE pseudo = ?')
  statement.execute(pseudo).each do |row|
    return row
  end
end

def db_get_user_by_id uid
  db_client.query('use `boite-a-outils_hot`;')
  statement = db_client.prepare('SELECT * FROM users WHERE id = ?')
  statement.execute(uid).each do |row|
    return row
  end
end


# Crée un utilisateur dans la base de donnée à partir de +duser+ si
# fourni et retourne toutes les données.
#
# Ajouter `mail_confirmed: true` pour faire un user qui a confirmé
# son email.
def create_new_user duser = nil

  require_lib_site

  udata = get_data_for_new_user(duser)
  # Noter que :password a été ajouté à udata. Il faut
  # retirer cette propriété qui n'est pas enregistrée
  passw = udata.delete(:password)

  # === CRÉATION ===
  udata[:id] = site.db.insert(:hot, 'users', udata)

  return udata.merge!(password: passw)
end

# Envoyer au moins le mot de passe car il ne sera pas renvoyé (c'est le
# mot de passe crypté qui le sera)
#
# Ajouter mail_confirmed: true à +duser+ pour faire un user qui a confirmé
# son email.
#
class User
  # Pour obtenir un nom vraiment unique, même lorsqu'on en crée
  # plusieurs à la suite.
  def self.__icreateduser
     @@icreateduser ||= 0
     @@icreateduser += 1
  end
end
def get_data_for_new_user duser = nil
  duser ||= Hash.new

  mail_is_conf = duser[:mail_confirmed]

  nows = (Time.now.to_i + User.__icreateduser).to_s(36)

  # ATTENTION ! NE PAS AJOUTER D'AUTRES DONNÉES, CAR ELLES SERVENT
  # À ÊTRE ENREGISTRÉES DANS LA BDD
  udata = {
    pseudo:     duser[:pseudo]    || "NewUser#{nows}",
    patronyme:  duser[:patronyme] || "NewU Ser#{nows}",
    sexe:       duser[:sexe]      || 'F',
    mail:       duser[:mail]      || "new.user.#{nows}@mail.com",
    options:    duser[:options]   || "0#{duser[:grade]||1}#{mail_is_conf ? '1' : '0'}0000000",
    salt:       duser[:salt]      || 'dusel',
    password:   duser[:password]  || 'motdepasse', # sera retiré
    cpassword:  nil
  }
  require 'digest/md5'
  udata[:cpassword] = Digest::MD5.hexdigest("#{udata[:password]}#{udata[:mail]}#{udata[:salt]}")

  return udata
end
