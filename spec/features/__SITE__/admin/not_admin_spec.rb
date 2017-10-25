require_support_db_for_test
require_support_integration

feature "Accès à la partie administration" do
  before(:all) do
    @inscrit = create_new_user()
  end
  scenario "un simple visiteur ne peut pas atteindre les parties d'administration" do
    visit home_page
    visit admin_page
    expect(page).not_to have_tag('h2', text: 'Administration du site')
    expect(page).to have_tag('h2', text: 'Vous avez été redirigé')
    expect(page).to have_content('Vous n’êtes pas autorisé à rejoindre la page demandée, désolé.')

    visit "#{base_url}/admin/spotlight"
    expect(page).not_to have_tag('h2', text: 'Admin : coup de projecteur')
    expect(page).to have_tag('h2', text: 'Vous avez été redirigé')

  end
  scenario 'un simple inscrit ne peut pas atteindre les parties administration' do
    visit home_page
    click_link 's’identifier'
    expect(page).to have_selector('form#signin_form')
    within('form#signin_form') do
      fill_in :user_mail, with: @inscrit[:mail]
      fill_in :user_password, with: @inscrit[:password]
      click_button 'OK'
    end
    expect(page).to have_content('Soyez la bienvenue')
    expect(page).not_to have_link 'administration'
    visit admin_page
    expect(page).not_to have_tag('h2', text: 'Administration du site')
    expect(page).to have_tag('h2', text: 'Vous avez été redirigée')
    expect(page).to have_content("#{@inscrit[:pseudo]}, vous n’êtes pas autorisée à rejoindre la page demandée, désolé.")

    visit "#{base_url}/admin/spotlight"
    expect(page).not_to have_tag('h2', text: 'Admin : coup de projecteur')
    expect(page).to have_tag('h2', text: 'Vous avez été redirigée')

  end

  scenario 'un administrateur peut atteindre les parties administration' do
    identify phil
    expect(page).to have_link 'administration'
    click_link 'administration'
    expect(page).to have_tag('h2', text: 'Administration du site')
    expect(page).to have_content('Bienvenue dans le tableau de bord du site, Phil')
    expect(page).to have_link 'Coup de projecteur'

    # On essaie aussi de rejoindre le réglage du coup de projecteur par
    # adresse directe
    visit "#{base_url}/admin/spotlight"
    expect(page).to have_tag('h2', text: 'Admin : coup de projecteur')
  end
end
