# encoding: UTF-8
require 'sass'

class SassSite
class << self


  # Actualise le fichier CSS quelconque +path+ si nécessaire
  # @param  {String}  src_path
  #                   Le fichier SASS qu'il faut peut-être actualiser.
  # @return {String}  dest_path
  #                   Le path du fichier de destination (permet de simplifier)
  #                   les méthodes du site.
  def update_file_if_needed path
    file_upofdate?(path) || update_file(path)
    return dest_file_of_src_file(path)
  end

  # Actualise le fichier ./css/all.css si nécessaire
  def update_all_css_if_needed
    updated_all_required? || return
    update_commons_in_all_css
  end


  # Recompile un fichier SASS particulier à actualiser
  # (hors fichier template)
  #
  # @param {String} path
  #     Chemin d'accès au fichier SASS à transformer
  #     Ce fichier doit exister.
  # @return {Bool} true/false
  #     True si le fichier a pu être créé, false dans le cas contraire.
  #
  def update_file path
    relpath_arr = path.sub(/^(.*?)__SITE__\//,'').split('/')
    rel_mainfolder  = relpath_arr[0]
    rel_subfolder   = relpath_arr[1]

    # PATH DU FICHIER DE DESTINATION
    dest_file_css = dest_file_of_src_file(path)
    # DOSSIER DE DESTINATION
    dest_folder = File.dirname(dest_file_css)
    `mkdir -p "#{dest_folder}"`

    file_code = self.entete_sass
    file_code += File.read(path).force_encoding('utf-8')
    file_code = Sass.compile(file_code, self.data_compilation)
    # On crée le fichier css final
    File.exist?(dest_file_css) && File.unlink(dest_file_css)
    File.open(dest_file_css,'w') { |f| f.write file_code }

    return File.exist?(dest_file_css)
  end

  # @return {TrueClass|FalseClass}
  #         True si le fichier +path+ est à jour, false s'il doit être
  #         actualisé.
  #         Un fichier doit être actualisé lorsque :
  #           1. Il est plus récent que son fichier CSS relatif
  #           2. Le fichier CSS relatif est plus vieux qu'un des fichiers
  #              de définition de la charte.
  def file_upofdate? src_sass
    dest_css = dest_file_of_src_file(src_sass)
    return false if ! File.exist?( dest_css )
    dest_mtime = File.stat(dest_css).mtime
    return false if dest_mtime < File.stat(src_sass).mtime
    return dest_mtime > younger_definition_mtime
  end

  # Retourne la plus récente date de modification d'un des
  # fichier `_<nom>.sass` de définition des paramètres de la charte.
  def younger_definition_mtime
    @older_definition_mtime ||= begin
      tim = nil
      Dir["#{folder_template}/css/_required/_*.sass"].each do |path|
        mtime = File.stat(path).mtime
        if tim.nil? || mtime > tim
          tim = mtime
        end
      end
      tim
    end
  end

  # Retourne le path du fichier de destination (.css) du fichier
  # +path+ (.sass)
  # @return {String} Path du fichier CSS relatif
  # @param {String} Path du fichier source SASS
  def dest_file_of_src_file path
    folder = File.dirname(path).sub(/^(.*?)__SITE__\//,'')
    affixe = File.basename(path, File.extname(path))
    return File.join('.', 'css', folder, "#{affixe}.css")
  end

  # Méthode reconstruisant tout le fichier `all.css` des styles
  # communs
  def update_commons_in_all_css

    File.exist?(all_css_filepath) && File.unlink(all_css_filepath)
    @ref = File.open(all_css_filepath, 'a')

    Dir["#{folder_template}/**/*.sass"].each do |src_path|
      src_path.start_with?('_') && next
      code_sass = File.read(src_path).force_encoding('utf-8')
      @ref.write Sass.compile(entete_sass + "\n\n" + code_sass, data_compilation)
    end

  end


  # @return {Bool}  True/False
  #                 True s'il faut actualiser le fichier général all.css
  def updated_all_required?
    File.exist?(self.all_css_filepath) || (return true)
    all_css_mtime = File.stat(all_css_filepath).mtime
    Dir["#{folder_template}/**/*.sass"].each do |src|
      return true if all_css_mtime < File.stat(src).mtime
    end
  end

  def all_css_filepath
    @all_css_filepath ||= File.join('.','css','all.css')
  end

  # Retourne les définitions à mettre en entête de tous les
  # codes SASS avant de les compiler
  def entete_sass
    @entete_sass ||= begin
      e = []
      Dir["#{folder_template}/css/_required/_*.sass"].each do |path|
        e << File.read(path).force_encoding('utf-8')
      end
      e.join('') + "\n"
    end
  end

  def data_compilation
    @data_compilation ||= begin
      { line_comments: false, style: :compressed, syntax: :sass }
    end
  end

  def folder_template
    @folder_template ||= File.join('.', '__SITE__', 'xTemplate')
  end

end # << self
end # SassSite
