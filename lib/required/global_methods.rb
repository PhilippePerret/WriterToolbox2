
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

# cf. Manuel > Vues > Formatage.md
def formate code, options = nil
  defined?(MD2Page) || require_folder('./lib/utils/md_to_page')
  res = MD2Page.transpile(nil,{dest:nil, code: code.force_encoding('utf-8')})
  if options && options[:deserb]
    res = ERB.new(res).result(options[:bind] || site.bind)
  end
  return res
end
alias :kramdown :formate

# TODO Cette méthode n'a pas été testée
def formate_file path
  defined?(MD2Page) || require_folder('./lib/utils/md_to_page')
  MD2Page.transpile(path,{dest:nil})
end
alias :kramdown_file :formate_file

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
  if cible == :last_page || cible == :last_route
    cible = site.session['last_page']
  end
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
def full_link href, titre = nil, css = nil
  simple_link("http://#{site.configuration.url_online}/#{href}", titre, css)
end

def bulle message, type, style = nil
  style.nil? || style = " style=\"#{style}\""
  <<-HTML
  <p class="bulle #{type}"#{style}>
    <img src="./img/ui/bulle-#{type}.png" class="bulle" />
    <span>#{message}</span>
  </p>
  HTML
end

# Raccourci pour faire un débug
# Cf. ./lib/site/debug.rb
def debug ca
  return if site.online? && !user.admin?
  Debug.debug ca
end

def require_folder folder, check_if_exist = false
  return if check_if_exist && !File.exist?(folder)
  site.load_ruby_folder(folder)
  site.load_javascript_folder(folder)
  site.load_css_folder(folder)

end
# Cf. Manuel > Librairies_et_modules.md
def require_lib path
  objet, affixe = path.split(':')
  p = "./__SITE__/#{objet}/_lib/library/#{affixe}"
  if File.exist?(p) && File.directory?(p)
    require_folder(p)
  elsif File.exist?("#{p}.rb")
    require p
  else
    raise "La librairie #{p} est introuvable."
  end
end
alias :require_library :require_lib

# Méthode appelée pour charger tous les éléments utiles aux formulaires,
# qui ne sont pas chargés par défaut.
#
# Noter qu'on n'utilise pas `require_folder` car on doit faire un chargement
# complet, avec les CSS et les JS.
def require_form_support
  site.load_folder 'xUtils/form'
end

def identification_required message = nil
  site.session['route_after_login'] = site.uri
  redirect_to('user/signin', message || "Pour atteindre la page demandée, vous devez être identifié.")
end
def administrator_only mess = nil
  user.admin? && return # OK
  user.identified? || identification_required(mess)
  raise NotAccessibleViewError.new(mess||'Cette opération nécessite des privilèges d’administrateur.')
end
alias :only_administrator :administrator_only
