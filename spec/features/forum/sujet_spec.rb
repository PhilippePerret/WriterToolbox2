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
          with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'messages_count', id: "messages_count-#{sid}"})
          with_tag('span', with:{class: 'last_message_date', id:"last_message_date-#{sid}"})
          with_tag('span', with: {class: 'created_at'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
          with_tag('span', with: {class: 'creator'}, text: hsujet[:creator_pseudo])
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
          with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'messages_count', id: "messages_count-#{sid}"})
          with_tag('span', with:{class: 'last_message_date', id:"last_message_date-#{sid}"})
          with_tag('span', with: {class: 'created_at'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
          with_tag('span', with: {class: 'creator'}, text: hsujet[:creator_pseudo])
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
          with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'messages_count', id: "messages_count-#{sid}"})
          with_tag('span', with:{class: 'last_message_date', id:"last_message_date-#{sid}"})
          with_tag('span', with: {class: 'created_at'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
          with_tag('span', with: {class: 'creator'}, text: hsujet[:creator_pseudo])
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
          with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
          with_tag('span', with:{class: 'messages_count', id: "messages_count-#{sid}"})
          with_tag('span', with:{class: 'last_message_date', id:"last_message_date-#{sid}"})
          with_tag('span', with: {class: 'created_at'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
          with_tag('span', with: {class: 'creator'}, text: hsujet[:creator_pseudo])
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
          with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
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


  scenario '=> un simple visiteur ne peut pas créer de sujet' do
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).not_to have_link 'Nouveau sujet'
    success 'Il ne trouve pas de lien « Nouveau sujet »'

    visit "#{base_url}/forum/sujet/new"
    expect(page).to have_tag('div.error', text: /vous ne pouvez pas atteindre le vue demandée/)
    success 'Il ne peut pas forcer l’adresse vers le formulaire'

    visit "#{base_url}/forum/sujet/create"
    expect(page).to have_tag('div.error', text: /vous ne pouvez pas atteindre le vue demandée/)
    success 'Il ne peut pas forcer l’adresse vers la création'
  end

  scenario 'un visiteur inscrit peut créer une question technique' do
    dauteur = create_new_user(mail_confirmed: true)
    identify dauteur
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with: {href: 'forum/sujet/new'}, text: 'Nouvelle question')
    expect(page).not_to have_link 'Nouveau sujet/nouvelle question'
    success 'Il trouve le lien « Nouveau question » mais pas le lien « Nouveau sujet »'
  end

  scenario 'un rédacteur (grade 5) peut créer un sujet quelconque non confirmé' do
    start_time = Time.now.to_i
    dauteur = create_new_user(mail_confirmed: true, grade: 5)
    identify dauteur
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with:{href: 'forum/sujet/new'}, text: 'Nouveau sujet/nouvelle question')
    success 'Il trouve de lien « Nouveau sujet/nouvelle question »'

    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h3', text: 'Nouveau sujet')
    titre_new_sujet = "Un nouveau sujet par #{dauteur[:pseudo]}"
    within('form#forum_sujet_form') do
      fill_in(:sujet_titre, with: titre_new_sujet)
      select('Autre sujet', from: 'sujet_type_s')
      click_button 'Créer'
    end
    success "#{dauteur[:pseudo]} peut remplir le formulaire et le soumettre avec un sujet d'un autre type"


    # ============ VÉRIFICATION ===============
    expect(page).to have_tag('h2', text: 'Forum : sujets')

    hsujet = site.db.select(:forum, 'sujets',"created_at > #{start_time}").first
    sid = hsujet[:id]
    expect(hsujet).not_to eq nil
    expect(hsujet[:titre]).to eq titre_new_sujet
    specs = hsujet[:specs]
    expect(specs[0]).to eq '0'
    expect(specs[1]).to eq '9'
    expect(specs[4]).to eq '0' # pas d'annonce pour un sujet qui doit être validé
    success 'Le nouveau sujet a été créé dans la base de donnée Forum avec les données correctes.'

    expect(page).to have_content("Le nouveau sujet est créé")
    expect(page).to have_content('doit être validé')
    expect(page).to have_tag('a', with:{href: "forum/post/new?sid=#{sid}"})
    expect(page).to have_tag('div', with: { class: 'forum_boutons'}) do
      with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
    end
    success 'l’auteur arrive sur une page valide confirmant la création'

    within('div.forum_boutons.top'){ click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      without_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"})
    end
    success 'l’auteur peut rejoindre la liste des sujets mais ne verra pas encore son nouveau sujet'
  end

  scenario 'un rédacteur confirmé (8) peut créer un sujet quelconque directement confirmé' do
    start_time = Time.now.to_i
    dauteur = create_new_user(mail_confirmed: true, grade: 8)
    identify dauteur
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with:{href: 'forum/sujet/new'}, text: 'Nouveau sujet/nouvelle question')
    success 'Il trouve de lien « Nouveau sujet/nouvelle question »'

    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h3', text: 'Nouveau sujet')
    titre_new_sujet = "Un nouveau sujet par #{dauteur[:pseudo]}"
    within('form#forum_sujet_form') do
      fill_in(:sujet_titre, with: titre_new_sujet)
      select('Question technique d’écriture', from: 'sujet_type_s')
      click_button 'Créer'
    end
    success "#{dauteur[:pseudo]} peut remplir le formulaire et le soumettre avec un sujet d'un autre type"


    # ============ VÉRIFICATION ===============
    expect(page).to have_tag('h2', text: 'Forum : sujets')

    hsujet = site.db.select(:forum, 'sujets',"created_at > #{start_time}").first
    sid = hsujet[:id]
    expect(hsujet).not_to eq nil
    expect(hsujet[:titre]).to eq titre_new_sujet
    expect(hsujet[:creator_id]).to eq dauteur[:id]
    specs = hsujet[:specs]
    expect(specs[0]).to eq '1'
    expect(specs[1]).to eq '2'
    expect(specs[4]).to eq '1' # pas d'annonce pour un sujet qui doit être validé
    success 'Le nouveau sujet a été créé dans la base de donnée Forum avec les données correctes.'

    expect(page).to have_content("Le nouveau sujet est créé")
    expect(page).not_to have_content('doit être validé')
    expect(page).to have_tag('a', with:{href: "forum/post/new?sid=#{sid}"})
    expect(page).to have_tag('div', with: { class: 'forum_boutons'}) do
      with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
    end
    success 'l’auteur arrive sur une page valide confirmant la création'

    within('div.forum_boutons.top'){ click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    # page.execute_script('__notice("Vous pouvez vérifier la présence du sujet #'+sid.to_s+'")')
    # sleep 5 * 60
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
        with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
        with_tag('span', with:{class: 'messages_count', id: "messages_count-#{sid}"})
        with_tag('span', with:{class: 'last_message_date', id:"last_message_date-#{sid}"})
        with_tag('span', with: {class: 'created_at'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
        with_tag('span', with: {class: 'creator'}, text: dauteur[:pseudo])
      end
    end
    success 'l’auteur peut rejoindre la liste des sujets et verra son nouveau sujet'

  end

  scenario 'une administratrice (Marion) peut créer un sujet quelconque directement confirmé' do
    start_time = Time.now.to_i

    identify marion
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with:{href: 'forum/sujet/new'}, text: 'Nouveau sujet/nouvelle question')
    success 'Marion trouve le lien « Nouveau sujet/nouvelle question »'

    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h3', text: 'Nouveau sujet')
    titre_new_sujet = "Un nouveau sujet par Marion"
    within('form#forum_sujet_form') do
      fill_in(:sujet_titre, with: titre_new_sujet)
      select('Question technique d’écriture', from: 'sujet_type_s')
      click_button 'Créer'
    end
    success 'Marion peut remplir le formulaire et le soumettre avec un sujet d’un autre type'


    # ============ VÉRIFICATION ===============
    expect(page).to have_tag('h2', text: 'Forum : sujets')

    hsujet = site.db.select(:forum, 'sujets',"created_at > #{start_time}").first
    sid = hsujet[:id]
    expect(hsujet).not_to eq nil
    expect(hsujet[:titre]).to eq titre_new_sujet
    expect(hsujet[:creator_id]).to eq marion.id
    specs = hsujet[:specs]
    expect(specs[0]).to eq '1'
    expect(specs[1]).to eq '2'
    expect(specs[4]).to eq '1' # Annonce car sujet validé
    success 'Le nouveau sujet a été créé dans la base de donnée Forum avec les données correctes.'

    expect(page).to have_content("Le nouveau sujet est créé")
    expect(page).not_to have_content('doit être validé')
    expect(page).to have_tag('a', with:{href: "forum/post/new?sid=#{sid}"})
    expect(page).to have_tag('div', with: { class: 'forum_boutons'}) do
      with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
    end
    success 'Marion arrive sur une page valide confirmant la création'

    within('div.forum_boutons.top'){ click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
        with_tag('a', with:{ href: "forum/sujet/#{sid}"}, text: hsujet[:titre])
        with_tag('span', with:{class: 'messages_count', id: "messages_count-#{sid}"})
        with_tag('span', with:{class: 'last_message_date', id:"last_message_date-#{sid}"})
        with_tag('span', with: {class: 'created_at'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
        with_tag('span', with: {class: 'creator'}, text: 'Marion')
      end
    end
    success 'Marion peut rejoindre la liste des sujets et verra son nouveau sujet'

  end

end
