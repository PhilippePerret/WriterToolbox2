# encoding: UTF-8
class Site

  # Compile si nécessaire tous les fichiers SASS en un fichier all.css
  # unique contenant tous les styles nécessaire.
  def sass_all
    require './lib/utils/sass_all'
    SassSite.update_all_css_if_needed
  end

  # ---------------------------------------------------------------------
  #   MÉTHODES DE CONSTRUCTION
  # ---------------------------------------------------------------------
  def partial relpath
    # Si `relpath` ne finit pas par '.erb', c'est :
    # - soit un dossier (qui contient notamment un fichier main.erb à charger)
    # - soit un partiel auquel il faut ajouter '.erb'
    fullpath = relpath
    File.exist?(relpath) || begin
      fullpath = "#{route.relative_path}/#{relpath}"
    end
    File.exist?(fullpath) || begin
      fullpath = "#{route.relative_path}/partial/#{relpath}"
    end
    File.exist?(fullpath) || begin
      if fullpath.end_with?('.erb')
        return "[PARTIEL INTROUVABLE : #{fullpath}]"
      else
        return partial(relpath+'.erb')
      end
    end

    if File.directory?(fullpath)
      # Si c'est un dossier, il faut charger tout le dossier et
      # ensuite charger le partiel main.erb qu'il doit contenir
      erbfile = File.join(fullpath,'main.erb')
      File.exist?(erbfile) || begin
        return "[PARTIEL INTROUVABLE : #{erbfile} (dans dossier #{fullpath})]"
      end
      load_folder(fullpath)
      return deserb("#{erbfile}")
    else
      # Si c'est un fichier, on le charge simplement
      return deserb(fullpath)
    end
  end

  # ---------------------------------------------------------------------
  #     MÉTHODES FONCTIONNELLES
  # ---------------------------------------------------------------------

  # Charge n'importe quel fichier main.erb qui se trouve dans
  # __SITE__/<relpath>/
  #
  # (1) Rare cas où il n'existe pas de page main.erb dans le dossier,
  #     lorsque par exemple on doit être tout de suite redirigé vers
  #     autre chose, comme c'est le cas pour la déconnection.
  #
  def load_main relpath, options = nil
    begin
      fullpath = "./__SITE__/#{relpath}/main.erb"
      File.exist?(fullpath) || return # (1)
      deserb(fullpath)
    rescue NotAccessibleViewError => e
      load_error_page('not_accessible', e)
    rescue Exception => e
      debug "PROBLÈME AVEC LA VUE : #{relpath}"
      load_error_page('erb_error', e)
    end
  end

  # Charge n'importe quel élément main.erb qui se trouve dans le dossier
  # des templates ./__SITE__/xTemplate/<relpath>/
  #
  def load_template relpath, version = nil
    # debug "-> load_template(#{relpath}, #{version})"
    version ||= :full
    version = version == :full ? '' : "-#{version}"
    load_folder "xTemplate/#{relpath}"
    temp_path = "./__SITE__/xTemplate/#{relpath}/main#{version}.erb"
    File.exist?(temp_path) ? deserb(temp_path) : ''
  end


  def deserb path
    ERB.new(File.read(path).force_encoding('utf-8')).result(bind)
  end

  # ---------------------------------------------------------------------
  #   CHARGEMENT D'UN DOSSIER DE __SITE__
  # ---------------------------------------------------------------------

  # Charge un dossier de __SITE__
  #
  # Le "charger" signifie qu'on va requérir tous les rubys contenus, qu'on
  # va charger les feuilles CSS et les fichiers Javascript.
  # On actualisera les fichiers SASS si nécessaire.
  #
  # Noter que les fichiers CSS et JS des templates ne sont pas chargés
  # par ce biais. C'est parce qu'ils se trouvent respectivement dans all.css
  # et dans all.js qui contient tous les éléments communs.
  #
  def load_folder relpath
    solid_path = relpath
    File.exist?(solid_path) || solid_path = "./__SITE__/#{relpath}"
    is_not_template = !relpath.start_with?('xTemplate')
    File.exist?(solid_path) || return
    folder_load_ruby solid_path
    if is_not_template
      folder_load_and_transpile_css relpath
      load_javascript_folder solid_path
    end
  end

  # Charge les fichiers du dossier, à commencer par le fichier main.rb
  #
  # Noter qu'à présent, on ne charge que les fichiers qui se trouvent à
  # la racine de solid_path, sans `**/*.rb`
  #
  # Passe seulement le dossier `partial` s'il existe à la racine du
  # dossier
  def folder_load_ruby solid_path
    # On regarde au préalable si le dossier principal contient un sous-dossier
    # de path '_lib/_required' qu'il faut toujours charger.
    # Ce dossier est chargé dans le dossier principal (route.objet) ainsi que
    # dans le sous-dossier de la méthode s'il existe. Cela permet par exemple
    # de charger les librairies spécialisées des sous-dossiers d'administration
    # Noter que les TESTS ne pourront pas passer par ici si l'objet de route
    # n'est pas défini, c'est la raison pour laquelle on ne peut pas faire
    # juste site.load_folder pour charger les _lib/_required.
    route.objet  && require_folder("./__SITE__/#{route.objet}/_lib/_required", true)
    route.method && require_folder("./__SITE__/#{route.objet}/#{route.method}/_lib/_required", true)
    Dir["#{solid_path}/**"].each do |element|
      if File.directory?(element)
        if File.basename(element) != 'partial'
          Dir["#{element}/*.rb"].each{|m|require m}
        end
      elsif element.end_with?('.rb')
        require element
      end
    end
  end

  # On charge les fichier SASS/CSS qui se trouve à la racinde de +relpath+
  # Note : on ne fait plus les fichiers `**/*.sass`
  def folder_load_and_transpile_css relpath
    require './lib/utils/sass_all'

    # Le relpath peut commencer par ./__SITE__/
    relpath.sub!(/^\.\/__SITE__\//,'')

    # Faire la liste des fichiers SASS que peut contenir le dossier principal
    # et le sous-dossier.
    folders     = relpath.split('/')

    # Pour savoir quand on atteindra le bout
    solid_path  = File.join('.','__SITE__', relpath)

    # La méthode de traitement qu'il faudra utiliser, en fonction de
    # La configuration. S'il faut surveiller les fichiers .sass, on regardera
    # si le fichier doit être actualisé et on l'actualisera si nécessaire.
    # Dans le cas contraire, on informera simplement la vue qu'elle doit
    # charger le .css relatif.
    meth = sass_method_per_config

    # On boucle sur chaque dossier pour charger les CSS requis
    # Chaque feuille de styles trouvée est chargée dans la vue (i.e. ajoutée
    # à site@all_css pour être mise dans le HEAD).
    curpath = File.join('.','__SITE__')
    for cfolder in folders
      curpath = File.join(curpath, cfolder)
      # all_sass = Dir["#{curpath}/#{curpath == solid_path ? '**/*.sass' : '*.sass'}"]
      all_sass = Dir["#{curpath}/*.sass"]
      all_sass.each { |src| self.all_css << SassSite.send(meth, src) }
    end
  end

  def sass_method_per_config
    @sass_method_per_config ||= offline? && configuration.watch_sass ? 'update_file_if_needed' : 'dest_file_of_src_file'
  end


  def load_ruby_folder solid_path
    Dir["#{solid_path}/_lib/_required/**/*.rb"].each { |m| require m }
    Dir["#{solid_path}/**"].each do |path|
      if File.directory?( path )
        # debug "* Check Rubies du dossier #{path}"
        ['partial','_lib'].include?(File.basename(path)) && next
        # debug "*** Traitement (ruby) du dossier `#{path}`"
        Dir["#{path}/**/*.rb"].each do |spath|
          # debug "---> requis: #{spath}"
          require spath
        end
      elsif File.extname(path) == '.rb'
        # debug "---> requis: #{path}"
        require path
      end
    end
  end

  def load_css_folder solid_path
    meth = sass_method_per_config
    Dir["#{solid_path}/**"].each do |path|
      if File.directory?(path)
        # debug "* Check CSS du dossier `#{path}`"
        ['partial','_lib'].include?(File.basename(path)) && next
        # debug "*** Traitement du dossier CSS `#{path}`"
        Dir["#{path}/**/*.sass"].each do |spath|
          # debug "---> requis: #{spath}"
          self.all_css << SassSite.send(meth, spath)
        end
      elsif File.extname(path) == '.sass'
        # debug "---> requis: #{path}"
        self.all_css << SassSite.send(meth, path)
      end
    end
  end
  def load_javascript_folder solid_path
    Dir["#{solid_path}/**"].each do |path|
      if File.directory?(path)
        debug "Check JS du dossier #{path}"
        ['partial','_lib'].include?(File.basename(path)) && next
        Dir["#{path}/**/*.js"].each do |spath|
          # debug "---> requis: #{spath}"
          all_javascripts << spath
        end
      elsif File.extname(path) == '.js'
        # debug "---> requis: #{path}"
        all_javascripts << path
      end
    end
  end

  # Tous les fichiers CSS qu'il faut ajouter à la page
  def all_css
    @all_css ||= ['./css/all.css']
  end

  def all_meta
    @all_meta ||= ['charset="utf-8"']
  end

  def all_javascripts
    @all_javascripts ||= begin
      arr = []
      arr += Dir["./js/_required/**/*.js"]
    end
  end

end
