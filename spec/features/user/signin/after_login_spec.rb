require_lib_site
require_support_integration

feature "Redirection de l'user après son identification" do
  scenario "Marion est redirigée vers l'accueil si aucune préférence n'est réglée" do
    marion.var['goto_after_login'] = nil
    identify marion
    expect(page).to have_tag('section#incipit') # <= accueil
  end

  scenario 'Marion est redirigée vers son profil si 1 est choisi' do
    marion.var['goto_after_login'] = 1
    identify marion
    expect(page).to have_tag('h2', text: /profil/i)
  end

  scenario 'Marion est redirigée vers sa dernière page si 2 est choisi' do
    marion.var['last_route'] = 'site/phil'
    marion.var['goto_after_login'] = 2
    identify marion
    expect(page).to have_tag('h2', text: 'Philippe Perret')
  end

  scenario 'Un auteur Un an un script est redirigé vers son bureau si 9 est choisi' do
    require_support_unanunscript
    hauteur = unanunscript_create_auteur()
    u = User.get(hauteur[:id])
    u.var['goto_after_login'] = 9
    identify(mail: hauteur[:mail], password: hauteur[:password])
    expect(page).to have_tag('h2', text: 'Votre bureau UN AN UN SCRIPT')
  end
end
