# encoding: UTF-8
require 'cgi'
require 'singleton'
require 'erb'
require 'json'

# Charge tout le dossier +relpath+
# Si +dont_check_if_exists+, on ne vérifie pas que le dossier existe. N'est
# pas encore utilisé pour le moment.
def require_folder relpath, dont_check_if_exists = false
  Dir["./#{relpath}/**/*.rb"].each{|m| require m}
end

# Pour pouvoir tout de suite enregistrer des messages de débug
require './lib/utils/debug'

require_folder 'lib/extensions'
require_folder 'lib/required'
require_folder 'lib/site'
require_folder 'lib/user'

# Le singleton du site
def site
  @site ||= Site.instance
end

# Pour voir
# debug "Au début du chargement, site.session['last_page'] = #{site.session['last_page'].inspect}"

# Chargement de la configuration du site courant
site.load_configuration # cf. in lib/site/config.rb

# Reconnection de l'user s'il était connecté
User.reconnect

# Exécution du ticket si nécessaire
param(:tckid) && begin
  require_folder('./lib/procedure/ticket')
  Ticket.exec(param(:tckid))
end

# Exécution d'un script quelconque
# require './lib/procedure/scripts/NOM DU SCRIPT'
# require './lib/procedure/scripts/recuperer_all_quiz'
# require './lib/procedure/scripts/drop_tables'
