# encoding: utf-8
#
# Gestion de l'affichage de la table des matières du livre choisi
# ou du premier livre.
#
# L'ID du livre se trouve dans site.route.objet_id ou est mis à 1
#

class Narration

  class Livre

    ORANGE_BALL = '<img src="./img/pictos/rond-orange.png" style="width:10px;" />'
    GREEN_BALL  = '<img src="./img/pictos/rond-vert.png" style="width:10px;" />'
    NONE_BALL   = '<img src="./img/pictos/rond-none.png" style="width:10px;" />'

    attr_reader :id

    def initialize bid
      @id = bid
    end

    # Retourne le titre du livre courant
    def titre
      @titre ||= LIVRES[id][:hname] 
    end

    # Retourne le code HTML de la table des matières du livre
    # 
    def tdm
      @tdm ||= "<ul class=\"tdm livre_tdm\">#{lis_pages}</ul>"
    end
    
    # Retourne le code HTML de tous les LI des pages et des titres de
    # la table des matières du livre courant.
    #
    def lis_pages
      @lis_pages ||= 
        begin
          page_ids.collect do |page_id|
            # Noter qu'il peut s'agir d'une page comme d'un titre
            dpage = pages[page_id]
            tpage = dpage[:options][0]
            devpage = dpage[:options][1].to_i(11)

            is_page     = tpage == '1'
            is_readable = !is_page || devpage >= 4

            # = MARQUE DE DÉVELOPPEMENT =
            #
            # Si c'est une page, on met une marque en fonction de
            # son niveau de développement.
            mark_dev =
              if devpage < 4
                is_page ? NONE_BALL : ''
              elsif devpage < 8
                ORANGE_BALL
              else
                GREEN_BALL
              end

            # = TITRE =
            titre = mark_dev + dpage[:titre]

            # = LIEN (même pour le titres) =
            titre_formated =
              if is_readable
                link = "<a href=\"narration/page/#{page_id}\" title=\"Page ##{page_id}\">#{titre}</a>"
              else
                "<span class=\"unreadable\">#{titre}</span>"
              end

            # TODO 
            # Quand user.admin? il faut ajouter les boutons d'édition pour les pages

            # = LI =
            "<li id=\"page-#{page_id}\" class=\"niv#{tpage}\">#{titre_formated}</li>"
          end.join('')
        end
    end


    # Hash contenant en clé l'identifiant de la page/titre et en
    # valeur son Hash (TODO On mettra peut-être son instance si
    # ça vaut le coup mais je ne pense pas)
    def pages
      @pages ||=
        begin
          h = Hash.new
          site.db.select(:cnarration,'narration',{livre_id: id},[:id,:titre,:options]).each do|row|
            h.merge!(row[:id] => row)
          end; h
        end
    end

    # Retourne la liste des IDs de page/titre du livre
    def page_ids
      @page_ids ||= 
        begin
          site.db.select(:cnarration,'tdms',{id: id})
            .first[:tdm]
            .split(',')
            .collect { |n| n.to_i }
        end
    end

  end #/Livre


  class Page

    attr_reader :id

    def initialize pid
      @id = pid
    end


  end
end #/Narration

# Le livre affiché, concerné par ce chargement. Soit il est défini
# par l'objet_id de la route, soit on le met à 1 quand la route est
# simplement `narration/livre`
#
def livre
  @livre ||= begin
               Narration::Livre.new(site.route.objet_id || 1)
             end
end
