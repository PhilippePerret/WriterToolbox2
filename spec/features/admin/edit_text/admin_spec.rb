require_support_integration


feature "Édition d'un texte quelconque" do
  def edit_file path
    visit "#{base_url}/admin/edit_text?path=#{CGI.escape(path)}"
  end
  scenario "Un administrateur peut rejoindre la section" do
    identify phil
    edit_file('./un/path.txt')
    expect(page).to have_tag('h2', text: 'Éditeur de texte')
    expect(page).to have_tag('div', with: {class:'red'}, text: 'Le fichier `./un/path.txt` n’existe pas.')
  end

  scenario 'un admin ne peut pas créer un fichier dont le dossier n’existe pas' do
    path = "./un/dossier/inexistant.txt"

    identify phil
    edit_file(path)

    within("form#edit_text_form") do
      fill_in 'file_code', with: "Ceci est le texte du fichier qui ne sera pas enregistré."
      click_button 'Enregistrer'
    end

    expect(page).to have_tag('div.error', text: /Le dossier `.\/un\/dossier` n'existe pas/)
    expect(File.exist?(path)).to eq false
    success 'aucun fichier n’a été créé'

  end

  scenario 'un admin peut créer un fichier qui n’existe pas, si le dossier existe' do

    path = "./xtmp/un_fichier_a_creer#{Time.now.to_i}.txt"
    add_file_2_destroy(path)

    # ========== PRÉ-VÉRIFICATIONS ===========
    expect(File.exist?(path)).to eq false

    identify phil
    edit_file(path)

    expect(page).to have_content("Le fichier `#{path}` n’existe pas.")
    success 'un message indique que le fichier n’existe pas'

    # ========> TEST <=============
    within("form#edit_text_form") do
      fill_in 'file_code', with: "Ceci est le texte du fichier"
      click_button 'Enregistrer'
    end

    expect(page).to have_tag('div.notice', text: "Fichier enregistré.")
    expect(File.exist?(path)).to eq true
    success 'le fichier a été créé.'

    code = File.read(path)
    expect(code).to eq "Ceci est le texte du fichier"
    success 'le code a bien été enregistré dans le fichier'

  end

  scenario 'on détruit le fichier si le code est vide' do

    path = './xtmp/adetruire.txt'
    add_file_2_destroy(path)

    File.open(path,'wb'){|f| f.write 'Un premier code.'}

    expect(File.exist?(path)).to eq true

    # ========== PRÉPARATION ===========
    identify phil
    edit_file(path)

    # ========== VÉRIFICATION PRÉPARATION ===========
    expect(page).to have_content("Le fichier `#{path}` est prêt à être édité.")

    # ==========> TEST <==========
    within('form#edit_text_form') do
      fill_in 'file_code', with: ''
      click_button 'Enregistrer'
    end

    # ========= VÉRIFICATION ===========
    expect(page).to have_tag('div.notice',text: "Le code est vide, j'ai détruit le fichier.")
    expect(File.exist?(path)).to eq false

  end

  scenario 'on peut modifier le code du fichier' do

    path = './xtmp/fichier_modified.txt'
    add_file_2_destroy(path)
    File.open(path,'wb'){|f| f.write("le code initial du fichier modifié.")}

    # ========= PRÉ-VÉRIFICATIONS ==========
    expect(File.exist? path).to eq true

    # ========== PRÉPARATION ===========
    identify phil
    edit_file path
    expect(page).to have_content("Le fichier `#{path}` est prêt à être édité.")

    # =========> TEST <===========
    autre_code = 'Un autre code pour le fichier modifié.'
    within('form#edit_text_form') do
      fill_in 'file_code', with: autre_code
      click_button 'Enregistrer'
    end

    # ======== VÉRIFICATIONS ==========
    expect(page).to have_tag('div.notice', "Fichier enregistré.")
    expect(File.exist? path).to eq true
    expect(File.read(path)).to eq autre_code

  end

end
