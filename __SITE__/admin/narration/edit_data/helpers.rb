# encoding: utf-8
class Site


  def file_md_path
    
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
    values = [
      [0, '--- correction ---'],
      [1, 'correction normale'],
      [4, 'correction rapide'],
      [7, 'correction prioritaire']
    ]
    params.merge!(values: values, id: 'page_priority', name: 'page[priority]', class: 'medium')
    Form.build_select(params)
  end

end #/Site
