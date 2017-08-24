require_support_integration
require_support_db_for_test


feature "Déconnection" do
  before(:all) do
    truncate_table_users
  end
  scenario "Un utilisateur qui s'est identifié peut suivre le cycle connexion/déconnexion" do
    duser = create_new_user()

    visit home_page
    expect(page).to have_link('s’identifier')
    expect(page).to have_link('s’inscrire')

    # Pour bouger ailleurs
    expect(page).to have_link('outils')
    click_link('outils')
    expect(page).to have_tag('h2', text: 'Outils d’écriture')
    expect(page).to have_link('s’identifier')

    # === TEST CONNEXION ===
    click_link('s’identifier')
    expect(page).to have_selector('form#signin_form')
    within('form#signin_form') do
      fill_in 'user_mail', with: duser[:mail]
      fill_in 'user_password', with: duser[:password]
      click_button 'OK'
    end
    expect(page).to have_content("Soyez")
    expect(page).to have_link('se déconnecter')
    expect(page).not_to have_link('s’inscrire')

    expect(page).to have_link('votre profil')
    click_link('votre profil')
    expect(page).to have_tag('h2', text: 'Votre profil')
    expect(page).to have_link('se déconnecter')

    # === TEST DÉCONNEXION ===
    click_link 'se déconnecter'
    expect(page).not_to have_link('se déconnecter')
    expect(page).to have_link('s’identifier')

  end

end
