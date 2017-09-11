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

    sleep 120

    success 'l’auteur rejoint son bureau à l’identification (ses préférences sont réglées comme ça)'

    expect(page).to have_tag('div', with: {id: 'onglets_sections'}) do
      with_tag('a', with: {class: 'onglet selected', id: 'unan_program'})
      with_tag('a', with: {class: 'onglet', id: 'unan_projet'})
      with_tag('a', with: {class: 'onglet', id: 'unan_taches'})
      with_tag('a', with: {class: 'onglet', id: 'unan_cours'})
      with_tag('a', with: {class: 'onglet', id: 'unan_quiz'})
      with_tag('a', with: {class: 'onglet', id: 'unan_forum'})
      with_tag('a', with: {class: 'onglet', id: 'unan_prefs'})
      with_tag('a', with: {class: 'onglet', id: 'unan_help'})
    end
    success 'il trouve un onglet pour les principales parties'

  end

  scenario 'un auteur inscrit au programme peut rejoindre son bureau UN AN UN SCRIPT par un lien à l’accueil' do
    identify data_auteur
    expect(page).to have_link 'Votre programme UN AN UN SCRIPT'
    click_link('Votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
  end
end
