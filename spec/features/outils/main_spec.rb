=begin

  Test de la liste des outils
  ---------------------------

  On s'assure qu'un visiteur quelconque puisse rejoindre une liste des
  outils conforme et qu'il puisse rejoindre chacun de ces outils

=end
require_support_integration

feature "Outils" do
  scenario "=> Un visiteur quelconque peut trouver une liste conforme et opérante des outils" do
    visit home_page
    within('section#header') do
      expect(page).to have_link 'outils'
    end

    listpath = './__SITE__/outils/tool_list.yaml'
    require 'yaml'
    hlist = YAML.load(File.read(listpath).force_encoding('utf-8'))

    click_link('outils', match: :first)
    expect(page).to have_tag('section', with: {id: 'contents'}) do
      with_tag('h2', text: 'Outils d’écriture')
      with_tag('dl', with:{id: 'tool_list'}) do

        # On vérifie que chaque outil soit affiché
        hlist.each do |tid, tdata|
          with_tag('dt', with: {id: "dt-#{tid}" }, text: tdata['name']) do
            with_tag('a', with: {href: "#{tdata['home'] || 'outils'}"})
          end
          with_tag('dd')
        end

      end
    end
    success 'il trouve une liste de tous les outils, complète'

    hlist.each do |tid, tdata|
      expect(page).to have_tag('h2', 'Outils d’écriture')
      scrollTo("dt#dt-#{tid}")
      within("dt#dt-#{tid}") do
        # On clique sur le lien du titre
        click_link tdata['name']
      end
      expect(page).to have_tag('h2', tdata['section_name'] || tdata['name'])
      within('section#header') do
        click_link 'outils'
      end
    end
    success 'il peut rejoindre chaque outil, depuis son titre'

    hlist.each do |tid, tdata|
      expect(page).to have_tag('h2', 'Outils d’écriture')
      within("div#quick_access") do
        click_link tdata['name']
      end
      expect(page).to have_tag('h2', tdata['section_name'] || tdata['name'])
      within('section#header') do
        click_link 'outils'
      end
    end
    success 'il peut rejoindre chaque outil, depuis l’accès rapide'
  end
end
