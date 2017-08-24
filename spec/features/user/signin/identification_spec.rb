
require_lib_site
require_support_integration
require_support_db_for_test

feature "Identification" do
  before(:all) do
    truncate_table_users
  end

  scenario 'la page d’accueil contient un lien pour s’identifier qui fonctionne' do
    visit home_page
    expect(page).to have_tag('a', text: 'S’identifier', with:{href:'user/signin'})
    click_link 'S’identifier'
    expect(page).to have_tag('h2', text: 'S’identifier')
    expect(page).to have_selector('form#signin_form')
  end

  scenario 'N’importe quel user peut rejoindre directement le formulaire d’identification' do
    visit signin_page
    expect(page).to have_selector('form#signin_form')
  end

  scenario "Un user inscrit peut s'identifier" do

    # On crée un nouvel user dans la table
    duser = create_new_user({sexe: 'F'})

    visit signin_page

    within('form#signin_form') do
      fill_in 'user_mail',      with: duser[:mail]
      fill_in 'user_password',  with: duser[:password]
      click_button 'OK'
    end
    mess = Regexp.escape("Soyez la bienvenue, #{duser[:pseudo]}")
    expect(page).to have_tag('div.notice', text: /#{mess}/)
  end

  scenario 'Un user non inscrit ne peut pas s’identifier' do
    visit signin_page
    within('form#signin_form') do
      fill_in 'user_mail', with: 'Nimportequelmail@pour.voir'
      fill_in 'user_password', with: 'Nimportequel mot de passe'
      click_button 'OK'
    end

    expect(page).to have_content('Aucun utilisateur du site ne possède cet email')
    expect(page).to have_selector('form#signin_form')
  end

  scenario 'Un user inscrit ne peut pas s’identifier avec un mauvais password' do
    duser = create_new_user()

    visit signin_page
    within('form#signin_form') do
      fill_in 'user_mail',      with: duser[:mail]
      fill_in 'user_password',  with: 'Nimportequel mot de passe'
      click_button 'OK'
    end

    expect(page).to have_tag('div.error', text: /Je ne vous reconnais pas/)
    expect(page).to have_selector('form#signin_form')

  end

  scenario 'un user ne peut pas essayer de s’identifier plus de 50 fois' do

    visit signin_page

    27.times do |itime|
      within('form#signin_form') do
        fill_in 'user_mail',      with: "login_soumis_#{1+itime}_fois@mail.com"
        fill_in 'user_password',  with: 'Nimportequel mot de passe'
        click_button 'OK'
      end
      page.has_selector?('form#signin_form') || break
    end

    expect(page).not_to have_selector('form#signin_form')
    expect(page).to have_tag('div.error', text: 'Vous avez dépassé votre quotat de tentatives de connexions.')

  end
end
