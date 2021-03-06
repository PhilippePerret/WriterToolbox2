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
def get_data_for_new_user duser = nil
  duser ||= Hash.new

  mail_is_conf = duser[:mail_confirmed]

  nows = Time.now.to_i.to_s(36)

  # ATTENTION ! NE PAS AJOUTER D'AUTRES DONNÉES, CAR ELLES SERVENT
  # À ÊTRE ENREGISTRÉES DANS LA BDD
  udata = {
    pseudo:     duser[:pseudo]    || "NewUser#{nows}",
    patronyme:  duser[:patronyme] || "NewU Ser#{nows}",
    sexe:       duser[:sexe]      || 'F',
    mail:       duser[:mail]      || "new.user.#{nows}@mail.com",
    options:    duser[:options]   || "00#{mail_is_conf ? '1' : '0'}0000000",
    salt:       duser[:salt]      || 'dusel',
    password:   duser[:password]  || 'motdepasse', # sera retiré
    cpassword:  nil
  }
  require 'digest/md5'
  udata[:cpassword] = Digest::MD5.hexdigest("#{udata[:password]}#{udata[:mail]}#{udata[:salt]}")

  return udata
end
