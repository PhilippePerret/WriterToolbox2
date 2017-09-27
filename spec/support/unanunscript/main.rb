

# Méthode créant un auteur un an un scrit avec les paramètres
# fournis
#
# En plus des paramètres habituels pouvant définir l'user, on
# peut trouver dans params :
#   :time_start       Le temps de départ du programme
#   :rythme           Le rythme du programme (5 par défuat)
#   :current_pday     Le jour-programme courant (1 par défaut)
#   :current_pday_start   Le time de démarrage du pday courant
#   :program_options  Pour régler les options du programme.
#   :projet_options   Pour régler les options du projet
#
# Cette méthode crée un nouvel utilisateur (féminin par défaut) et
# l'inscript "artificiellement" au programme.
#
# NOTES
# =====
#     * Par défaut, le mail de l'user est confirmé. Mettre
#       mail_confirmed: à false dans les +params+ dans le cas contraire.
#
# @return {Hash} hdata
#                 Le hash de toutes les données utilisées ou calculées pour
#                 l'auteur.
#
def unanunscript_create_auteur params = nil
  require_lib_site
  require_support_db_for_test

  params ||= Hash.new

  require_folder('./__SITE__/unanunscript/signup/main')
  require_folder('./__SITE__/unanunscript/_lib/_required')

  # Si un jour-programme est déterminé dans les paramètres, mais que
  # :start_time ne l'est pas, on règle ce :start_time pour qu'il
  # corresponde, en tenant compte du rythme défini ou 5 par défaut
  if params.key?(:current_pday) && params[:current_pday] > 1
    if ! params.key?(:start_time)
      rythme = params[:rythme] || 5
      coef_rythme = 5.0 / rythme
      pday_duree = 24*3600 / coef_rythme
      params[:start_time] = Time.now.to_i - ( params[:current_pday] * pday_duree)
      puts "Jour-programme réglé à : #{params[:current_pday]}"
      puts "=> début du programme réglé à : #{Time.at(params[:start_time])}"
    end
  end

  # On crée un nouvel utilisateur inscrit au site (mais pas abonné)
  # Par défaut, son mail sera confirmé
  params.key?(:mail_confirmed) || params.merge!(mail_confirmed: true)
  huser = create_new_user(params) # dans le support db

  # Instance de l'user, pour la création du programme et du projet
  u = User.get(huser[:id])

  # Paiement pour le programme
  # ==========================
  require './lib/utils/paiement'
  Paiement.new({
    id:       'PAY-000000000000',
    user_id:  u.id,
    objet_id: '1AN1SCRIPT',
    montant:  {total: 19.8}
  }).save

  # Programme
  # =========
  # On crée son programme
  program_id = Unan::UUProgram.create_program_for(u)

  # Projet
  # =======
  # On crée son projet
  projet_id = Unan::UUProjet.create_projet_for(u, {program_id: program_id})
  hparam_projet = Hash.new
  params[:start_time]     && hparam_projet.merge!(created_at: params[:start_time])
  params[:projet_options] && hparam_projet.merge!(options: params[:projet_options])
  # S'il y a des données à régler dans le projet, on le fait
  if hparam_projet.keys.count > 0
    projet = Unan::UUProjet.new(projet_id)
    projet.set(hparam_projet)
  end

  # Si des paramètres sont définis pour le programme, il faut les régler
  hparam_program = {
    projet_id:            projet_id,
    rythme:               params[:rythme] || 5,
    current_pday:         params[:current_pday] || 1,
    current_pday_start:   params[:current_pday_start] || Time.now.to_i
  }
  params[:start_time]       && hparam_program.merge!(created_at: params[:start_time])
  params[:program_options]  && hparam_program.merge!(options: params[:program_options])

  program = Unan::UUProgram.new(program_id)
  program.set(hparam_program)

  params.merge!(
    program_id:   program_id,
    projet_id:    projet_id,
    program:      program
  )

  return params.merge(huser)
end


def goto_bureau_unan onglet = nil
  url = "#{base_url}/unanunscript/bureau"
  onglet && url << "/#{onglet}"
  visit url
end
