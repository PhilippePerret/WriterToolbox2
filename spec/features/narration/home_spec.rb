require_support_integration

require './__SITE__/narration/_lib/_required/constants'

feature "Accueil de la collection Narration" do
  scenario "Un visiteur quelconque trouve une page d'accueil de Narration valide" do
    visit home_page
    expect(page).to have_link('outils')
    click_link('outils', match: :first)
    expect(page).to have_tag('h2', text: 'Outils d’écriture')
    expect(page).to have_link('La collection Narration')
    click_link('La collection Narration', match: :first)

    # ========= VÉRIFICATION =========

    expect(page).to have_tag('h2', text: 'La collection Narration')
    expect(page).to have_tag('a', with:{href: 'narration/livres'}, text: 'Tous les livres')
    expect(page).to have_tag('a', with:{href: 'narration/presentation'}, text: /État du développement/)
    expect(page).to have_tag('h3', text: 'Toutes les tables des matières')
    expect(page).to have_tag('ul#livres') do
      Narration::LIVRES.each do |bid, bdata|
        with_tag('li a', with: {href:"narration/livre/#{bid}"}, text: bdata[:hname])
      end
    end
  end

  scenario 'un administrateur trouve une page valide' do
    identify phil
    visit narration_page
    expect(page).to have_tag('a', with:{href: 'admin/narration'}, text: 'administrer')
  end
end
