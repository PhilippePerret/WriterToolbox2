require_support_unanunscript
require_support_integration

feature "Bureau d'un auteur du programme UN AN UN SCRIPT" do
  before(:all) do
    @data_auteur = unanunscript_create_auteur
  end

  let(:data_auteur) { @data_auteur }
  let(:auteur) { @auteur ||= User.get(data_auteur[:id]) }

  scenario "un auteur non inscrit au programme ne peut pas rejoindre le bureau UN AN" do
    visit "#{base_url}/unanunscript/bureau"
    expect(page).not_to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
  end

  scenario 'suivant ses préférences, l’auteur inscrit au programme rejoint son bureau après l’identification' do
    auteur.var['goto_after_login'] = 9
    expect(auteur.var['goto_after_login']).to eq 9
    identify data_auteur
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')

    # sleep 30*60

    success 'l’auteur rejoint son bureau à l’identification (ses préférences sont réglées comme ça)'

    expect(page).to have_tag('div', with: {id: 'onglets_sections'}) do
      with_tag('a', with: {class: 'onglet selected', id: 'unan_program'})
      with_tag('a', with: {class: 'onglet', id: 'unan_projet'})
      with_tag('a', with: {class: 'onglet', id: 'unan_taches'})
      with_tag('a', with: {class: 'onglet', id: 'unan_cours'})
      with_tag('a', with: {class: 'onglet', id: 'unan_quiz'})
      with_tag('a', with: {class: 'onglet', id: 'unan_forum'})
      with_tag('a', with: {class: 'onglet', id: 'unan_prefs'})
      with_tag('a', with: {class: 'onglet', id: 'unan_aide'})
    end
    success 'il trouve un onglet pour les principales parties'

  end

  scenario 'un auteur peut modifier les données de son projet' do
    identify data_auteur
    visit "#{base_url}/unanunscript/bureau"
    expect(page).to have_link('Projet')
    click_link('Projet')
    expect(page).to have_tag('form', with: {id: 'projet_form'}) do
      with_tag('input', with: {type: 'text', id: 'projet_titre'}, text: '')
      with_tag('textarea', with:{name: 'projet[resume]', id: 'projet_resume'}, text: '')
      with_tag('select', with:{name:'projet[type]', id: 'projet_type'})
      with_tag('input', with:{type:'submit', value:'Enregistrer'})
    end
    success 'l’auteur trouve un formulaire conforme pour modifier les données du projet'

    # Il modifie les données
    new_data = {
      titre: {value: "Un nouveau titre à #{Time.now.to_i}", ftype: :text},
      resume: {value: "Le nouveau résumé au #{Time.now}.\n\nPour voir.", ftype: :text},
      type: {value:'BD (scénario)', real_value: 3, ftype: :select},
      specs: {value: '130048'}
    }

    within('form#projet_form') do
      new_data.each do |kprop, dprop|
        case dprop[:ftype]
        when :text    then fill_in("projet_#{kprop}", with: dprop[:value])
        when :select  then select(dprop[:value], from: "projet_#{kprop}")
        else
          # Ne rien faire, c'est une valeur qui doit serveur plus tard
        end
        shot('after-fillin-projet-form')
      end
      click_button 'Enregistrer'
      shot('after-submit-projet-form')
    end

    # =========== VÉRIFICATION ===========
    expect(page).to have_tag('div.notice', text: 'Les nouvelles données du projet ont été enregistrées.')
    hprojet = site.db.select(:unan,'projets', {auteur_id: data_auteur[:id]}).first
    expect(hprojet[:titre]).to eq new_data[:titre][:value]
    expect(hprojet[:resume]).to eq new_data[:resume][:value]
    expect(hprojet[:specs]).to eq new_data[:specs][:value]


  end



  scenario 'un auteur peut régler les préférences de son programme' do

    # ============ DONNÉES UTILES ==============
    u = User.get(data_auteur[:id])
    program = u.program
    if u.var['goto_after_login'] == 9
      u.var['goto_after_login'] = 1
    end

    # ============== PRÉ-VÉRIFICATION ===========
    expect(program.rythme).to eq 5
    expect(program.options).to eq '100000000000'
    expect(u.var['goto_after_login']).not_to eq 9

    # L'auteur se rend dans son onglet des préférences
    identify data_auteur
    visit "#{base_url}/unanunscript/bureau"
    expect(page).to have_link('Préférences')
    click_link 'Préférences'

    expect(page).to have_tag('form', with: {id: 'unan_prefs_form'}) do
      with_tag('select', with: {id: 'prefs_rythme', name: 'prefs[rythme]'})
      with_tag('input', with: {type: 'checkbox', id: 'prefs_daily_summary'})
      with_tag('select', with: {id: 'prefs_send_time', name: 'prefs[send_time]'})
      with_tag('input', with: {type: 'checkbox', id: 'prefs_after_login'})
      with_tag('select', with: {id: 'prefs_partage', name: 'prefs[partage]'})
    end
    success 'il trouve un formulaire de préférences valide'

    expect(page.execute_script("return DOM('prefs_rythme').value;")).to eq '5'
    expect(page.execute_script("return DOM('prefs_daily_summary').checked;")).to eq false
    expect(page.execute_script("return DOM('prefs_send_time').value;")).to eq ''
    expect(page.execute_script("return DOM('prefs_after_login').checked;")).to eq false
    success 'et bien réglé'


    # ============> TEST UN <===============
    within('form#unan_prefs_form') do

      select('Soutenu', from: 'prefs_rythme') # => 6

      # Pas d'envoi du mail quotidien
      check('prefs_daily_summary')  # => bit 3 => 1
      sleep 0.2
      select('10:00', from: 'prefs_send_time')
      # Après le login, se rend dans le profil (valeur par défaut)
      check('prefs_after_login')
      # Réglage du partage (bit 6 des options)
      select('Personne', from: 'prefs_partage') # => 1

      shot 'before-submit-prefs-1'
      click_button 'Enregistrer'
    end
    shot 'after-submit-prefs-1'
    success 'il choisit d’autres valeurs et les soumet'

    # ============== VÉRIFICATION UN ==============
    u = User.get(data_auteur[:id], force = true)
    program = u.program
    expect(page).to have_tag('div.notice', 'Vos préférences pour le programme sont enregistrées.')
    expect(program.rythme).to eq 6
    expect(program.options[0..6]).to eq '1001a01'
    expect(u.var['goto_after_login']).to eq 9
    success 'les nouvelles valeurs sont correctes'



    # ============> TEST DEUX <===============
    within('form#unan_prefs_form') do
      # Réglage du rythme
      select('Tranquille', from: 'prefs_rythme') # => 3
      # Pas d'envoi du mail quotidien
      uncheck('prefs_daily_summary')  # => bit 3 => 0
      # Après le login, se rend dans le profil (valeur par défaut)
      uncheck('prefs_after_login')
      # Réglage du partage (bit 6 des options)
      select('Autres auteurs du programme', from: 'prefs_partage') # => 2

      shot 'before-submit-prefs-2'
      # sleep 10
      click_button 'Enregistrer'
    end
    shot 'after-submit-prefs-2'
    success 'il choisit d’autres valeurs et les soumet avec succès'


    # ========== VÉRIFICATIONS DEUX ===========
    u = User.get(data_auteur[:id], force = true)
    program = u.program
    expect(page).to have_tag('div.notice', 'Vos préférences pour le programme sont enregistrées.')
    expect(program.rythme).to eq 3
    expect(program.options[0..6]).to eq '1000002'
    expect(u.var['goto_after_login']).not_to eq 9

  end



  scenario 'un auteur inscrit au programme peut rejoindre son bureau UN AN UN SCRIPT par un lien à l’accueil' do
    identify data_auteur
    expect(page).to have_link 'Votre programme UN AN UN SCRIPT'
    click_link('Votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
  end
end
