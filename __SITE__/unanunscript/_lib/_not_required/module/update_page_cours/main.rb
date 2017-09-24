# encoding: UTF-8
#
# Ce module est copié du module de la collection Narration, mais ce
# n'est pas exactement le même. Par exemple, pour le programme UAUS, 
# on a pas besoin des liens vers les livres ou les tables des matières,
# ni même des liens vers les pages suivantes/précédentes entendu qu'on
# consulte une page à la fois.
# (voir quand même si ça n'est pas intéressant de pouvoir revenir à une
# page précédente.)
#
class Unan
  class PageCours

    include PropsAndDbMethods

    # Création de la page dynamique .dyn.erb permettant d'afficher
    # rapidement la page du programme UAUS.
    #
    # Note : contrairement à la version précédente, qui écrivait dynamiquement
    # les infos de titre, chapitre, etc., cette version de la page contient
    # tout ce qu'il faut, défini une seule fois.
    #
    def update_page_dyn
      require_folder './lib/utils/md_to_page'
      MD2Page.transpile(
        md_file, 
        {
          raw_pre_code:   pre_code_page,
          raw_post_code:  post_code_page,
          dest:           dyn_file,
        }
      )
    end

    # Retourne le code qui doit être ajouté avant le contenu du fichier
    #
    # Pour le moment, on met les choses minimumales telles que le titre
    # de la page et les liens avant/après.
    def pre_code_page
      <<-HTML
#{div_pages_avant_apres(:top)}
<section id="unan_page_cours-#{id}" class="page_cours">
<h2 class="titre_page">#{data[:titre]}</h2>
      HTML
    end

    # Retourne le code qui doit être ajouté après le contenu du fichier
    # Il s'agit :
    #   - des liens vers les pages avant/après et tdm
    def post_code_page
      <<-HTML
</section>
#{div_pages_avant_apres(:bottom)}
      HTML
    end

    # ---------------------------------------------------------------------
    #
    #   Éléments de page
    #
    # ---------------------------------------------------------------------

    # Retourne le div contenant les liens vers les pages avant et après
    # Contrairement à la page Narration, on n'a pas de table des matières
    # vers un livre.
    def div_pages_avant_apres where
      <<-HTML
<div class="liens_next_previous_pages #{where}">
  <div class="cadre_links">
    <span class="lien_prev_page">#{prev_page_link}</span>
    <span class="lien_main_page">#{lien_bureau}</span>
    <span class="lien_next_page">#{next_page_link}</span>
  </div>
</div>
      HTML
    end

    # Retourne le code HTML du lien vers le bureau
    def lien_bureau
      'Votre bureau'.in_a(href:"unanunscript/bureau/pages") 
    end
    
    # Lien vers la page avant
    def prev_page_link
      prev_page_id != nil || (return '')
      "<a href=\"unanunscript/page_cours/#{prev_page_id}\">←</a>"
    end
    def next_page_link
      next_page_id != nil || (return '')
      "<a href=\"unanunscript/page_cours/#{next_page_id}\">→</a>"
    end

    # ---------------------------------------------------------------------
    #   MÉTHODES DE DONNÉES
    # ---------------------------------------------------------------------

    # Retourne l'index de la page dans la table des matières
    # Permet de récupérer les pages avant/après
    def index_in_tdm
      @index_in_tdm ||= pages_ids.index(id)
    end

    # Retourne la liste des IDs des pages
    # C'est en réalité une liste qui contient des données un peu plus complète
    # que le simple identifiant puisqu'une même page peut être utilisée 
    # plusieurs jours. Donc il faut associer la page à son jour-programme,
    # Rappel : le `wid` est envoyé dans l'url en même temps que l'identifiant
    # de la page, ce qui permet de retrouver le pday de la page.
    def pages_ids
      @pages_ids ||= 
        begin
          Array.new
        end
    end

    def prev_page_id
      @prev_page_id ||= begin
        if index_in_tdm && index_in_tdm > 0
          pages_ids[index_in_tdm - 1][:id]
        else
          nil
        end
      end
    end
    def next_page_id
      @next_page_id ||= begin
        if index_in_tdm && index_in_tdm + 1 < pages_ids.count
          pages_ids[index_in_tdm + 1][:id]
        else
          nil
        end
      end
    end

  end #/PageCours
end #/Unan

