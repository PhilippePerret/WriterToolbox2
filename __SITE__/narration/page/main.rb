# encoding: utf-8
#
# Pour l'affichage d'un page de la collection Narration
#
class Narration
  class Page

    attr_reader :id, :data
    attr_reader :dyn_file, :md_file

    # Instanciation
    def initialize pid
      @id = pid
      get_data
      type == :page && def_paths
      # debug "md_file = #{md_file}"
    end

    # Retourne le type de la page, i.e. :page, :chap ou :schap
    def type
      @type ||= begin
        {'1'=> :page, '2'=> :schap, '3'=> :chap}[data[:options][0]]
      end
    end

    def exist?
      @page_existe === nil && (@page_existe = !data.nil?)
      @page_existe
    end

    # Retourne TRUE si le fichier dynamique est à jour
    def uptodate?
      exist? && File.exist?(dyn_file) && File.stat(dyn_file).mtime > File.stat(md_file).mtime
    end

    #--------------------------------------------------------------------------------
    #
    #   MÉTHODES D'HELPER
    #
    #--------------------------------------------------------------------------------

    def livre_folder
      @livre_folder ||= data_livre[:folder]
    end
    def data_livre
      @data_livre ||= Narration::LIVRES[livre_id]
    end
    def livre_id
      @livre_id ||= data[:livre_id]
    end

    def full_content
      uptodate? || begin
        require './__SITE__/narration/_lib/module/update.rb'
        update_dyn_page
      end
      deserb(dyn_file)
    end
    #--------------------------------------------------------------------------------
    #
    #   MÉTHODES DE CONSTRUCTION DE LA PAGE
    #
    #--------------------------------------------------------------------------------

    def base_n_table ; @base_n_table ||= [:cnarration, 'narration'] end


    private

      def get_data
        @data = site.db.select(:cnarration,'narration',{id:id}).first
      end

      # Méthodes qui définit les différentes paths de la page courante
      def def_paths
        affixe_path = File.join(folder_pages,livre_folder, data[:handler])
        @md_file  = "#{affixe_path}.md"
        @dyn_file = "#{affixe_path}.dyn.erb"
      end

      def folder_pages
        @folder_pages ||= File.join('.','__SITE__','narration','_data')
      end
  end #/Page
end #/Narration

def page
  @page ||= Narration::Page.new(site.route.objet_id || 1)
end
