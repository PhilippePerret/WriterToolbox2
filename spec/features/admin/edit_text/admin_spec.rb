require_support_integration


feature "Édition d'un texte quelconque" do
  scenario "Un administrateur peut rejoindre la section" do
    identify phil
    visit "#{base_url}/admin/edit_text?path=#{CGI.escape('./un/path.txt')}"
    sleep 10
    expect(page).to have_tag('h2', text: 'Éditeur de texte')
    expect(page).to have_tag('div', with: {class:'red'}, text: 'Le fichier `./un/path.txt` n’existe pas.')
  end
end
