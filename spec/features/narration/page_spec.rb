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
    sleep 10

    expect(page).to have_tag('h2', 'La collection Narration')
    expect(page).to have_tag('h3', text: /L'Analyse de film/)
    expect(page).to have_tag('h2', text: /Deuxième phase de l'analyse/)
    page_path = './__SITE__/narration/_data/analyse/collecte/2e_phase_analyse.md'
    expect(page).to have_tag('a', text: 'text', with:{href:"admin/edit_text?path=#{CGI.escape(page_path)}"})
    expect(page).to have_tag('a', text: 'data', with:{href:'admin/narration/138?op=edit_data'})
  end

  scenario '=> Une page normale contient les éléments normaux' do

    visit "#{base_url}/narration/page/6" # Livre structure

    success 'une page correcte…'

    expect(page).to have_tag('section',with:{class:'page_narration', id: 'page_narration-6'})
    success 'contient la section.page_narration'

    expect(page).to have_tag('span', with:{class: 'chap_titre'}) do
      with_tag('a', with:{href: 'narration/page/1'}, text: 'Introduction à la structure')
    end
    success 'contient le titre du chapitre'

    expect(page).to have_tag('span', with:{class:'schap_titre'}) do
      with_tag('a', with:{href: 'narration/page/2'}, text: 'Prologue')
    end
    success 'contient le titre du sous-chapitre'

    expect(page).to have_tag('h2', with:{class: 'titre_page'}, text: 'Choix des films')
    success 'contient le titre de la page'

    expect(page).to have_tag('span', with:{class: 'lien_prev_page'}) do
      with_tag('a', with:{href: 'narration/page/5'})
    end
    success 'contient le bouton pour la page précédente'

    expect(page).to have_tag('span', with:{class:'lien_next_page'}) do
      with_tag('a', with:{href: 'narration/page/7'})
    end
    success 'contient le bouton pour la page suivante'

    expect(page).to have_tag('span', with:{class:'lien_main_page'}) do
      with_tag('a', with:{href: 'narration/livre/1'}, text: 'Table des matières')
    end
    success 'contient le lien pour la table des matières du livre'

    expect(page).not_to have_link('éditer')
    success 'ne contient pas le lien pour éditer la page'

  end
  scenario '=> un chapitre normal contient les éléments normaux' do

    failure 'contient la section.chap_narration'
    failure 'contient le titre du chapitre'
    failure 'ne contient pas le titre du sous-chapitre'
    failure 'contient le bouton pour la page précédente'
    failure 'contient le bouton pour la page suivante'
    failure 'contient le lien pour la table des matières du livre'
    failure 'ne contient pas le lien pour éditer la page'

  end
  scenario '=> un sous-chapitre normal contient les éléments normaux' do

    failure 'contient la section.schap_narration'
    failure 'contient le titre du chapitre'
    failure 'contient le titre du sous-chapitre'
    failure 'contient le bouton pour la page précédente'
    failure 'contient le bouton pour la page suivante'
    failure 'contient le lien pour la table des matières du livre'
    failure 'ne contient pas le lien pour éditer la page'

  end
end
