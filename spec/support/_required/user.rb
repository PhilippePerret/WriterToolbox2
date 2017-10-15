

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

# Retourne les données d'un user choisi au hasard
# Le fabrique si nécessaire.
#
# Les paramètres peuvent mettre certaines contraintes
# @param {Hash} params
#               :in         Array d'IDs. L'ID de l'user doit être parmi ces
#                           identifiants.
#               :not_in     Array d'IDs. L'user ne doit pas avoir l'un de
#                           ces identifiants.
#
#               :sexe       'H' ou 'F' pour avoir un homme ou une femme
#
#               :grade_min  Il faut que l'user ait au moins ce grade
#               :grade_max  Il faut que l'user ait au plus ce grade
#               :grade      Il faut que l'user ait ce grade
#
#               :admin      Si true, il faut un admin. Si false, il ne faut
#                           pas un admin.
#
#               :analyste   Si true, est passé en analyste de niveau indifférent
#                           c'est-à-dire 3. Sinon, si Fixnum, est cherché comme
#                           analyste (17e bit).
# =>                        Si false, on ne doit pas avoir d'analyste
#
def get_data_random_user params = nil

  defined?(Site) || require_lib_site

  params ||= Hash.new
  wheres = Array.new

  if params[:not_in]
    wheres << "id NOT IN (#{params[:not_in].join(', ')})"
  end
  if params[:in]
    wheres << "id IN (#{params[:in].join(', ')})"
  end

  if params[:sexe]
    wheres << "sexe = '#{params[:sexe]}'"
  end

  if params[:grade_min]
    wheres << "CAST(SUBSTRING(options,2,1) AS UNSIGNED) >= #{params[:grade_min]}"
    wheres << "CAST(SUBSTRING(options,2,1) AS UNSIGNED) >= #{params[:grade_min]}"
  elsif params[:grade_max]
    wheres << "CAST(SUBSTRING(options,2,1) AS UNSIGNED) <= #{params[:grade_max]}"
  elsif params[:grade].is_a?(Fixnum)
    wheres << "SUBSTRING(options,2,1) = '#{params[:grade]}'"
  end

  if params.key?(:analyste)
    if params[:analyste] === false
      wheres << "CAST(SUBSTRING(options,17,1) AS UNSIGNED) = 0"
    else
      params[:analyste] === true && params[:analyste] = 3
      wheres << "SUBSTRING(options,17,1) = '#{params[:analyste]}'"
    end
  end

  case params[:admin]
  when true   then wheres << "CAST(SUBSTRING(options,1,1) AS UNSIGNED) > 0"
  when false  then wheres << "CAST(SUBSTRING(options,1,1) AS UNSIGNED) = 0"
  when nil
    # Ne rien faire
  end

  wheres =
    if wheres.count > 0
      "WHERE #{wheres.join(' AND ')}"
    else '' end

  request = <<-SQL
  SELECT id FROM users
  #{wheres}
  LIMIT 20
  SQL

  site.db.use_database(:hot)
  result = site.db.execute(request)
  if result.count == 0
    # => Aucun user n'a été trouvé
    # <= On le créé ou on génère une erreur
    #

    # = Débug =
    # puts "Aucun user trouvé avec la requête : #{request}"

    if params[:in]
      raise 'Impossible de trouver un user dans le rang d’IDs fourni.'
    end
    require_support_db_for_test
    duser = {mail_confirmed: true}
    if params[:grade]
      duser.merge!(grade: params[:grade])
    elsif params[:grade_min]
      duser.merge!(grade: [params[:grade_min] + 1,9].min)
    elsif params[:grade_max]
      duser.merge!(grade: [params[:grade_max]-1,1].max)
    end
    params[:is_admin] && duser.merge!(admin: true)
    params.key?(:analyste) && duser.merge!(analyste: params[:analyste])
    # puts "Je crée l'user voulu avec les données #{duser.inspect}"
    return create_new_user(duser)
  else
    # => Des users ont été trouvés.
    # <= On en prend un parmi ceux-là.
    uid = result.shuffle.shuffle.first[:id]
    return get_data_user(uid)
  end
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
