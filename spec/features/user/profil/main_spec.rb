
require_lib_site
require_support_integration

feature "Page de profil de l'user" do

  before(:all) do

    require './__SITE__/user/_lib/_required/constants'
  end


  scenario 'page sans profil (profil-none) - user non identifié, sans objet_id' do
    visit "#{base_url}/user/profil"
    expect(page).to have_tag('h2', text: 'Aucun profil')
  end






  scenario '=> page de profil simple (profil-public) - user non identifié, objet_id spécifié' do
    site.db.update(:hot,'users',{options: marion.data[:options][0..2]},{id: marion.id})
    visit "#{base_url}/user/profil/#{marion.id}"
    success 'la page contient…'
    expect(page).to have_tag('h2', text: "Profil de #{marion.pseudo}")
    success '… le bon titre'
    expect(page).to have_tag('section', with: {class: 'user_card card'}) do
      success '… une carte user_card'
      with_tag('span', with:{class: 'libelle'}, text: 'Inscrite sur le site depuis le')
      with_tag('span', with:{class: 'created_at date'}, text: /#{Regexp.escape marion.data[:created_at].as_human_date}/)
      success '… l’indication de la date d’inscription'
      with_tag('span', with:{class: 'libelle'}, text: 'Grade')
      hgrade = ERB.new(User::GRADES[marion.grade][:hname]).result(marion.bind)
      with_tag('span', with:{class: 'grade'}, text: hgrade)
      success '… l’indication du grade'
      with_tag('div', text: "#{marion.pseudo} est une administratrice.")
      success '… l’indication du fait que c’est une administratrice'
      with_tag('div', text: /Marion n’accepte d’être contactée que par des inscrits/)
      without_tag('a', with:{href:"user/contact/#{marion.id}"}, text: 'la contacter')
    end
  end















  scenario '=> un visiteur identifié trouve une page de profil d’inscrit conforme (profil-complet)' do
    huser     = get_data_random_user(admin: false)
    hautre    = get_data_random_user(not_in: [huser[:id]], sexe: 'F', admin: false)
    autre_id  = hautre[:id]
    autre     = User.get(autre_id)
    opts = hautre[:options];opts[4] = '8'
    site.db.update(:hot,'users',{options: opts},{id: autre_id})
    # puts "huser : #{huser.inspect}"
    # puts "autre : #{hautre.inspect}"
    identify huser
    visit "#{base_url}/user/profil/#{autre_id}"
    success 'la page contient…'
    expect(page).to have_tag('h2', text: "Profil de #{hautre[:pseudo]}")
    success "… le bon titre (« Profil de #{hautre[:pseudo]} »)"
    expect(page).to have_tag('section', with: {class: 'user_card card'}) do
      success '… une carte user_card'
      with_tag('span', with:{class: 'libelle'}, text: 'Inscrite sur le site depuis le')
      with_tag('span', with:{class: 'created_at date'}, text: /#{Regexp.escape hautre[:created_at].as_human_date}/)
      success '… l’indication de la date d’inscription'
      with_tag('span', with:{class: 'libelle'}, text: 'Grade')
      hgrade = ERB.new(User::GRADES[autre.grade][:hname]).result(autre.bind)
      with_tag('span', with:{class: 'grade'}, text: hgrade)
      success '… l’indication du grade'
      expect(page).not_to have_tag('div', text: "#{autre.pseudo} est une administratrice.")
      success '… aucune indication d’administration'
      with_tag('div', text: /#{autre.pseudo} accepte d’être contactée par tout le monde/)
      with_tag('a', with:{href:"user/contact/#{autre_id}"}, text: 'la contacter')
      success '… le niveau de contact, avec un lien pour la contacter'
    end
  end
















  scenario '=> inscrit identifié, trouve une page de profil personelle (profil-perso) conforme' do
    huser     = get_data_random_user(admin: false, sexe: 'F')

    identify huser
    within('section#header'){click_link 'auteur'}

# sleep 30
    success 'la page contient…'
    expect(page).to have_tag('h2', text: 'Votre profil')
    success '… le bon titre (« Votre profil »)'
    expect(page).to have_tag('section', with: {class: 'user_card card'}) do
      success '… la carte "user_card"'

      with_tag('fieldset', with: {id: 'preferences'}) do
        with_tag('legend', text: 'Préférences')
        success '… un fieldset préférences'
        with_tag('select', with:{id: 'prefs_contact', name:'prefs[contact]'})
        success '… un menu pour définir qui peut le contacter'
        with_tag('select', with:{id: 'prefs_after_login', name:'prefs[after_login]'})
        success('… un menu pour définir où se rendre après le login')
        with_tag('select', with:{id: 'prefs_notification', name:'prefs[notification]'})
        success('… un menu pour définir le niveau de notification')
        with_tag('input', with:{type: 'hidden', name:'op', value: 'save_preferences'})
        with_tag('input', with:{type: 'submit', value:'Enregistrer'})
        success '… un bouton pour enregistrer les préférences'
      end

      with_tag('fieldset', with: {id: 'forum'}) do
        with_tag('legend', text: 'Forum')
        success '… un fieldset Forum'
      end

      with_tag('fieldset', with: {id: 'narration'}) do
        with_tag('legend', text: 'Collection Narration')
        success '… un fieldset Narration'
      end
    end
  end


end
