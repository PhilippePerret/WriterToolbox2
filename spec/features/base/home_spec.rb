require_support_integration

feature "Accueil de la boite à outils de l'auteur" do
  scenario "Un visiteur quelconque peut rejoindre l'accueil" do
    visit 'http://localhost/WriterToolbox2'
    expect(page).to have_tag('h1', text: "la boite à outils de l’auteur")
  end
  scenario '=> la page de premier accueil est conforme' do
    visit home_page
    expect(page).to have_tag('section', with:{id:'header'})
    success '  contient la section "header"'
    expect(page).to have_tag('section', with:{id:'contents'})
    success '  contient la section "contents"'
    expect(page).to have_tag('section', with:{id:'footer'})
    success '  contient la section "footer"'
    expect(page).not_to have_tag('section', with:{id:'left_margin'})
    success '  ne contient pas la marge gauche'
  end

  scenario '=> la page d’accueil après une identification réussie' do
    identifier_phil
    visit home_page
    expect(page).not_to have_tag('section', with:{id:'left_margin'})
    success '  ne contient pas la marge gauche'
  end
end
