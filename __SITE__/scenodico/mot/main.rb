# encoding: utf-8
# 
class Array
  def as_list_mots data_mots
    self.count > 0 || (return '---')
    self.collect do |mot_id|
      "<a href=\"scenodico/mot/#{mot_id}\">#{data_mots[mot_id][:mot]}</a>"
    end.join(', ')
  end
end
class Scenodico
  class Mot

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
    end

    # -------------------------------------------------------------------------------- 
    #
    #   MÉTHODES D'HELPER
    #
    # -------------------------------------------------------------------------------- 

    # Retourne l'ID (1-a-start) de la lettre du mot, pour composer le lien
    # qui permet de retourner à la liste du mot.
    # Noter que ça retourne un {String}, pour le moment
    def lettre_id
      @lettre_id ||= (terme[0].ord - 64).to_s
    end
    def displayed_terme
      self.terme
    end
    def displayed_definition
      formate(definition)
    end
    def displayed_relatifs
      relatifs.as_list_mots(data_all_relatifs)
    end
    def displayed_synonymes
      synonymes.as_list_mots(data_all_relatifs)
    end
    def displayed_contraires
      contraires.as_list_mots(data_all_relatifs)
    end
    def displayed_categories
      categories != nil || (return '---')
      data_categories.collect do |cid, cdata|
        "<a href=\"scenodico/categorie/#{cdata[:id]}\" class=\"tag\">#{cdata[:hname].downcase}</a>"
      end.join('')
    end
    def displayed_liens
      liens != nil || (return '')
      links = liens.force_encoding('utf-8')
      links = links.split("\n").collect{|l| href, titr = l.split('::'); {href: href, titre: titr}} 
      links.collect do |hlink|
        "<div><a href=\"#{hlink[:href]}\" target=\"_blank\">#{hlink[:titre]}</a></div>"
      end.join('')
    end

    def lien_edit_if_admin
      user.admin? || (return '')
      "<span class=\"span_edit_link\">"+
        "<a href=\"admin/scenodico/#{id}?op=edit_mot\">éditer</a>"+
      "</span>"
    end
    # -------------------------------------------------------------------------------- 
    #
    #   METHODES DE DONNÉES
    #
    # -------------------------------------------------------------------------------- 
    #
    def terme       ; @terme      ||= data[:mot]                    end
    def definition  ; @definition ||= data[:definition]             end
    def relatifs    ; @relatifs   ||= data[:relatifs].as_id_list    end
    def synonymes   ; @synonymes  ||= data[:synonymes].as_id_list   end
    def contraires  ; @contraires ||= data[:contraires].as_id_list  end
    def categories  ; @categories ||= data[:categories].nil_if_empty  end
    def liens       ; @liens      ||= data[:liens].nil_if_empty       end

    # -------------------------------------------------------------------------------- 
    #
    #   METHODES DE DONNÉES VOLATILES
    #
    # -------------------------------------------------------------------------------- 

    def data_categories
      @data_categories ||=
        begin
          h = Hash.new
          categories != nil && 
            begin
              cates = categories.split(' ').collect{|cat| "'#{cat}'"}.join(', ')
              res = site.db.select(:biblio,'categories',"cate_id IN (#{cates})",[:id, :cate_id, :hname])
              res.each { |dcate| h.merge!(dcate[:cate_id] => dcate) };
            end
          h
        end
    end


    # Retourne un Hash qui contient toutes les données des mots en relation
    # avec le mot courant, qu'il soit relatif, contraire ou synonyme.
    def data_all_relatifs
      @data_all_relatifs ||=
        begin
          allids = (relatifs + synonymes + contraires).uniq
          h = Hash.new
          if allids.count > 0
            site.db.select(:biblio,'scenodico',"id IN (#{allids.join(',')})").each do |hmot|
              h.merge!(hmot[:id] => hmot)
            end
          end
          h
        end
    end


    def base_n_table ; @base_n_table ||= [:biblio, 'scenodico'] end

    end #/Mot
  end #/Scenodico

  def mot
    @mot ||= Scenodico::Mot.new(site.route.objet_id || 1)
  end
