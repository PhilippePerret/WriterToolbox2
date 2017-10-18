=begin

  Pour la création de données factory

=end


# Créer de toutes pièces une analyes pour +howner+ avec les
# données/options +options+
#
# @param {Hash} howner
#               Données du créateur
# @param {hash} options
#               Données pour créer l'analyse
#               :film_id      ID dans le filmodico (#256 par défaut, Ali)
#               :current      TRUE si c'est une analyse en cours
#               :visible      Si TRUE, peut être visible pour quiconque
#               :relecture    Si TRUE, en relecture
#               :complete     Si TRUE, elle est achevée
#
# @return {Hash}
#         Les options auxquelles on a ajouté les données manquantes, par
#         exemple l'identifiant du film.
def create_analyse_for howner, options

  # Si on passe par ici, il faut absolument protéger les données biblio qui
  # vont être modifiées. On doit les sauver si nécessaire et demander leur
  # rechargement.
  backup_base_biblio # seulement si nécessaire
  protect_biblio

  # Un enregistrement dans le filmodico
  # -----------------------------------
  # NON, on prend un film qu'on n'analysera certainement pas
  options[:film_id] ||= 256
  film_id = options[:film_id]

  # On vérifie qu'il n'existe pas d'analyse de ce film
  # ---------------------------------------------------
  # Mesure de sécurité évidente
  specs_test = site.db.select(:biblio,'films_analyses',{id: film_id},[:specs])[0][:specs]
  specs_test.nil? || specs_test[0] != '1' || raise("Impossible de prendre le film ##{film_id}, il possède déjà une analyse.")
  nombre = site.db.count(:biblio,'user_per_analyse',{film_id: film_id})
  nombre == 0 || raise("Impossible de prendre le film ##{film_id}, on trouve une référence à ce film dans `user_per_analyse`")

  # Enregistrement dans films_analyses
  # -------------------------------------
  # En fait, on doit simplement modifier les specs de l'enregistrement qui
  # doit obligatoirement exister pour le film.
  visible   = options[:visible]   ? '1' : '0'
  current   = options[:current]   ? '1' : '0'
  relecture = options[:relecture] ? '1' : '0'
  complete  = options[:complete]  ? '1' : '0'
  specs = "1000#{visible}#{current}#{relecture}#{complete}"
  site.db.update(:biblio,'films_analyses',{specs: specs}, {id: film_id})
  options.merge!(specs: specs)

  # Enregistrement dans user_per_analyse
  # ----------------------------------------
  site.db.insert(:biblio,'user_per_analyse',{
    user_id:  howner[:id],
    film_id:  film_id,
    role:     1|32|64|128|256
    })

  return options.merge!(id: film_id)

end
