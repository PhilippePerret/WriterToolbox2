
# raccourci pour obtenir ou définir le paramètre +p+
def param p,v=nil,f=nil; site.param(p,v,f) end

# Deserbe le fichier de chemin +path+ et le retourne
# Note : c'est toujours `site` qui est bindé aux vues
# Astuce : pour définir le path d'un fichier par rapport au module qui
# appelle `deserb`, on peut utiliser une méthode comme `thisfolder` définie
# par `File.dirname(__FILE__)`
def deserb path, bindee = nil
  path.end_with?('.erb') || path << '.erb'
  if File.exist?(path)
    ERB.new(File.read(path).force_encoding('utf-8')).result(bindee || site.bind)
  else
    "[Le fichier ERB #{path} est introuvable]"
  end
end

# Formate un texte quelconque
# cf. Manuel > Markdown.md
def formate code
  defined?(MD2Page) || require_folder('./lib/utils/md_to_page')
  MD2Page.transpile(nil,{dest:nil, code: code})
end

# Pour écrire un message d'erreur dans la page
# Cf. ./lib/site/flash.rb
def __error message
  site.flash.error message
end

# Pour écrire un simple message dans la page
# Cf. ./lib/site/flash.rb
def __notice message
  site.flash.notice message
end

def redirect_to cible, hmessage = nil
  hmessage && begin
    hmessage.is_a?(String) && hmessage = [hmessage, :notice]
    hmessage[1] == :notice ? __notice(hmessage[0]) : __error(hmessage[0])
  end
  site.flash.messages_for_redirection
  cible.is_a?(Array) && cible = cible.join('/')
  puts site.cgi.header('status'=>'REDIRECT', 'location'=>"http://#{site.url}/#{cible}")
end

# Pour produire un lien simple, à partir du href et
# du titre, avec optionnellement une class CSS
def simple_link href, titre = nil, css = nil
  css = css ? " class=\"#{css}\"" : ''
  "<a href=\"#{href}\"#{css}>#{titre || href}</a>"
end

# Raccourci pour faire un débug
# Cf. ./lib/site/debug.rb
def debug ca
  return if site.online? && !user.admin?
  Debug.debug ca
end

# Méthode appelée pour charger tous les éléments utiles aux formulaires,
# qui ne sont pas chargés par défaut.
#
# Noter qu'on n'utilise pas `require_folder` car on doit faire un chargement
# complet, avec les CSS et les JS.
def require_form_support
  site.load_folder 'xUtils/form'
end

def identification_required message = nil
  uri = ENV['REQUEST_URI'].split('/')
  uri.shift
  site.offline? && uri.shift
  site.session['route_after_login'] = uri.join('/')
  redirect_to('user/signin', message || "Pour atteindre la page demandée, vous devez être identifié.")
end
