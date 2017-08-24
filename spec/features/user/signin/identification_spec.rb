
require_lib_site
require_support_integration
require_support_db_for_test

feature "Identification" do

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
    visit signin_page

    truncate_table_users

    # On crée un nouvel user dans la table

    mail      = 'identifieur@mail.com'
    salt      = 'dusel'
    password  = 'monmotdepasse'
    require 'digest/md5'
    cpassword = Digest::MD5.hexdigest("#{password}#{mail}#{salt}")

    duser = {
      pseudo: 'Identifieur', patronyme: 'Iden Tifieur',
      sexe: 'F', mail: mail, options: '0000000000',
      salt: salt, cpassword: cpassword
    }
    duser[:id] = site.db.insert(:hot, 'users', duser)

    within('form#signin_form') do
      fill_in 'user_mail',      with: duser[:mail]
      fill_in 'user_password',  with: duser[:password]
      click_button 'OK'
    end
    expect(page).to have_tag('div.notice', text: "Bienvenue, #{data_user[:pseudo]}")

  end

  scenario 'Un user non inscrit ne peut pas s’identifier' do
    visit signin_page
    within('form#signin_form') do
      fill_in 'user_mail', with: 'Nimportequelmail@pour.voir'
      fill_in 'user_password', with: 'Nimportequel mot de passe'
      click_button 'OK'
    end

    expect(page).not_to have_content('Bienvenue')
    expect(page).to have_content('Je ne vous reconnais pas')
  end

  scenario 'Un user inscrit ne peut pas s’identifier avec un mauvais mail' do
    pending
  end

  scenario 'Un user inscrit ne peut pas s’identifier avec un mauvais password' do
    pending
  end
end
