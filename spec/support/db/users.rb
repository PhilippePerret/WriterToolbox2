=begin

  Pour utiliser ces méthodes de test, ajouter cette ligne en haut des feuilles
  de test :

    require_db_support

=end

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
def create_new_user duser = nil

  require_lib_site

  udata = get_data_for_new_user(duser)

  # === CRÉATION ===
  udata[:id] = site.db.insert(:hot, 'users', udata)

  return udata.merge(password: password)
end

# Envoyer au moins le mot de passe car il ne sera pas renvoyé (c'est le
# mot de passe crypté qui le sera)
# 
def get_data_for_new_user duser = nil
  duser ||= Hash.new

  nows = Time.now.to_i.to_s(36)

  # ATTENTION ! NE PAS AJOUTER D'AUTRES DONNÉES, CAR ELLES SERVENT
  # À ÊTRE ENREGISTRÉES DANS LA BDD
  udata = {
    pseudo:     duser[:pseudo]    || "NewUser#{nows}",
    patronyme:  duser[:patronyme] || "NewU Ser#{nows}",
    sexe:       duser[:sexe]      || 'F',
    mail:       duser[:mail]      || "new.user.#{nows}@mail.com",
    options:    duser[:options]   || '0000000000',
    salt:       duser[:salt]      || 'dusel',
    cpassword:  nil
  }
  require 'digest/md5'
  password  = duser[:password] || 'monmotdepasse'
  udata[:cpassword] = Digest::MD5.hexdigest("#{password}#{udata[:mail]}#{udata[:salt]}")

  return udata
end
