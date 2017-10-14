require_lib_site
require_support_integration
require_support_analyse

feature 'Accueil de la section analyse' do
  scenario 'Un visiteur quelconque peut rejoindre la section Analyse depuis les outils' do
    visit home_page
    within('section#header'){ click_link 'outils' }
    expect(page).to have_tag('h2', text: 'Outils d’écriture')
    within('div#quick_access'){ click_link 'Les Analyses de films'}
    expect(page).to have_tag('h2', text: 'Les Analyses de films')
  end

  scenario 'Un visiteur quelconque peut rejoindre la section Analyses par URL' do
    visit "#{base_url}/analyse/home"
    expect(page).to have_tag('h2', text: 'Les Analyses de films')
  end

  scenario '=> Un visiteur quelconque trouve un accueil conforme' do

    # On prend un film qui peut être vu par n'importe qui
    hfilm = get_film_analyse(access: :public)
    puts "hfilm = #{hfilm.inspect}"
    visit analyse_page
    expect(page).to have_tag('fieldset', with:{id: "fs_analyse_list"}) do
      with_tag('legend', text: 'Analyses')
      with_tag('ul', with: {id: 'analyse_list'}) do
        with_tag('li', with: {class: 'film', id: "film-#{hfilm[:id]}"}, text: /#{hfilm[:titre]}/)
      end
    end
  end
end
