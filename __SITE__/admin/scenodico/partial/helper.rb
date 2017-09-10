# encoding: utf-8
class Site

  # Retourne le code HTML pour les titres des listes de mots "relatifs", "synonymes" et "contraires", avec
  # un span permettant d'indiquer le nombre de mots que contient chaque liste pour le mot courant.
  def label_mot type
    "<label class=\"mots\" for=\"mot_#{type}\">#{type.titleize} (<span id=\"nombre_mots_#{type}\"></span>)</label>"
  end

  # Construit le menu des mots pour les relatifs, synonymes et contraires
  #
  def menu_mots type_mot
    template_menu_mots
    .gsub(/__TYPE__/,type_mot)
    .gsub(/_TYPE_MOT_/,type_mot.titleize)
    .sub(/_VALUE_TYPE_/,mot.send(type_mot.to_sym)||'')
  end
  def template_menu_mots
    @template_menu_mots ||= 
      begin
        '<select size="10" id="menu_mot___TYPE__" class="mots" data-type="__TYPE__" onchange="Scenodico.aor_mot(this)">'+
          site.db.select(:biblio,'scenodico',"id = id ORDER BY mot",[:id,:mot]).collect do |hmot|
          "<option value=\"#{hmot[:id]}\">#{hmot[:mot]}</option>"
          end.join('')+
            '</select>'+
            '<input type="hidden" name="mot[__TYPE__]" id="mot___TYPE__" value="_VALUE_TYPE_" />'
      end
  end


  def menu_categories
    m = String.new
    m << '<select id="menu_categories" onchange="Scenodico.on_choose_categorie(this)">'
    m << "<option value=''>Choisir la catégorie…</option>"
    site.db.select(:biblio,'categories',nil,[:cate_id, :hname, :id]).each do |hcate|
      m << "<option value=\"#{hcate[:cate_id]}\">#{hcate[:hname]}</option>"
    end
    m << '</select>'
    return m
  end

  def lien_show_mot
    mot.id != nil || (return '')
    "<a class=\"small btn\" href=\"scenodico/mot/#{mot.id}\" target=\"_blank\">voir</a>"
  end
  
  # Retourne le code HTML du lien-bouton permettant d'éditer le mot dont on
  # a rentré l'ID
  def lien_edit_mot_by_id
    "<a href=\"#\" class=\"small btn\" onclick=\"return Scenodico.edit_mot.call(Scenodico)\">edit</a>"
  end
    
end #/Site



