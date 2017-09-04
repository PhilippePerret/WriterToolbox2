require_support_integration


feature "Édition d'un texte quelconque" do
  scenario "Un visiteur quelconque ne peut pas rejoindre la section" do
    visit "#{base_url}/admin/edit_text?path=#{CGI.escape('./un/path.txt')}"
    expect(page).not_to have_tag('h2', text: 'Éditeur de texte')
  end
end
