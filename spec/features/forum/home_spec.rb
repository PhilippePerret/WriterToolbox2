require_support_integration
require_support_db_for_test

feature "Forum d'écriture" do

  scenario "=> Un visiteur quelconque peut rejoindre le forum d'écriture" do
    visit home_page
    within('section#header'){click_link('outils')}
    within('div#quick_access'){click_link('Forum d’écriture')}

    expect(page).to have_tag('section', with: {id: 'contents'}) do
      with_tag('h2', text: 'Forum d’écriture')
      with_tag('div', text: 'Bienvenue sur le forum d’écriture du site.')
      with_tag('fieldset', with: {id: 'last_public_messages'})
      with_tag('div', with: {class: 'forum_boutons bottom'}) do
        without_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
        with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
        without_tag('a', with: {href: 'forum/message/new'}, text: 'Réponse rapide')
      end
    end
  end

  scenario '=> un PADAWAN trouve un accueil de forum avec les bons éléments' do
    dauteur = create_new_user(mail_confirmed: true)
    auteur = User.get(dauteur[:id])
    opts = auteur.options
    # On définit le niveau de l'auteur
    opts[1] = '0' # ne peut lire que les sujets publics
    auteur.set(options: opts)

    identify dauteur
    within('section#header'){click_link('outils')}
    within('div#quick_access'){click_link('Forum d’écriture')}

    expect(page).to have_tag('section', with: {id: 'contents'}) do
      with_tag('h2', text: 'Forum d’écriture')
      with_tag('div', text: 'Bienvenue sur le forum d’écriture du site.')
      without_tag('fieldset', with: {id: 'last_messages'})
      with_tag('fieldset', with: {id: 'last_public_messages'})
      with_tag('div', with: {class: 'forum_boutons bottom'}) do
        without_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
        with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
        without_tag('a', with: {href: 'forum/message/new'}, text: 'Réponse rapide')
      end
    end
  end


  scenario '=> un SIMPLE AUDITEUR trouve un accueil de forum avec les bons éléments' do
    dauteur = create_new_user(mail_confirmed: true)

    auteur = User.get(dauteur[:id])
    opts = auteur.get(:options)
    # On définit le niveau de l'auteur
    opts[1] = '1' # peut lire tous les messages (publics et privés)
    auteur.set(options: opts)

    identify dauteur
    within('section#header'){click_link('outils')}
    within('div#quick_access'){click_link('Forum d’écriture')}

    expect(page).to have_tag('section', with: {id: 'contents'}) do
      with_tag('h2', text: 'Forum d’écriture')
      with_tag('div', text: 'Bienvenue sur le forum d’écriture du site.')
      with_tag('fieldset', with: {id: 'last_messages'})
      without_tag('fieldset', with: {id: 'last_public_messages'})
      with_tag('div', with: {class: 'forum_boutons bottom'}) do
        without_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
        with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
        without_tag('a', with: {href: 'forum/message/new'}, text: 'Réponse rapide')
      end
    end
  end


  scenario '=> un AUTEUR CONFIRMÉ trouve un accueil de forum avec les bons éléments' do
    dauteur = create_new_user(mail_confirmed: true)
    auteur = User.get(dauteur[:id])
    opts = auteur.get(:options)
    # On définit le niveau de l'auteur
    opts[1] = '7' # ne peut pas clore un sujet
    auteur.set(options: opts)
    identify dauteur
    within('section#header'){click_link('outils')}
    within('div#quick_access'){click_link('Forum d’écriture')}

    expect(page).to have_tag('section', with: {id: 'contents'}) do
      with_tag('h2', text: 'Forum d’écriture')
      with_tag('div', text: 'Bienvenue sur le forum d’écriture du site.')
      with_tag('fieldset', with: {id: 'last_messages'})
      with_tag('div', with: {class: 'forum_boutons bottom'}) do
        with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
        with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
        without_tag('a', with: {href: 'forum/message/new'}, text: 'Réponse rapide')
      end
    end

  end

  scenario '=> Un administrateur trouve un accueil de forum complet' do
    identify phil

    within('section#header'){click_link('outils')}
    within('div#quick_access'){click_link('Forum d’écriture')}

    expect(page).to have_tag('section', with: {id: 'contents'}) do
      with_tag('h2', text: 'Forum d’écriture')
      with_tag('div', text: 'Bienvenue sur le forum d’écriture du site.')
      with_tag('fieldset', with: {id: 'last_messages'})
      with_tag('div', with: {class: 'forum_boutons bottom'}) do
        with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
        with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
        without_tag('a', with: {href: 'forum/message/new'}, text: 'Réponse rapide')
      end
    end

  end



end
