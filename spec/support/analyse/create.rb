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

# Crée des fichiers factices pour une analyse et retourne les
# données.
# Note : on s'assure que
def create_files_analyse analyse_id, nombre, options = nil
  # Si on passe par ici, il faut absolument protéger les données biblio qui
  # vont être modifiées. On doit les sauver si nécessaire et demander leur
  # rechargement.
  backup_base_biblio # seulement si nécessaire
  protect_biblio

  contributors = site.db.select(:biblio,'user_per_analyse',{film_id: analyse_id})
  nombre_conts = contributors.count
  nombre_conts > 0 || raise("Impossible de créer les données sans contributeurs pour l'analyse #{analyse_id}")

  files = Array.new

  # On le fait, pour le moment, juste pour obtenir la 
  # constante FILES_TYPES
  require_folder './__SITE__/analyser/_lib/_required/'


  nombre.times do |i|

    specs     = '0'*16
    type_file = rand(10) # type du fichier
    specs[1]  = type_file.to_s
    # Extension du fichier en fonction du type
    ext = Analyse::AFile::FILES_TYPES[type_file][:ext] || 'md'

    data_file = {
      titre: "Fichier ##{i+1} pour l'analyse #{analyse_id}",
      film_id: analyse_id,
      specs:   specs
    }
    file_id = site.db.insert(:biblio,'files_analyses',data_file)
    data_file.merge!(id: file_id)

    # Une fois que la donnée a été construite, on peut :
    # 1. créer physiquement le fichier
    # 2. le confier à un contributeur de l'analyse

    ffolder= File.expand_path("./__SITE__/analyser/_data_/files/#{analyse_id}")
    fpath = File.expand_path("#{ffolder}/#{file_id}.#{ext}")
    File.exist?(fpath) || begin
      `mkdir -p "#{ffolder}"`
      File.open(fpath,'wb'){|f| f.write("# Un fichier de type #{type_file} pour voir\n\n")}
      # On ajoute ce fichier à détruire
      add_file_2_destroy fpath
    end

    hauteur_fichier = contributors[rand(nombre_conts)]
    # puts "Auteur fichier : #{hauteur_fichier.inspect}"
    data_user_file = {
      file_id: file_id,
      user_id: hauteur_fichier[:user_id],
      role:    1
    }
    data_file.merge!(user_id: data_user_file[:user_id])
    site.db.insert(:biblio,'user_per_file_analyse', data_user_file)


    files << data_file
  end

  return files

end

# Liste de tâches pour factory
ACTIONS_ANALYSES = [
  'Relire le fichier spécifié',
  'Demander une correction pour le fichier spécifié',
  'Approfondir le fichier spécifié',
  'Mettre en forme la structure du fichier spécifié',
  'Faire une proposition de correction',
  'Corriger le fichier spécifié',
  'Annoncer la fin de l’analyse du film',
  'Annoncer le nouveau fichier concernant le film',
  'Passer le fichier en version publique'
]
NOMBRE_ACTIONS_ANALYSES = ACTIONS_ANALYSES.count

# Création de tâche
# =================
#
#
# Note : si des tâches et des fichiers doivent être créés, il faut
# faire les fichiers d'abord, afin de pouvoir "hériter" de ces fichiers pour
# leur adjoindre des tâches.
#
def create_taches_analyse analyse_id, nombre, options = nil
  # Si on passe par ici, il faut absolument protéger les données biblio qui
  # vont être modifiées. On doit les sauver si nécessaire et demander leur
  # rechargement.
  backup_base_biblio # seulement si nécessaire
  protect_biblio

  contributors = site.db.select(:biblio,'user_per_analyse',{film_id: analyse_id})
  nombre_conts = contributors.count

  # On prend aussi les fichiers qui ont pu être créé
  hfiles = site.db.select(:biblio,'files_analyses', {film_id: analyse_id})
  nombre_files = hfiles.count

  taches = Array.new

  nombre.times do |i|
    data_task = {
      action:  ACTIONS_ANALYSES[rand(NOMBRE_ACTIONS_ANALYSES)],
      user_id: contributors[rand(nombre_conts)][:id],
      film_id: analyse_id,
      echeance: Time.now.to_i + rand(100000)*3600, # Toutes dans le futur
      file_id: hfiles[rand(nombre_files)][:id],
      specs:   "10000000"
    }
    task_id = site.db.insert(:biblio,'taches_analyses', data_task)

    taches << data_task.merge!(id: task_id)

  end

  return taches
end
