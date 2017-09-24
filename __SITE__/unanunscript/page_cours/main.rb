# encoding: utf-8

# Seul un auteur du programme ou un administrateur peut passer par ici
#
user.unanunscript? || user.admin? || raise('Section interdite.')

#
# Pour l'affichage d'une page de cours du programme UN AN UN SCRIPT.
# Noter que c'est presque le même module que pour la collection Narration
#
class Unan
  class PageCours

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
        Unan.require_module('update_page_cours')
        update_page_dyn
      end
      deserb(dyn_file)
    end

    def boutons_edition_if_admin
      user.admin? || (return '')
      c = String.new
      c << '<div class="admin_edit_links">'
      c << "<a href=\"admin/unanunscript/#{id}?op=edit_data\" target=\"_new\">data</a>"
      if type == :page
        escaped_path = CGI.escape(md_file)
        c << "<a href=\"admin/edit_text?path=#{escaped_path}\" target=\"_new\">text</a>"
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
      return File.stat(dyn_file).mtime > File.stat(md_file).mtime
    end

    def exist?
      @page_existe === nil && (@page_existe = !data.nil?)
      @page_existe
    end

    # Retourne le type de la page, i.e. :page, :chap ou :schap
    # Je conserve ça de la collection Narration, mais normalement c'est inutile
    # ici puisqu'il n'y a que des pages de cours dans le programme UAUS. On pourra
    # supprimer cette propriété.
    def type
      :page
    end

    #--------------------------------------------------------------------------------
    #
    #   MÉTHODES DE CONSTRUCTION DE LA PAGE
    #
    #--------------------------------------------------------------------------------

    def base_n_table ; @base_n_table ||= [:unan, 'pages_cours'] end


    private

      def get_data
        @data = site.db.select(:unan,'pages_cours',{id:id}).first
      end

      # Méthodes qui définit les différentes paths de la page courante
      # C'est la nouvelle méthode, avec un path qui dépend seulement du
      # dossier (ID) et de l'id de la page.
      def def_paths
        affixe_path = File.join(folder_pages,id.to_s)
        @md_file  = File.join(folder_pages,'source', "#{id}.md")
        @dyn_file = File.join(folder_pages,'dyn', "#{id}.dyn.erb")
      end

      def folder_pages
        @folder_pages ||= File.join('.','__SITE__','unanunscript','page_cours','_text_')
      end
  end #/Page
end #/Narration

# Retourne l'instance {Unan::PageCours} de la page de cours courante.
# Noter qu'elle doit toujours être définie et que si aucun identifiant n'est inscrit,
# alors la méthode raise de façon fatale.
# Noter que pour passer par ici l'auteur doit forcément être un auteur unanunscript ou
# un administrateur. C'est vérifié avant, en haut de ce module.
def page
  @page ||= Unan::PageCours.new(site.route.objet_id || raise('Vous ne pouvez pas atteindre cette page.'))
end
