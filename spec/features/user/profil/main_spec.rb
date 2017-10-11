
require_support_integration

feature "Page de profil de l'user" do

  context 'un visiteur non identifié' do
    context 'avec une adresse sans identifiant d’inscrit' do
      scenario 'aboutit sur la page de non profil' do
        visit "#{base_url}/user/profil"
        expect(page).to have_tag('h2', text: 'Aucun profil')
      end
    end
    context 'avec une adresse avec identifiant d’inscrit (Marion)' do
      scenario 'aboutit sur la page de profil simplifié de Marion' do
        visit "#{base_url}/user/profil/#{marion.id}"
        success 'la page contient…'
        expect(page).to have_tag('h2', text: "Profil de #{marion.pseudo}")
        success '… le bon titre'
        expect(page).to have_tag('span', with:{class: 'libelle'}, text: 'Inscrite au site depuis le')
        expect(page).to have_tag('span', with:{class: 'created_at date'}, text: /#{Regexp.escape marion.data[:created_at].as_human_date}/)
        success '… l’indication de la date d’inscription'
        expect(page).to have_tag('span', with:{class: 'libelle'}, text: 'Grade')
        expect(page).to have_tag('span', with:{class: 'grade'}, text: User::GRADE[marion.grade][:hname])
        success '… l’indication du grade'
        expect(page).to have_tag('div', text: "#{marion.pseudo} est une administratrice.")
        success '… l’indication du fait que c’est une administratrice'
      end
    end
  end

  scenario "Un user non identifié ne peut pas rejoindre son profil" do
    visit "#{base_url}/user/profil"
    expect(page).to have_content('Vous n’êtes pas identifié, votre profil n’existe pas sur le site.')
    expect(page).to have_tag('section#contents a', with:{href:'user/signup'}, text: 'S’inscrire')
  end

  scenario 'Un user identifié peut voir la page de son profil' do
    # identified_user
    # visit profil_page
    pending "à implémenter"
  end
end
