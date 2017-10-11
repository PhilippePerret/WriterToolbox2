

def phil
  @phil ||= begin
    defined?(User) || require_lib_site
    User.get(1)
  end
end

def marion
  @marion ||= begin
    defined?(User) || require_lib_site
    User.get(3)
  end
end

# Retourne les données pour l'user d'ID +uid+ (mais le mot de passe)
#
# Retourne aussi le password qui, pour les tests, a été enregistré dans la
# variable 'password' de l'user
#
def get_data_user uid
  reader = User.get(uid)
  site.db.select(:hot,'users',{id: uid}).first.merge!(password: reader.var['password'])
end


def data_phil
  @data_phil ||= begin
    require './__SITE__/_config/data/secret/data_phil'
    DATA_PHIL
  end
end

def data_marion
  @data_marion ||= begin
    require './__SITE__/_config/data/secret/data_marion'
    DATA_MARION
  end
end
