# encoding: UTF-8
=begin
  cf. Manuel/Modules/Main_section_methods.md
=end
module MainSectionMethods

  def require_module mod_name
    mod_path = File.join(self.folder,'_lib','_not_required','module',mod_name)
    if File.exist?(mod_path) && File.directory?(mod_path)
      mod_path.gsub(/\.\/__SITE__\//)
      site.load_folder(mod_path)
    elsif File.exist?(mod_path) || File.exist?("#{mod_path}.rb")
      require mod_path
    else
      raise "Le module `#{mod_path}` est introuvable"
    end
  end

end
