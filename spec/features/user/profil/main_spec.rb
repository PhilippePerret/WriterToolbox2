
require_support_integration

feature "Page de profil de l'user" do
  scenario "Un user non identifié ne peut pas rejoindre son profil" do
    visit profil_page
    expect(page).to have_content('Vous n’êtes pas identifié, votre profil n’existe pas sur le site.')
    expect(page).to have_tag('section#contents a', with:{href:'user/signup'}, text: 'S’inscrire')
  end

  scenario 'Un user identifié peut voir la page de son profil' do
    # identified_user
    # visit profil_page
    pending "à implémenter"
  end
end
