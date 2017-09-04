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
      def_paths
      # debug "md_file = #{md_file}"
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

    # Retourne le span pour le titre du livre
    def titre_livre
      "<span class='titre_livre'>#{data_livre[:hname]}</span>"
    end
    def livre_folder
      @livre_folder ||= data_livre[:folder]
    end
    def data_livre
      @data_livre ||= Narration::LIVRES[livre_id]
    end
    def livre_id
      @livre_id ||= data[:livre_id]
    end

    # Titre de la page
    def titre
      "<span class='titre_page'>#{data[:titre]}</span>"
    end

    def content
      uptodate? || update
      deserb(dyn_file)
    end


    #--------------------------------------------------------------------------------
    #
    #   MÉTHODES DE CONSTRUCTION DE LA PAGE
    #
    #--------------------------------------------------------------------------------

    # Actualise le fichier dynamique lorsqu'il n'est pas à jour.
    def update
      require_folder './lib/utils/md_to_page'
      MD2Page.transpile( md_file, {dest: dyn_file, narration_current_book_id: livre_id} )
    end


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
