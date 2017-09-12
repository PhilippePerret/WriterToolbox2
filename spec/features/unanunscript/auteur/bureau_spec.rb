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
    expect(page).not_to have_tag('h2', text: 'Votre bureau UN AN UN SCRIPT')
  end

  scenario 'suivant ses préférences, l’auteur inscrit au programme rejoint son bureau après l’identification' do
    auteur.var['goto_after_login'] = 9
    expect(auteur.var['goto_after_login']).to eq 9
    identify data_auteur
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')

    sleep 30*60

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
      with_tag('select', with: {name: 'projet[partage]', id: 'projet_partage'})
      with_tag('input', with:{type:'submit', value:'Enregistrer'})
    end
    success 'l’auteur trouve un formulaire conforme pour modifier les données du projet'

    # Il modifie les données
    new_data = {
      titre: {value: "Un nouveau titre à #{Time.now.to_i}", ftype: :text},
      resume: {value: "Le nouveau résumé au #{Time.now}.\n\nPour voir.", ftype: :text},
      type: {value:'BD (scénario)', real_value: 3, ftype: :select},
      partage: {value: 'Autres auteurs du programme', real_value: 2, ftype: :select},
      specs: {value: '132048'}
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

  scenario 'un auteur inscrit au programme peut rejoindre son bureau UN AN UN SCRIPT par un lien à l’accueil' do
    identify data_auteur
    expect(page).to have_link 'Votre programme UN AN UN SCRIPT'
    click_link('Votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
  end
end
