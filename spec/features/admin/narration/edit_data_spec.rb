=begin

  Test de l'édition des données d'une page

=end

require_lib_site
require_support_integration
require_support_db_for_test
require_support_narration



feature "Édition des données d'une page" do
  before(:all) do

    # On commence par faire une sauvegarde narration si nécessaire
    backup_narration

    # Création d'une page Narration quelconque
    @data_fake_page = create_page_narration_test
  end

  after(:all) do
    # On détruit la page qu'on a créé pour les besoins du test
    # en vérifiant que la destruction s'est bien passée
    # Mettre false pour récupérer toutes les données initiales
    if false # true
      remove_page_narration_test(@data_fake_page[:id])
    else
      retreive_data_narration
    end
  end

  def url_edit_page page_id
    "#{base_url}/admin/narration/#{page_id}?op=edit_data"
  end
  def get_data_page page_id
    site.db.select(:cnarration,'narration',{id: page_id}).first
  end
  def get_last_id_narration
    last_id = site.db.select(:cnarration,'narration','id > 200 ORDER BY id DESC LIMIT 1',[:id])
    last_id.first[:id]
  end

  scenario "Un visiteur quelconque ne peut pas éditer une page" do
    visit url_edit_page(12)
    expect(page).not_to have_tag('h2',text: "Administration collection Narration")
    expect(page).to have_content("Vous n’êtes pas autorisé à rejoindre la page demandée, désolé.")
  end

  scenario '=> Un administrateur peut éditer les données d’une page' do

    nid = @data_fake_page[:id]

    identify phil

    # ========> TEST <==========
    visit url_edit_page(nid)
    shot "data-page-narration-#{nid}"
    expect(page).to have_tag('h2',text: "Administration collection Narration")
    # sleep 10

    hpage = site.db.select(:cnarration,'narration',{id: nid}).first

    # Niveau de développement
    # puts "hpage[:options] = #{hpage[:options].inspect}"
    ptype     = hpage[:options][0]
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
      expect(page.find("select#page_type option[value=\"#{ptype}\"]")).to be_selected
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
    expect(dpage[:options]).to start_with '1014'
    success 'l’admin peut changer les données de la page'

    md_file = File.join('.','__SITE__','narration','_data','','un','nouveau','handler.md')
    expect(File.exist?(md_file)).not_to eq true
    success 'n’a pas créé de fichier avec le handler car pas de livre'

    expect(page).not_to have_tag('div', with:{id: 'utils_page_buttons'})
    expect(page).not_to have_tag('a', text: 'texte')
    success 'la page n’a pas de bouton pour éditer le texte'

  end


  scenario 'un administrateur peut créer une page de toute pièce' do

    start_time = Time.now.to_i

    identify phil
    visit "#{base_url}/admin/narration?op=edit_data"
    shot 'arrivee-form-page-narration-sans-page'
    expect(page).to have_tag('input', with:{type:'text', id:'page_id', value: ''})
    success 'le champ de l’ID est vide'
    expect(page).to have_tag('input', with:{type:'submit', value:'Créer'})
    success 'le button submit s’appelle « Créer »'

    # On récupère le dernier id pour voir
    last_id = get_last_id_narration()
    # puts "DERNIER ID NARRATION : #{last_id}"

    # options = '131'
    datapage = narration_data_page({
      type: 'page',
      livre_id: 3, # La Dynamique narrative
      handler: 'tests/page_test',
      nivdev: 3,
      priority: 1,
      only_web: false,
      create_file: true
      })

    # Le fichier .md qui doit être construit
    file_md_path = datapage[:md_file][:value]
    add_file_2_remove(file_md_path)
    # puts "path file-md: #{file_md_path}"
    file_md_path && File.exist?(file_md_path) && File.unlink(file_md_path)

    # ==========> TEST <============
    narration_fill_form_with(datapage, submit = true)

    shot('page-after-create-page')
    expect(page).to have_tag('h2', text:'Administration collection Narration')

    new_last_id = get_last_id_narration
    expect(new_last_id).not_to eq last_id
    expect(new_last_id).to eq last_id + 1
    success 'une nouvelle page a été créée'

    expect(page).to have_tag('input', with:{id:'page_id', value: new_last_id.to_s})
    success "L'ID est mis dans le champ ID du formulaire"

    dpage = get_data_page(new_last_id)
    expect(dpage[:id]).to eq new_last_id
    expect(dpage[:titre]).to eq datapage[:titre][:value]
    expect(dpage[:handler]).to eq datapage[:handler][:value]
    expect(dpage[:description]).to eq datapage[:description][:value]
    expect(dpage[:options]).to eq datapage[:options][:value]
    expect(dpage[:created_at]).to be > start_time
    expect(dpage[:updated_at]).to be > start_time
    success 'les données de la nouvelle page ont été enregistrées'

    expect(file_md_path).not_to be_nil
    expect(File.exist?(file_md_path)).to eq true
    success 'le fichier de la page a été créé'

    tdm = site.db.select(:cnarration,'tdms',{id: 3},[:tdm]).first[:tdm]
    tdm = tdm.split(',').collect{|i|i.to_i}
    expect(tdm.index(new_last_id)).to eq nil
    success 'la page n’est pas encore insérée dans la tdm de son livre'

    expect(page).to have_tag('div', with:{id: 'utils_page_buttons'}) do
      with_tag('a', text: 'texte', with: {href: "admin/edit_text?path=#{CGI.escape(file_md_path)}"})
      with_tag('a', text: 'afficher', with: {href: "narration/page/#{new_last_id}"})
    end
    success 'la page a un bouton pour éditer et voir le texte'

  end

  scenario 'un administrateur peut créer un chapitre après avoir édité une page' do

    start_time = Time.now.to_i

    identify phil
    visit "#{base_url}/admin/narration/102?op=edit_data"

    # ======= VÉRIFICATIONS PRÉLIMINAIRES ===========
    expect(page).to have_tag('input', with:{id:'page_id', value: '102'})
    nb = site.db.count(:cnarration,'narration',"created_at > #{start_time}")
    expect(nb).to eq 0

    # =========> TEST <==========
    # Initialisation du formulaire
    expect(page).to have_tag('a', with:{href:'admin/narration?op=edit_data'}, text: 'Init new')
    within('form#narration_edit_data_form') do
      click_link 'Init new'
    end
    expect(page).to have_tag('h2', text: 'Administration collection Narration')
    ['id', 'titre','handler'].each do |prop|
      expect(page).to have_tag('input', with:{id:"page_#{prop}", value: ''})
    end


    # ==========> TEST <==========
    # Entrée des données pour un chapitre
    datapage = narration_data_page(type: 'chapitre', livre_id: 1, titre: "Un chapitre nouveau")
    datapage[:handler][:value] = 'un/faux/handler'
    narration_fill_form_with datapage, (submit = false)
    within('form#narration_edit_data_form') do
      check('page_create_file')
      shot('avant-submit-new-chapitre')
      click_button 'Créer'
    end
    shot('apres-submit-new-chapitre')


    # ========= VÉRIFICATIONS ==========
    expect(page).to have_tag('div.notice', text: 'Chapitre enregistré.')
    nb = site.db.count(:cnarration,'narration',"created_at > #{start_time}")
    expect(nb).to eq 1
    success 'une donnée page a été créée dans la base'

    res = site.db.select(:cnarration,'narration',"created_at > #{start_time}").first

    expect(res[:titre]).to eq "Un chapitre nouveau"
    expect(res[:options][0]).to eq '3'
    expect(res[:handler]).to eq nil
    success 'les données enregistrées dans la base sont correctes'

    expect(page).not_to have_link('texte')
    expect(page).not_to have_link('afficher')
    success 'la page n’a  pas de bouton pour éditer le texte ou l’afficher'

    badfile = File.join('.','__SITE__','narration','_data','structure','un','faux','handler.md')
    expect(File.exist?(badfile)).not_to eq true
    success 'aucun fichier n’a été créé (même avec le handler fourni et la case cochée)'

  end

  scenario 'une erreur est produite si les données sont manquantes ou invalides' do
    start_time = Time.now.to_i

    identify phil
    visit "#{base_url}/admin/narration?op=edit_data"

    datapage = narration_data_page(type: 1, livre_id: 1, titre: "Une page avec mauvais handler")
    # =======> TESTS <========
    narration_fill_form_with(datapage, submit = false)

    within('form#narration_edit_data_form') do
      fill_in 'page_titre', with: ''
      click_button 'Créer'
    end
    expect(page).to have_tag('div.error', text: "Il faut impérativement définir le titre.")
    expect(site.db.count(:cnarration,'narration',"created_at > #{start_time}")).to eq 0
    success 'produit une erreur si le titre n’est pas fourni et ne crée pas de donnée'

    narration_fill_form_with(datapage, submit = false)
    within('form#narration_edit_data_form') do
      fill_in 'page_handler', with: ''
      click_button 'Créer'
    end
    expect(page).to have_tag('div.error', text: "Pour une page, il faut impérativement définir le handler (path au fichier).")
    expect(site.db.count(:cnarration,'narration',"created_at > #{start_time}")).to eq 0
    success 'produit une erreur si le handler n’est pas fourni pour une page et ne crée pas de donnée'

    narration_fill_form_with(datapage, submit = false)
    within('form#narration_edit_data_form') do
      fill_in 'page_handler', with: 'un mauvais handler! '
      click_button 'Créer'
    end
    expect(page).to have_tag('div.error', text: /Le handler est un chemin invalide/)
    expect(site.db.count(:cnarration,'narration',"created_at > #{start_time}")).to eq 0
    success 'produit une erreur si le handler est invalide et ne crée pas de donnée.'
  end

end
