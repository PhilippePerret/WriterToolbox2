

# Retourne la liste des Hash de chaque contributeur de l'analyse
# du film +film_id+
#
# Noter que par convénience, on ajoute la clé :id au champ, mais originellement
# c'est la clé :user_id qui est utilisée.
#
def contributors film_id
  defined?(Site) || require_lib_site
  site.db.select(:biblio,'user_per_analyse',{film_id: film_id}).collect do |h|
    h.merge!(id: h[:user_id])
  end
end
