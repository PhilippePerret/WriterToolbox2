require_support_integration
require_support_scenodico
require_support_db_for_test

feature "Édition d'un mot du scénodico" do

  before(:all) do
    backup_base_biblio # copie du jour
  end
  after(:all) do
    retreive_base_biblio
  end

  scenario "Un visiteur quelconque ne peut pas éditer un mot du scénodico" do
    visit "#{base_url}/admin/scenodico"
    expect(page).not_to have_tag('h2', text: "Édition Scénodico")
    visit "#{base_url}/admin/scenodico?op=edit_mot"
    expect(page).not_to have_tag('h2', text: "Édition Scénodico")
    visit "#{base_url}/admin/scenodico/2?op=edit_mot"
    expect(page).not_to have_tag('h2', text: "Édition Scénodico")
  end

  scenario 'un administrateur peut éditer un mot du scénodico' do
    hmot = scenodico_get_mot('relatifs != "" AND contraires != ""')
    # puts "hmot = #{hmot.inspect}"
    identify phil
    visit "#{base_url}/admin/scenodico/#{hmot[:id]}?op=edit_mot"
    # sleep 15
    expect(page).to have_tag('h2', text: "Édition Scénodico")
    expect(page).to have_tag('form', with: {id: "edit_mot_form"}) do
      with_tag('input', with:{type: 'text', id:'mot_mot', name:'mot[mot]'}, value: hmot[:mot])
      with_tag('textarea', with:{id: 'mot_definition', name: 'mot[definition]'})
      with_tag('input', with:{type: 'text', id:'mot_categories', name:'mot[categories]', value: (hmot[:categories]||'')})
      with_tag('input', with:{type: 'hidden', id:'mot_relatifs', name:'mot[relatifs]', value:hmot[:relatifs]})
      with_tag('input', with:{type: 'hidden', id:'mot_synonymes', name:'mot[synonymes]', value:hmot[:synonymes]})
      with_tag('input', with:{type: 'hidden', id:'mot_contraires', name:'mot[contraires]', value:hmot[:contraires]})
      with_tag('textarea', with: {id: 'mot_liens', name: 'mot[liens]'}, text: hmot[:liens])
      with_tag('input', with: {type:'submit', value:'Enregistrer'})
    end
    success "la page contient un formulaire valide"

    # L'administrateur peut modifier les données
  end

  scenario 'un administrateur peut créer un nouveau mot' do
    start_time = Time.now.to_i

    identify phil
    visit "#{base_url}/admin/scenodico/8?op=edit_mot"
    expect(page).to have_tag('a', with:{class:'btn fleft', href: "admin/scenodico?op=edit_mot"}, text: "Init nouveau")
    expect(page).to have_tag('input', with:{id: 'mot_id', value: '8'})


    # ======== PRÉPARATION ==========
    click_link 'Init nouveau'
    expect(page).to have_tag('form', with: {id: 'edit_mot_form'}) do
      with_tag('input', with:{id: 'mot_id', value: ''})
      with_tag('input', with:{id: 'mot_mot', value: ''})
      with_tag('textarea', with:{id: 'mot_definition'}, text: '')
      with_tag('input', with:{value: "Créer", type: 'submit'})
    end
    success 'en cliquant sur “init nouveau”, il initialise le formulaire'

    # =============> TEST <=============
    new_mot_mot = "Mot test #{Time.now.to_i}"
    new_mot_def = "La définition du #{Time.now}"
    new_mot_cat = 'METH DYNA'
    new_mot_liens = "http://www.atelier-icare.net::Atelier Icare\nhttp://www.laboiteaoutilsdelauteur.fr::Boa"
    data_mot = {
      mot:        {value: new_mot_mot, ftype: :text},
      definition: {value: new_mot_def, ftype: :text},
      categories: {value: new_mot_cat, ftype: :text},
      liens:      {value: new_mot_liens, ftype: :text},
      relatifs:   {value: ['Harmatia', 'Protagoniste', 'Antagoniste'], ftype: :select},
      synonymes:  {value: ['Acte', 'Séquence'], ftype: :select},
      # contraires reste à nil
    }


    within('form#edit_mot_form') do
      # Il faut décocher la case cb_only_checkeds pour pouvoir
      # afficher tous les mots. Sinon, par défaut, seuls les mots choisis
      # sont affichés.
      # page.find('input#cb_only_checkeds').click
      # uncheck('cb_only_checkeds')
      page.execute_script('Scenodico.show_only_checkeds(null,false)')

      data_mot.each do |prop, dprop|
        domid = "mot_#{prop}"
        case dprop[:ftype]
        when :text then fill_in(domid, with: dprop[:value])
        when :select then
          dprop[:value].is_a?(Array) || dprop[:value] = [dprop[:value]]
          dprop[:value].each do |val|
            within("select#menu_mot_#{prop}")do
              page.find("option[value=\"#{SCENODICO_MOT_TO_ID[val]}\"]").click
            end
            sleep 0.1
          end
        end
      end

      shot 'form-mot-before-submit'

      click_button 'Créer'
      shot 'form-mot-after-submit'
    end
    # /fin formulaire

    expect(page).to have_content("Nouveau mot créé.")
    # On récupère le dernier mot testé
    nmot = site.db.select(:biblio,'scenodico',"created_at > #{start_time} LIMIT 1").first

    expect(nmot[:mot]).to eq new_mot_mot
    expect(nmot[:definition]).to eq new_mot_def
    expect(nmot[:categories]).to eq new_mot_cat
    expect(nmot[:liens]).to eq new_mot_liens
    synonymes_ids = data_mot[:synonymes][:value].collect{|mo|SCENODICO_MOT_TO_ID[mo]}
    expect(nmot[:synonymes]).to eq synonymes_ids.join(' ')
    relatifs_ids = data_mot[:relatifs][:value].collect{|mo| SCENODICO_MOT_TO_ID[mo]}
    expect(nmot[:relatifs]).to eq relatifs_ids.join(' ')
    expect(nmot[:contraires]).to eq nil
    success "Les données du mot sont valides"

    expect(page).to have_tag('a', with: {href: "scenodico/mot/#{nmot[:id]}"})
    success "la page présente un bouton « voir » permettant d'afficher le mot"


    visit "#{base_url}/admin/scenodico/#{nmot[:id]}?op=edit_mot"
    expect(page).to have_tag('form', with: {id: 'edit_mot_form'}) do
      with_tag('input', with:{id: 'mot_id', value: nmot[:id]})
      with_tag('input', with: {type: 'submit', value: 'Enregistrer'})
    end
    success "l'administrateur peut rééditer le mot"

  end
  scenario 'toutes les données doivent être correcte pour enregistrer le nouveau mot' do

    start_time = Time.now.to_i

    identify phil

    visit "#{base_url}/admin/scenodico?op=edit_mot"

    expect(page).to have_tag('form', with: {id: 'edit_mot_form'}) do
      with_tag('input', with:{id: 'mot_id', value: ''})
      with_tag('input', with: {type: 'submit', value: 'Créer'})
    end
    success 'administrateur repart d’un mot vierge'

    within('form#edit_mot_form') do
      fill_in('mot_mot', with: '')
      click_button('Créer')
    end
    expect(page).to have_tag('div.error', text: 'Le mot est requis.')
    expect(nombre_mots_after(start_time)).to eq 0
    success 'un mot est obligatoire pour enregistrer un nouveau mot'


    within('form#edit_mot_form') do
      fill_in('mot_mot', with: 'Antagoniste')
      click_button('Créer')
    end
    expect(page).to have_tag('div.error', text: 'Ce mot existe déjà.')
    expect(nombre_mots_after(start_time)).to eq 0

    within('form#edit_mot_form') do
      fill_in('mot_mot', with: 'antagoniste')
      click_button('Créer')
    end
    expect(page).to have_tag('div.error', text: 'Ce mot existe déjà.')
    expect(nombre_mots_after(start_time)).to eq 0
    success "Le mot ne doit pas exister déjà, même en minuscule (si c'est un nouveau, of course)"

    within('form#edit_mot_form') do
      fill_in('mot_mot', with: "Le mot à #{Time.now.to_i}")
      fill_in('mot_definition', with: '')
      click_button('Créer')
    end
    expect(page).to have_tag('div.error', text: 'La définition du mot est absolument requise.')
    expect(nombre_mots_after(start_time)).to eq 0
    success "Le mot doit avoir une définition"

    within('form#edit_mot_form') do
      fill_in('mot_mot', with: "Le mot à #{Time.now.to_i}")
      fill_in('mot_definition', with: 'Une définition pour le mot redéfini.')
      fill_in('mot_categories', with: 'METH BADE')
      click_button('Créer')
    end
    expect(page).to have_tag('div.error', text: 'Une catégorie est inconnue. Ne les rentrez pas à la main.')
    expect(nombre_mots_after(start_time)).to eq 0
    success "Si la catégorie est définie, elle doit être valide"

    {
      # "Un mauvais lien" => "Un des liens est mal formaté (format : url::titre).",
      "Un mauvais lien::" => "Le titre du lien est requis (format : url::titre).",
      "::Un mauvais lien" => "L'URL du lien est requise (format : url::titre).",
      "Un mauvais::lien" => "Un des liens est mal formaté (format : url::titre)."
    }.each do |badlink, mess_error|
      within('form#edit_mot_form') do
        fill_in('mot_mot', with: "Le mot à #{Time.now.to_i}")
        fill_in('mot_definition', with: 'Une définition pour le mot redéfini.')
        fill_in('mot_categories', with: 'METH DYNA STRU')
        fill_in('mot_liens', with: "http://www.atelier-icare.net::Icare\n#{badlink}")
        click_button('Créer')
      end
      expect(page).to have_tag('div.error', text: mess_error)
      expect(nombre_mots_after(start_time)).to eq 0
    end
    success "Si les liens sont mal définis, une erreur"
  end
end
