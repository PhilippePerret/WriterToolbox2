=begin

  Test de la création d'un sujet ou d'une question technique

=end

require_support_integration
require_support_db_for_test
require_support_forum

feature "Création de sujet/question technique" do


  scenario '=> un simple visiteur ne peut pas créer de sujet' do
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).not_to have_link 'Nouveau sujet'
    success 'Il ne trouve pas de lien « Nouveau sujet »'
    expect(page).to have_link 'Nouvelle question'
    success 'mail il trouve un lien « Nouvelle question »'

    click_link('Nouvelle question', match: :first)
    success 'Il peut cliquer sur le ligne « Nouvelle question » et rejoint la création du sujet'
    expect(page).not_to have_tag('form#forum_sujet_form')
    expect(page).to have_tag('p.bulle', text: /Pour pouvoir poser une question/)
    expect(page).to have_tag('p.bulle', text: /vous devez être inscrit/)
    success 'mais il ne trouve pas le formulaire mais une invitation à s’inscrire'

    expect(page).to have_tag('h2', text: 'Forum') do
      with_tag('a', with: {href: 'forum/home'})
    end
    success 'le titre lié lui permet de revenir à l’accueil du forum'
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
