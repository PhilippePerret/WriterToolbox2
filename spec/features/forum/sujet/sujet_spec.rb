=begin

  La liste des sujets
  -------------------

  Elle est accessible à tout le monde, mais certains peuvent
  créer de nouveaux sujets, d'autres ne peuvent pas.

=end
require_support_integration
require_support_db_for_test
require_support_forum

feature "Liste des sujets", teste: true do
  before(:all) do
    # Effacement de toutes les tables
    forum_truncate_all_tables
    truncate_table_users
    @drene = create_new_user(pseudo: 'René', sexe: 'H')
    @rene = User.get(@drene[:id])
    @dlise = create_new_user(pseudo: 'Lise', sexe: 'F')
    @lise = User.get(@dlise[:id])
    # Création de 50 sujets
    forum_create_sujets 50, {validate: true, auteurs: [1,2,3, @lise.id, @rene.id], with_posts: 3..5}

  end
  scenario "=> Un visiteur quelconque peut consulter la liste des sujets" do
    visit forum_page
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets') do
      with_tag('a', with: {href: 'forum/home'}, text: 'Forum')
    end
    # Les sujets
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('legend', text: 'Liste des sujets')
      with_tag('nav', with:{ class: 'nav_boutons.top'}) do
        with_tag('a', with:{href: "forum/sujet/list?from=20"}, text: 'Sujets suivants')
        without_tag('a', text: 'Sujets précédents')
      end
      with_tag('div', with: {class: 'sujet'}, match: 20)
      all_sujets_forum(0,19).each do |hsujet|
        sid = hsujet[:id]
        with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
          with_tag('a', with:{ href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'posts_count'})
          with_tag('span', with:{class: 'post_date'})
          with_tag('span', with: {class: 'sujet_date'})
          with_tag('span', with: {class: 'sujet_creator'}, text: hsujet[:creator_pseudo])
        end
      end
    end
    # Les boutons
    expect(page).to have_tag('div.forum_boutons') do
      without_tag('a', text: 'Nouveau sujet')
    end
    success 'le visiteur trouve un listing conforme'

    # Le visiteur consulte les autres messages
    within('nav.nav_boutons.top'){click_link 'Sujets suivants'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('nav', with:{ class: 'nav_boutons.top'}) do
        with_tag('a', with:{href: "forum/sujet/list?from=40"}, text: 'Sujets suivants')
        with_tag('a', with:{href: "forum/sujet/list?from=0"}, text: 'Sujets précédents')
      end
      with_tag('div', with: {class: 'sujet'}, match: 20)
      all_sujets_forum(20,20).each do |hsujet|
        sid = hsujet[:id]
        with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
          with_tag('a', with:{ href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'posts_count'})
          with_tag('span', with:{class: 'post_date'})
          with_tag('span', with: {class: 'sujet_date'})
          with_tag('span', with: {class: 'sujet_creator'}, text: hsujet[:creator_pseudo])
        end
      end
    end
    success 'le visiteur peut consulter la liste des 20 sujets suivants'

    # Le visiteur consulte les autres messages
    within('nav.nav_boutons.top'){click_link 'Sujets suivants'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('nav', with:{ class: 'nav_boutons.top'}) do
        without_tag('a', text: 'Sujets suivants')
        with_tag('a', with:{href: "forum/sujet/list?from=20"}, text: 'Sujets précédents')
      end
      derniers_sujets = all_sujets_forum(40,20)
      with_tag('div', with: {class: 'sujet'}, match: 10)
      derniers_sujets.each do |hsujet|
        sid = hsujet[:id]
        with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
          with_tag('a', with:{ href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'posts_count'})
          with_tag('span', with:{class: 'post_date'})
          with_tag('span', with: {class: 'sujet_date'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
          with_tag('span', with: {class: 'sujet_creator'}, text: hsujet[:creator_pseudo])
        end
      end
    end
    success 'le visiteur peut consulter la liste des 10 derniers sujets'


    # Le visiteur consulte les autres messages
    within('nav.nav_boutons.top'){click_link 'Sujets précédents'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('nav', with:{ class: 'nav_boutons.top'}) do
        with_tag('a', with:{href: "forum/sujet/list?from=40"}, text: 'Sujets suivants')
        with_tag('a', with:{href: "forum/sujet/list?from=0"}, text: 'Sujets précédents')
      end
      with_tag('div', with: {class: 'sujet'}, match: 20)
      all_sujets_forum(20,20).each do |hsujet|
        sid = hsujet[:id]
        with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
          with_tag('a', with:{ href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'posts_count'})
          with_tag('span', with:{class: 'post_date'})
          with_tag('span', with: {class: 'sujet_date'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
          with_tag('span', with: {class: 'sujet_creator'}, text: hsujet[:creator_pseudo])
        end
      end
    end
    success 'le visiteur peut revenir à la liste des sujets précédents'

  end


  scenario '=> Un administrateur atteint une liste conforme des sujets' do
    identify phil
    visit forum_page
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets') do
      with_tag('a', with: {href: 'forum/home'}, text: 'Forum')
    end
    # Les sujets
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('legend', text: 'Liste des sujets')
      with_tag('nav', with:{ class: 'nav_boutons.top'}) do
        with_tag('a', with:{href: "forum/sujet/list?from=20"}, text: 'Sujets suivants')
        without_tag('a', with:{href: "forum/sujet/list?from=0"}, text: 'Sujets précédents')
      end
      with_tag('div', with: {class: 'sujet'}, match: 20)
      all_sujets_forum(0,20).each do |hsujet|
        sid = hsujet[:id]
        with_tag('div', with: {class: 'sujet', id: "sujet-#{hsujet[:id]}"}) do
          with_tag('a', with:{ href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
        end
      end
    end
    # Les boutons
    expect(page).to have_tag('div.forum_boutons.top') do
      with_tag('a', with: {href: 'forum/sujet/new'}, text: 'Nouveau sujet/nouvelle question')
    end
    success 'l’administrateur trouve une première liste valide'

    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h3', text: 'Nouveau sujet')
    expect(page).to have_tag('form', with: {id: 'forum_sujet_form'})
    success 'l’administrateur peut rejoindre le formulaire pour créer un nouveau sujet'
  end


end
