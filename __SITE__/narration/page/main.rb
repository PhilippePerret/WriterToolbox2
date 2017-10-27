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
    end

    # Méthode principale retournant le code de la page (ou du chapitre,
    # du sous-chapitre) à afficher.
    #
    # Si la page n'est pas à jour, il faut l'actualiser.
    def full_content
      uptodate? || begin
        require './__SITE__/narration/_lib/module/update.rb'
        update_dyn_by_type
      end
      deserb(dyn_file)
    end

    def boutons_edition_if_admin
      user.admin? || (return '')
      c = String.new
      c << '<div class="admin_edit_links">'
      c << "<a href=\"admin/narration/#{id}?op=edit_data\" target=\"_new\">data</a>"
      if type == :page
        c << "<a href=\"admin/narration/#{id}?op=edit_text\" target=\"_new\">text</a>"
      end
      c << '</div>'
      return c
    end
    # ---------------------------------------------------------------------
    #
    #     MÉTHODES DE DONNÉES
    #
    # ---------------------------------------------------------------------

    # Retourne TRUE si le fichier dynamique est à jour
    def uptodate?
      exist? &&
      File.exist?(dyn_file) &&
      code_dyna_is_a_jour
    end

    def code_dyna_is_a_jour
      type == :page || ( return true )
      return File.stat(dyn_file).mtime > File.stat(md_file).mtime
    end

    def exist?
      @page_existe === nil && (@page_existe = !data.nil?)
      @page_existe
    end

    # Retourne le type de la page, i.e. :page, :chap ou :schap
    def type
      @type ||= begin
        {'1'=> :page, '2'=> :schap, '3'=> :chap}[data[:options][0]]
      end
    end

    #--------------------------------------------------------------------------------
    #
    #   MÉTHODES D'HELPER
    #
    #--------------------------------------------------------------------------------

    # Nécessaire pour obtenir le path du fichier quand c'est une page
    def livre_folder
      @livre_folder ||= data_livre[:folder]
    end
    def data_livre
      @data_livre ||= Narration::LIVRES[livre_id]
    end
    def livre_id
      @livre_id ||= data[:livre_id]
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
      # C'est la nouvelle méthode, avec un path qui dépend seulement du
      # dossier (ID) et de l'id de la page.
      def def_paths
        case type
        when :page
          affixe_path = File.join(folder_pages,livre_id.to_s,id.to_s)
          @md_file  = "#{affixe_path}.md"
          @dyn_file = "#{affixe_path}.dyn.erb"
        else
          # Pour les chapitres et sous-chapitres
          @dyn_file = File.join(folder_pages, 'xdyn', "#{type}_#{id}.dyn.erb")
        end
      end

      def folder_pages
        @folder_pages ||= File.join('.','__SITE__','narration','_data')
      end
  end #/Page
end #/Narration

def page
  @page ||= Narration::Page.new(site.route.objet_id || 1)
end
