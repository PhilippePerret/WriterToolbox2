require_lib_site
require_support_integration
require_support_analyse
require_support_db_for_test

feature 'Accueil de la section analyse', check: false do

  before(:all) do
    # Si on passe par ici, il faut absolument protéger les données biblio qui
    # vont être modifiées. On doit les sauver si nécessaire et demander leur
    # rechargement.
    backup_base_biblio # seulement si nécessaire
    protect_biblio
  end

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
    hfilms = get_films_analyse(access: :suscribed)
    visit analyse_page
    expect(page).to have_tag('fieldset', with:{id: "fs_analyse_list"}) do
      with_tag('legend', text: 'Analyses')
      with_tag('ul', with: {id: 'analyse_list'}) do
        hfilms.each do |hfilm|
          titre_film = hfilm[:titre].force_encoding('utf-8')
          with_tag('li', with: {class: 'film', id: "film-#{hfilm[:id]}"}, text: /#{titre_film}/) do
            with_tag('a', with: {href: "analyse/lire/#{hfilm[:id]}"})
            director_name = hfilm[:director].force_encoding('utf-8').split(' ').last
            with_tag('span.director', text: /#{director_name}/)
            with_tag('span.annee', text: hfilm[:annee].to_s)
          end
        end
      end
    end
    success 'il trouve la liste des films'

    expect(page).to have_tag('a', with: {href: "analyser", class: 'exergue'}, text: 'contribuer aux analyses')
    success 'il trouve un lien vers la partie « Contribuer »'
  end

  scenario '=> Un visiteur quelconque peut atteindre les différentes parties depuis l’accueil des analyses' do
    visit analyse_page

    lifilm = page.all('ul#analyse_list li.film')[5]
    titre_film = lifilm.find('a')[:text].strip
    # puts "titre_film : #{titre_film}"
    lifilm.click
    expect(page).to have_tag('h2', text: 'Analyses de films')
    expect(page).to have_tag('h3', text: titre_film)
    success 'Il peut atteindre l’analyse d’un film'

    within('h2'){click_link 'Analyses de films'}
    expect(page).to have_tag('h2', text: 'Les Analyses de films')
    click_link 'contribuer aux analyses'
    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "analyser"}, text: 'Contribuer')
      with_tag('a', with: {href: "analyse/home"}, text: 'analyses de films')
    end
    success 'il peut atteindre la partie contribuer'

    within('h2'){click_link 'analyses de films'} # à l'intérieur du titre
    expect(page).to have_tag('h2', text: 'Les Analyses de films')
    click_link('consulter l’aide')
    expect(page).to have_tag('h2', text: 'Aide')
    expect(page).to have_tag('h3', text: 'Aide pour les analyses de films')
    success 'il peut atteindre l’aide des analyses de film'

  end


end
