# encoding: utf-8

=begin

Ce script doit être utilisé une seule fois, en chargeant une page de Narration et doit
permettre de transformer les paths des fichiers, pour les mettres tous dans des dossiers 
numérotés (livre id) avec pour affixe simplement l'ID de la page.

=end
class Narration
  class << self

    # Méthode principale qui va copier tous les fichiers actuels vers leurs nouvelles
    # path.
    def move_all_files
      debug "Nombre de fichiers : #{all_files.count}"
      all_files.each do |hpage|
        if File.exist?(old_path_md(hpage))
          oldpath = old_path_md(hpage)
          newpath = new_path_md(hpage)
          
          # Il faut construire le dossier si nécessaire
          folder  = File.dirname(newpath)
          `mkdir -p "#{folder}"`

          # Copie du fichier
          `cp "#{oldpath}" #{newpath}`
          debug "Move : #{oldpath}\n"+"To   : #{newpath}"

          # Vérification 
          unless File.exist?(newpath)
            debug "### PROBLÈME : Le fichier de destination n'existe pas"
          end
          
          if File.exist?(old_path_dyn(hpage))
            oldpath = old_path_dyn(hpage)
            newpath = new_path_dyn(hpage)

            `cp "#{oldpath}" "#{newpath}"`
            debug "Move : #{oldpath}\n"+"To   : #{newpath}"

            unless File.exist?(newpath)
              debug "### PROBLÈME : Le fichier de destination n'existe pas"
            end

          else
            debug "Le fichier #{old_path_dyn(hpage)} n'existe pas"
          end
        else
          debug "Le fichier #{old_path_md(hpage)} n'existe pas"
        end

      end #/ fin de boucle sur tous les fichiers
    end

    def old_path_md hpage
      "#{old_path_affixe(hpage)}.md"
    end
    def old_path_dyn hpage
      "#{old_path_affixe(hpage)}.dyn.erb" 
    end
    def old_path_affixe hpage
      File.join(folder_pages, folder_livre(hpage), hpage[:handler])
    end
    def folder_livre hpage
      Narration::LIVRES[hpage[:livre_id]][:folder]
    end

    def new_path_md hpage
      "#{new_path_affixe(hpage)}.md"
    end
    def new_path_dyn hpage
      "#{new_path_affixe(hpage)}.dyn.erb"
    end
    def new_path_affixe hpage
      File.join(folder_pages, hpage[:livre_id].to_s, hpage[:id].to_s)
    end

    def all_files
      @all_files || site.db.select(:cnarration,'narration',"handler IS NOT NULL")
    end


    def folder_pages
      @folder_pages ||= File.join('.','__SITE__','narration','_data')
    end
  end #/Class
end #/Narration


# Narration.move_all_files
