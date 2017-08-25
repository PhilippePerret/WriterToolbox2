# encoding: UTF-8
require 'cgi'
require 'singleton'
require 'erb'
require 'json'

def require_folder relpath
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

# Chargement de la configuration du site courant
site.load_configuration # cf. in lib/site/config.rb

# Reconnection de l'user s'il était connecté
User.reconnect

# Exécution du ticket si nécessaire
param(:tckid) && begin
  require_folder('./lib/procedure/ticket')
  Ticket.exec(param(:tckid))
end
