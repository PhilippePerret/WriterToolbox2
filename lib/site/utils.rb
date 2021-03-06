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
    rescue Exception => e
      debug "PROBLÈME AVEC LA VUE : #{relpath}"
      raise e
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
    File.exist?(solid_path) || begin
      solid_path = "./__SITE__/#{relpath}"
    end
    is_not_template = !relpath.start_with?('xTemplate')
    File.exist?(solid_path) || return
    folder_load_ruby solid_path
    if is_not_template
      folder_load_css relpath
      folder_load_javascript solid_path
    end
  end

  # Charge les fichiers du dossier, à commencer par le fichier main.rb
  #
  # Passe seulement le dossier `partial` s'il existe à la racine du
  # dossier
  def folder_load_ruby solid_path
    # On regarde au préalable si le dossier principal contient un sous-dossier
    # de path '_lib/_required' qu'il faut toujours charger
    route.objet && begin
      objet_required_folder = "./__SITE__/#{route.objet}/_lib/_required"
      File.exist?( objet_required_folder ) && begin
        require_folder( objet_required_folder )
      end
    end
    Dir["#{solid_path}/**"].each do |element|
      if File.directory?(element)
        if File.basename(element) != 'partial'
          Dir["#{element}/**/*.rb"].each{|m|require m}
        end
      elsif element.end_with?('.rb')
        require element
      end
    end
  end
  def folder_load_css relpath
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
    meth = offline? && configuration.watch_sass ? 'update_file_if_needed' : 'dest_file_of_src_file'

    # On boucle sur chaque dossier pour charger les CSS requis
    # Chaque feuille de styles trouvée est chargée dans la vue (i.e. ajoutée
    # à site@all_css pour être mise dans le HEAD).
    curpath = File.join('.','__SITE__')
    for cfolder in folders
      curpath = File.join(curpath, cfolder)
      all_sass = Dir["#{curpath}/#{curpath == solid_path ? '**/*.sass' : '*.sass'}"]
      !all_sass.empty? || next
      all_sass.each { |src| self.all_css << SassSite.send(meth, src) }
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

  def folder_load_javascript solid_path
    Dir["#{solid_path}/**/*.js"].each do |path|
      all_javascripts << path
    end
  end

end
