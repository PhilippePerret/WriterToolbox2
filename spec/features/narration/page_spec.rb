require_lib_site
require_support_integration


feature "Affichage d'une page de la collection Narration" do
  scenario "Un visiteur quelconque peut voir une page achevée" do

    visit "#{base_url}/narration/page/138"

    expect(page).to have_tag('h2', 'La collection Narration')
    expect(page).to have_tag('h3', text: /L'Analyse de film/)
    expect(page).to have_tag('h3', text: /Deuxième phase de l'analyse/) do
      without_tag('a', text: 'éditer')
    end


  end
  scenario 'Un visiteur quelconque ne peut pas voir une page insuffamment développée' do
    pending
  end
  scenario 'Un administrateur peut toujours voir une page quelconque' do
    identify phil

    visit "#{base_url}/narration/page/138"

    expect(page).to have_tag('h2', 'La collection Narration')
    expect(page).to have_tag('h3', text: /L'Analyse de film/)
    expect(page).to have_tag('h3', text: /Deuxième phase de l'analyse/) do
      with_tag('a', text: 'éditer', with:{href:'admin/narration/138?op=edit_page'})
    end
  end
end
