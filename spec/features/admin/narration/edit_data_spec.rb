=begin

  Test de l'édition des données d'une page

=end

require_lib_site
require_support_integration
require_support_db_for_test

# Crée un page narration dans la table
#
# ATTENTION : il vaut mieux penser à détruire cette page en fin
# de test en appelant la méthode :
# remove_page_narration_test(page_id)
# @return {Hash}  page_data
#                 L'intégralité des données enregistrées
def create_page_narration_test params = nil

  params ||= Hash.new

  # Avant d'opérer, on crée une fausse page pour pouvoir la détruire
  # ensuite. On la met avec un identifiant haut
  unless params.key?(:id)
    nid = 100000000
    while site.db.count(:cnarration,'narration',{id:nid}) > 0
      nid += 1
    end
  end

  data_fake_page = {
    id:             params[:id], # peut être nil
    titre:          params[:titre]      || 'Ma page de test n\'est pas mauvaise',
    description:    params[:description] || 'Description de la page de test',
    options:        params[:options]    || '1a00',
    handler:        params[:handler]    || 'tests/test',
    livre_id:       params[:livre_id]   || nil,
    created_at:     params[:created_at] || NOW,
    updated_at:     params[:updated_at] || NOW,
    completed_at:   params[:completed_at]
  }

  id_new = site.db.insert(:cnarration,'narration',data_fake_page)
  data_fake_page[:id] ||= id_new

  # === Vérifier que la page a été créée ===
  expect(site.db.count(:cnarration,'narration',{id:data_fake_page[:id]})).to eq 1

  return data_fake_page
end

def remove_page_narration_test page_id
  site.db.delete(:cnarration,'narration',{id: page_id})
  # === Vérifier que la page a été détruite ===
  expect(site.db.count(:cnarration,'narration',{id:page_id})).to eq 0
end

feature "Édition des données d'une page" do
  before(:all) do
    # Création d'une page Narration quelconque
    @data_fake_page = create_page_narration_test
  end

  after(:all) do
    # On détruit la page qu'on a créé pour les besoins du test
    # en vérifiant que la destruction s'est bien passée
    remove_page_narration_test(@data_fake_page[:id])
  end

  def url_edit_page page_id
    "#{base_url}/admin/narration/#{page_id}?op=edit_data"
  end
  def get_data_page page_id
    site.db.select(:cnarration,'narration',{id: page_id}).first
  end

  scenario "Un visiteur quelconque ne peut pas éditer une page" do
    visit url_edit_page(12)
    expect(page).not_to have_tag('h2',text: "Administration collection Narration")
    expect(page).to have_content("Vous n’êtes pas autorisé à rejoindre la page demandée, désolé.")
  end

  scenario '=> Un administrateur peut éditer les données d’une page' do

    nid = @data_fake_page[:id]

    identify phil
    visit url_edit_page(nid)
    expect(page).to have_tag('h2',text: "Administration collection Narration")

    hpage = site.db.select(:cnarration,'narration',{id: nid}).first

    # Niveau de développement
    nivdev    = hpage[:options][1].to_i(11)
    only_web  = hpage[:options][2]
    priority  = hpage[:options][3]

    expect(page).to have_tag('form', with:{id: "narration_edit_data_form"}) do
      # ID
      with_tag('input', with:{id: 'page_id', value: nid.to_s, type: 'text'})
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

    new_titre   = "Nouveau titre pour la page test à #{NOW}"
    new_desc    = "Nouvelle description à #{NOW}"
    new_handler = 'un/nouveau/handler'
    within('form#narration_edit_data_form') do
      fill_in 'page_titre',       with: new_titre
      fill_in 'page_description', with: new_desc
      fill_in 'page_handler',     with: new_handler
      select('Achevée', from: 'page_nivdev')
      check('page_only_web')
      uncheck('page_create_file')
      select('correction rapide', from: 'page_priority')
      shot 'avant-save-page'
      click_button 'Enregistrer'
    end
    shot 'apres-save-page'
    expect(page).to have_content("Page enregistrée.")
    dpage = get_data_page(nid)
    expect(dpage[:titre]).to eq new_titre
    expect(dpage[:description]).to eq new_desc
    expect(dpage[:handler]).to eq new_handler
    expect(dpage[:options]).to start_with '1a14'
    success 'l’admin peut changer les données de la page'

    md_file = File.join('.','__SITE__','narration','_data','','un','nouveau','handler.md')
    expect(File.exist?(md_file)).not_to eq true
    success 'n’a pas créé de fichier avec le handler car pas de livre'

    expect(page).not_to have_tag('a', text: 'texte')
    success 'la page n’a pas de bouton pour éditer le texte'


  end

  scenario 'un administrateur peut créer une page de toute pièce' do
    identify phil
    visit "#{base_url}/admin/narration?op=edit_data"
    shot 'arrivee-form-page-narration-sans-page'
    expect(page).to have_tag('input', with:{type:'text', id:'page_id', value: ''})
    success 'le champ de l’ID est vide'
    expect(page).to have_tag('input', with:{type:'submit', value:'Créer'})
    success 'le button submit s’appelle « Créer »'

    # ==========> TEST <============
    datapage = {
      titre:        {value: "Un titre de nouvelle page"},
      type:         {value: 'page', real_value: 1,     type: :select},
      livre_id:     {value: "La Dynamique narrative", real_value: 3,  type: :select},
      handler:      {value: 'tests'},
      description:  {value: "La description de la nouvelle page"},
      nivdev:       {value: 'Esquisse', real_value: 3, type: :select},
      priority:     {value: 'correction normale', real_value: 1, type: :select},
      only_web:     {value: false, type: :cb},
      create_file:  {value: true, type: :cb}
    }
    within('form#narration_edit_data_form') do
      datapage.each do |prop, dprop|
        field_id = "page_#{prop}"
        case dprop[:type]
        when :cb
          dprop[:value] == true ? check(field_id) : uncheck(field_id)
        when :select
          select(dprop[:value], from: field_id)
        else
          fill_in( field_id, with: dprop[:value])
        end
      end
      sleep 30
    end

    failure 'le fichier de la page a été créé'
    failure 'la page n’est pas encore insérée dans la tdm du livre'
    failure 'la page a un bouton pour éditer le texte'

  end
  scenario 'crée le fichier si la case est cochée et qu’un livre est choisi' do
    pending
    failure 'la page a un bouton pour éditer le texte'
  end


  scenario 'ne crée pas le fichier si la case est cochée mais qu’aucun livre n’est choisi' do
    pending
    expect(page).not_to have_tag('a', text: 'texte')
    success 'la page n’a pas de bouton pour éditer le texte'
  end
end
