# encoding: UTF-8
class Narration
  class Page

    include PropsAndDbMethods

    # Méthode principale appelée pour updater la page, pour une vraie
    # page, un chapitre ou un sous-chapitre.
    def update_dyn_by_type
      send("update_dyn_#{type}".to_sym)
    end

    # Actualiser le code dynamique d'un chapitre
    def update_dyn_chap
      File.open(dyn_file,'wb'){ |f|
        f.write <<-HTML
<h3 class="titre_livre">#{titre_livre}</h3>
#{div_pages_avant_apres(:top)}
<div id="page_titre">
  <div class="libelle_titre">Chapitre</div>
  <div class="titre">#{data[:titre]}</div>
</div>
        HTML
      }
    end

    # Actualiser le code dynamique d'un sous-chapitre
    def update_dyn_schap
      File.open(dyn_file,'wb'){ |f|
        f.write <<-HTML
<h3 class="titre_livre">#{titre_livre}</h3>
#{div_pages_avant_apres(:top)}
<div id="page_titre">
  <div class="libelle_titre">Sous-chapitre</div>
  <div class="titre">#{data[:titre]}</div>
</div>
        HTML
      }
    end

    # Création de la page dynamique .dyn.erb permettant d'afficher
    # rapidement la page Narration.
    #
    # Note : contrairement à la version précédente, qui écrivait dynamiquement
    # les infos de titre, chapitre, etc., cette version de la page contient
    # tout ce qu'il faut, défini une seule fois.
    #
    def update_dyn_page
      require_folder './lib/utils/md_to_page'
      MD2Page.transpile(
        md_file, {
          raw_pre_code:   pre_code_page,
          raw_post_code:  post_code_page,
          dest:           dyn_file,
          narration_current_book_id: livre_id
          }
        )
    end

    # Retourne le code qui doit être ajouté avant le contenu du fichier
    #
    # Il s'agit :
    #   - du titre de la collection
    #   - du titre du chapitre/sous-chapitre
    #   - du titre de la page
    #   - des liens vers les pages avant/après et tdm
    def pre_code_page
      <<-HTML
<h3 class="titre_livre">#{titre_livre}</h3>
#{div_pages_avant_apres(:top)}
<section id="page_narration-#{id}" class="page_narration">
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
    # ainsi que le lien vers la table des matières du livre
    def div_pages_avant_apres where

      # Le cadre pour le chapitre/sous-chapitre
      @div_chap_sous_chap =
        case type
        when :page, :schap
          "<div class=\"under_next_prev_links\">#{liens_livres}#{span_chapitre}#{span_sous_chapitre}</div>"
        else
          ''
        end

      <<-HTML
<div class="liens_next_previous_pages #{where}">
  #{where == :top ? '' : @div_chap_sous_chap }
  <div class="cadre_links">
    <span class="lien_prev_page">#{prev_page_link}</span>
    <span class="lien_main_page">#{tdm_livre_link}</span>
    <span class="lien_next_page">#{next_page_link}</span>
  </div>
  #{where == :bottom ? '' : @div_chap_sous_chap }
</div>
      HTML
    end

    # Span lien vers la liste de tous les livres
    def liens_livres
      "<span class=\"fleft\"><a href=\"narration\">Tous les livres</a></span>"
    end

    # Lien vers la page avant
    def prev_page_link
      prev_page_id != nil || (return '')
      "<a href=\"narration/page/#{prev_page_id}\">←</a>"
    end
    def next_page_link
      next_page_id != nil || (return '')
      "<a href=\"narration/page/#{next_page_id}\">→</a>"
    end
    def tdm_livre_link
      "<a href=\"narration/livre/#{livre_id}\">Table des matières</a>"
    end

    # ---------------------------------------------------------------------
    #   MÉTHODES DE DONNÉES
    # ---------------------------------------------------------------------

    # Retourne l'index de la page dans la table des matières
    # Permet de récupérer les pages avant/après
    def index_in_tdm
      @index_in_tdm ||= livre_pages_ids.index(id)
    end

    # Retourne la liste des IDs des pages du livre de la page
    def livre_pages_ids
      @livre_pages_ids ||= site.db.select(:cnarration,'tdms',{id: livre_id})
              .first[:tdm]
              .split(',').collect{|e| e.strip.to_i}
    end

    def prev_page_id
      @prev_page_id ||= begin
        if index_in_tdm > 0
          livre_pages_ids[index_in_tdm - 1]
        else
          nil
        end
      end
    end
    def next_page_id
      @next_page_id ||= begin
        if index_in_tdm + 1 < livre_pages_ids.count
          livre_pages_ids[index_in_tdm + 1]
        else
          nil
        end
      end
    end

    # Retourne le span du titre du chapitre
    def span_chapitre
      debug "Chapitre ID : #{chapitre_id}"
      '<span class="chap_titre">' +
        "<a href=\"narration/page/#{chapitre_id}\">#{titre_chapitre}</a>" +
      '</span>'
    end
    def titre_chapitre
      @titre_chapitre ||= begin
        site.db.select(:cnarration,'narration',{id: chapitre_id},[:titre]).first[:titre]
      end
    end
    def chapitre_id
      @chapitre_id ||= define_chap_and_schap(:chap)
    end
    # Retourne le span du titre du sous-chapitre
    def span_sous_chapitre
      # debug "Sous-chapitre ID : #{sous_chapitre_id}"
      scid, sctitre =
        case type
        when :page
          [sous_chapitre_id, titre_sous_chapitre]
        when :schap
          [id, data[:titre]]
        else
          # Ne doit pas survenir
        end
      '<span class="schap_titre">' +
        "<a href=\"narration/page/#{scid}\">#{sctitre}</a>" +
      '</span>'
    end
    def titre_sous_chapitre
      @titre_sous_chapitre || site.db.select(:cnarration,'narration',{id:sous_chapitre_id},[:titre]).first[:titre]
    end
    def sous_chapitre_id
      @sous_chapitre_id ||= define_chap_and_schap(:schap)
    end

    # Définition du chapitre et du sous-chapitre de la
    # page.
    # Soit ils sont définis dans les options (9e à 14e bit), soit
    # il faut les rechercher et les définir.
    def define_chap_and_schap returned_value
      @chapitre_id = data[:options][8..10].to_s.to_i(36)
      @chapitre_id > 0 || begin
        @chapitre_id = nil
        define_chap_n_schap_of_page
        @chapitre_id = data[:options][8..10].to_s.to_i(36)
      end
      if type == :page
        @sous_chapitre_id = data[:options][11..13].to_s.to_i(36)
      end

      return returned_value == :chap ? @chapitre_id : @sous_chapitre_id
    end

    # Retourne le span pour le titre du livre
    def titre_livre
      "<span class='titre_livre'>#{data_livre[:hname]}</span>"
    end


    # On recherche le chapitre et le sous-chapitre de la page courante, pour
    # les consigner dans les options de la page.
    def define_chap_n_schap_of_page

      # debug "-> define_chap_n_schap_of_page"



      # On recherche jusqu'à ce qu'on ait trouvé notre bonheur
      tole = 0
      while @chapitre_id.nil? || (type == :page && @sous_chapitre_id.nil?)
        tole += 30
        find_chap_id_and_schap_id tole
      end

      # debug "Chapitre : #{@titre_chapitre} (##{@chapitre_id})"
      # debug "Sous-chapitre : #{@titre_sous_chapitre} (##{@sous_chapitre_id})"

      # Redéfinition des options
      opts = data[:options]
      opts.length > 13 || opts = opts.ljust(13,'0')

      chap36  = @chapitre_id.to_s(36).rjust(3,'0')
      schap36 = (@sous_chapitre_id||0).to_s(36).rjust(3,'0')

      opts[8..10]   = chap36
      opts[11..13]  = schap36

      @data[:options] = opts
      # debug "options nouveau : #{@data[:options]}"

      # On enregistre la nouvelle valeur
      set(options: @data[:options])
    end

    def find_chap_id_and_schap_id tole
      # On remonte jusqu'à trouver un sous-chapitre et un chapitre
      # Pour simplifier, on relève les 50 pages précédente
      fromindex = index_in_tdm - tole
      fromindex < 0 && fromindex = 0
      indexes = livre_pages_ids[fromindex..index_in_tdm].reverse

      # debug "Recherche dans les index :#{indexes}"

      chap_id   = nil; chap_titre   = nil
      schap_id  = nil; schap_titre  = nil
      rows = Hash.new
      site.db.select(:cnarration,'narration',"ID IN (#{indexes.join(',')})",[:options,:titre,:id]).each do |row|
        rows.merge!(row[:id] => row)
      end

      # debug "rows : #{rows.inspect}"

      indexes.each do |irow|
        row = rows[irow]
        # debug "row : #{row.inspect}"
        if chap_id.nil? && row[:options][0] == '3'
          chap_id     = row[:id]
          chap_titre  = row[:titre]
          break
        elsif type == :page && schap_id.nil? && row[:options][0] == '2'
          schap_id    = row[:id]
          schap_titre = row[:titre]
        end
      end

      @chapitre_id          = chap_id
      @titre_chapitre       = chap_titre
      @sous_chapitre_id     = schap_id
      @titre_sous_chapitre  = schap_titre
    end
  end #/Page
end #/Narration
