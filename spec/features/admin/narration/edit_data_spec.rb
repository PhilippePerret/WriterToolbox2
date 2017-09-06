=begin

  Test de l'édition des données d'une page

=end

require_lib_site
require_support_integration
require_support_db_for_test

feature "Édition des données d'une page" do
  before(:all) do
    # Avant d'opérer, on crée une fausse page pour pouvoir la détruire
    # ensuite. On la met avec un identifiant haut
    nid = 100000000
    while site.db.count(:cnarration,'narration',{id:nid}) > 0
      nid += 1
    end
    @data_fake_page = {
      id:             nid,
      titre:          'Ma page de test n\'est pas mauvaise',
      description:    'Description de la page de test',
      options:        '1a00',
      handler:        'tests/test',
      livre_id:       nil,
      created_at:     NOW,
      updated_at:     NOW,
      completed_at:   nil
    }

    site.db.insert(:cnarration,'narration',@data_fake_page)
    # === Vérifier que la page a été créée ===
    expect(site.db.count(:cnarration,'narration',{id:nid})).to eq 1
  end

  after(:all) do
    # On détruit la page qu'on a créé pour les besoins du test
    nid = @data_fake_page[:id]
    site.db.delete(:cnarration,'narration',{id: nid})
    # === Vérifier que la page a été détruite ===
    expect(site.db.count(:cnarration,'narration',{id:nid})).to eq 0
  end

  def url_edit_page page_id
    "#{base_url}/admin/narration/#{page_id}?op=edit_data"
  end

  scenario "Un visiteur quelconque ne peut pas éditer une page" do
    visit url_edit_page(12)
    expect(page).not_to have_tag('h2',text: "Administration collection Narration")
    expect(page).to have_content("Vous n’êtes pas autorisé à rejoindre la page demandée, désolé.")
  end

  scenario '=> Un administrateur peut éditer les données d’une page' do
    identify phil
    visit url_edit_page(@data_fake_page[:id])
    expect(page).to have_tag('h2',text: "Administration collection Narration")

    hpage = site.db.select(:cnarration,'narration',{id: @data_fake_page[:id]}).first

    # Niveau de développement
    nivdev    = hpage[:options][1].to_i(11)
    only_web  = hpage[:options][2]
    priority  = hpage[:options][3]

    expect(page).to have_tag('form', with:{id: "narration_edit_data_form"}) do
      # ID
      with_tag('input', with:{id: 'page_id', value: @data_fake_page[:id].to_s, type: 'text'})
      # TITRE
      with_tag('input', with:{id: 'page_titre', value: hpage[:titre].gsub(/'/,'’'), type: 'text'})
      # TYPE
      with_tag('select', with:{id: 'page_type'})
      expect(page.find("select#page_type option[value=\"#{hpage[:options][0]}\"]")).to be_selected
      # LIVRE
      with_tag('select', with:{id: 'page_livre_id'})
      expect(page.find("select#page_livre_id option[value=\"#{hpage[:livre_id]}\"]")).to be_selected
      # HANDLER
      with_tag('input', with:{id:'page_handler', name:'page[handler]', value: hpage[:handler]})
      # CB TYPE WEB/PAPIER
      with_tag('label', with:{for:'page_only_web'}, text: 'Version en ligne seulement (pas papier)')
      dweb = {type: 'checkbox', name:'page[only_web]', id:'page_only_web'}
      only_web == '1' && dweb.merge!(checked: 'CHECKED')
      with_tag('input', with: dweb)
      # DESCRIPTION
      with_tag('textarea', with:{id:'page_description'}, text: hpage[:description])
      # DÉVELOPPEMENT
      with_tag('select', with:{id:'page_nivdev', name:'page[nivdev]'}, selected: nivdev.to_s)
      # MENU PRIORITÉ
      with_tag('select', with:{id:'page_priority', name:'page[priority]'})
      # CB CRÉER LE FICHIER
      with_tag('label', with:{for:'page_create_file'}, text: 'Créer le fichier s’il n’existe pas.')
      with_tag('input', with:{type:'checkbox', id:'page_create_file'})

    end
    expect(page.find('input#page_create_file')).to be_checked
    expect(page).to have_button 'Enregistrer'
    success 'la page contient un formulaire valide'



    pending 'crée le fichier s’il n’existe pas et que la case est cochée'
    pending 'NE crée PAS le fichier s’il n’existe pas et que la case est décochée'


  end
end
