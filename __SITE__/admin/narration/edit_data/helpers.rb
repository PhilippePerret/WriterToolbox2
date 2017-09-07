# encoding: utf-8
class Site


  # retourne le code HTML pour les boutons utiles pour une page,
  # par exemple le bouton qui permet d'éditer son texte ou de l'afficher
  def div_boutons_if_page
    (page.page? && page.in_livre?) || (return '')
    c = String.new
    c << '<div id="utils_page_buttons">'
    c << edit_text_button
    c << show_page_button
    c << '</div>'
    return c
  end
  def edit_text_button
    "<a href=\"admin/edit_text?path=#{CGI.escape page.md_file}\" target=\"_new\">texte</a>" 
  end
  def show_page_button
    "<a href=\"narration/page/#{page.id}\" target=\"_new\">afficher</a>"
  end
  def menu_livres params 
    require './__SITE__/narration/_lib/_required/constants'
    params.merge!(values: Narration::LIVRES, id: 'page_livre_id', name: 'page[livre_id]', class: 'medium',
                 first_option: '<option value="">Aucun livre</option>')
    Form.build_select(params)
  end

  def menu_type_page params = nil
    values = [
      ['1', 'page'],
      ['2', 'sous-chapitre'],
      ['3', 'chapitre'],
      ['5', 'texte type']
    ]
    params.merge!(values: values, id: 'page_type', name: 'page[type]', class: 'max-medium')
    Form.build_select(params)
  end


  # Menu pour le niveau de développement
  #
  def menu_niveau_developpement params
    params.merge!(values: Narration::NIVEAUX_DEVELOPPEMENT, id: 'page_nivdev', name: 'page[nivdev]', class: 'medium')
    Form.build_select(params)
  end


  # Menu pour la priorité de correction de la page
  #
  def menu_priorite params
    params.merge!(values: Narration::PRIORITIES, id: 'page_priority', name: 'page[priority]', class: 'medium')
    Form.build_select(params)
  end

end #/Site
