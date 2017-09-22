=begin

  Utiliser ce faux-test pour faire des essais en live.

  Il crée un auteur du programme et le dirige vers son bureau de
  travail. Puis il s'arrête la durée STOP_TIME ci-dessous (en minutes)

  On renvoie les informations sur l'auteur créé, afin de pouvoir consulter
  en direct ses tables, etc.

=end

# Temps de sommeil du test (pour l'essai)
STOP_TIME = 30 # En minutes
# Jour-programme de l'auteur
AUTEUR_PDAY = 10



require_support_integration
require_support_unanunscript


feature "Pour tester en live" do
  scenario "Un auteur rejoint son bureau et attend…" do

    hauteur = unanunscript_create_auteur(current_pday: AUTEUR_PDAY)
    # puts "Auteur programme UAUS créé : #{hauteur.inspect}"
    identify( mail: hauteur[:mail], password: hauteur[:password])
    visit "#{base_url}/unanunscript/bureau"

    sleep STOP_TIME * 60

  end
end
