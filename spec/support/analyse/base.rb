
# Prépare la base d'une analyse
#
# Benoit est analyste, mais pas de l'analyse courante
#
def prepare_base_analyse params = nil

  params ||= Hash.new

  @film_id = params[:film_id]

  # Il faut faire du film @film_id un film en cours
  hfilm = site.db.select(:biblio,'films_analyses',{id: @film_id}).first
  specs = hfilm[:specs] || '0'*16
  specs[0] = '1'
  specs[5] = '1'
  site.db.update(:biblio,'films_analyses',{specs: specs},{id: @film_id})

  # On crée les deux utilisateurs utiles
  @hANACreator           = get_user_by_pseudo('Boboche') || create_new_user(pseudo: 'Boboche', sexe: 'H', admin: false, analyste: true)
  @hANASimpleCorrector   = get_user_by_pseudo('Michou')  || create_new_user(pseudo: 'Michou', admin: false, analyste: true)
  @hANARedacteur         = get_user_by_pseudo('Patrick') || create_new_user(pseudo: 'Patrick', admin: false, analyste: true)

  # # Débug
  # puts "@hANACreator = #{@hANACreator.inspect}"
  # puts "@hANASimpleCorrector = #{@hANASimpleCorrector.inspect}"
  # puts "@hANARedacteur = #{@hANARedacteur.inspect}"

  expect(@hANACreator).to_not eq nil
  expect(@hANASimpleCorrector).to_not eq nil
  expect(@hANARedacteur).to_not eq nil


  # On détruit tous les fichier et toutes les références aux fichiers
  site.db.use_database(:biblio)
  site.db.execute('TRUNCATE TABLE files_analyses;')
  site.db.execute('TRUNCATE TABLE user_per_file_analyse;')

  # Benoit ne fait rien mais il est analyse
  site.db.delete(:biblio,'user_per_analyse',{film_id: @film_id, user_id: 2})
  opts = site.db.select(:hot,'users',{id: 2},[:options])[0][:options] || '0'*17
  opts = opts.ljust(17,'0')
  opts[16] = '3'
  site.db.update(:hot,'users',{options: opts},{id: 2})

  @hBenoit  = get_data_user(2)


  # Phil ne fait rien
  site.db.delete(:biblio,'user_per_analyse',{film_id: @film_id, user_id: phil.id})

  # Marion ne fait rien
  site.db.delete(:biblio,'user_per_analyse',{film_id: @film_id, user_id: marion.id})

  # Boboche est mis en créateur de l'analyse
  site.db.insert(
    :biblio,
    'user_per_analyse',
    {film_id:@film_id,user_id: @hANACreator[:id], role: 1|32|64|128|256}
  )

  # Patrick est mis en rédacteur occasionnel de l'analyse
  site.db.insert(
    :biblio,
    'user_per_analyse',
    {film_id: @film_id, user_id: @hANARedacteur[:id], role: 1|8}
  )

  # Michou est mis en simple correcteur de l'analyse
  site.db.insert(
    :biblio,
    'user_per_analyse',
    {film_id: @film_id, user_id: @hANASimpleCorrector[:id], role: 1|4}
  )

end
