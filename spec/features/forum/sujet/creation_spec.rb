=begin

  Test de la création d'un sujet ou d'une question technique

=end

require_support_integration
require_support_db_for_test
require_support_forum
require_support_mail_for_test

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
    start_time = Time.now.to_i

    dauteur = get_data_random_user(admin: false, grade: 1)
    identify dauteur
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with: {href: 'forum/sujet/new'}, text: 'Nouvelle question')
    expect(page).not_to have_link 'Nouveau sujet/nouvelle question'
    success 'Il trouve le lien « Nouveau question » mais pas le lien « Nouveau sujet »'

    click_link 'Nouvelle question'
    expect(page).to have_tag('h3', 'Nouvelle question')
    expect(page).to have_tag('form#forum_sujet_form') do
      with_tag('input', with: {type:'text', id:'sujet_titre', name:'sujet[titre]'})
      with_tag('textarea', with: {id:'sujet_first_post', name:'sujet[first_post]'})
      with_tag('label', with:{for: 'sujet_first_post'}, text: 'Merci de préciser votre question')
      with_tag('input', with: {type:'submit', value:'Poser cette question'})
      # Pas de menu pour choisir le type du sujet
      without_tag('select', with:{name:'sujet[type_s]', id: 'sujet_type_s'})
    end
    success 'il trouve un formulaire conforme pour poser sa question'

    within('form#forum_sujet_form') do
      fill_in('sujet_titre', with: "La question de #{dauteur[:pseudo]} du #{Time.now}")
      fill_in('sujet_first_post', with: "Explication de la question de #{dauteur[:pseudo]} du #{Time.now}.")
      click_button 'Poser cette question'
    end
    success 'il remplit correctement le formulaire et le soumet'

    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_content('Merci à vous pour votre participation')
    expect(page).to have_content('La nouvelle question technique est créée')
    expect(page).to have_content('cette question doit être validée')
    expect(page).to have_link('liste des sujets')
    success 'il arrive sur une page de confirmation valide'

    # On récupère le dernier sujet et le dernier message pour vérifier
    hlast_sujet = site.db.select(:forum,'sujets',"created_at > #{start_time}").first
    expect(hlast_sujet).not_to eq nil
    last_sujet_id = hlast_sujet[:id]
    hlast_post = site.db.select(:forum,'posts',"created_at > #{start_time} LIMIT 1").first
    last_post_id = hlast_post[:id]

    expect(hlast_sujet[:titre]).to include "La question de #{dauteur[:pseudo]}"
    expect(hlast_sujet[:creator_id]).to eq dauteur[:id]
    expect(hlast_sujet[:specs][0]).to eq '0'
    expect(hlast_sujet[:last_post_id]).to eq last_post_id
    expect(hlast_sujet[:count]).to eq 1

    expect(hlast_post[:options][0..3]).to eq '0000'
    expect(hlast_post[:sujet_id]).to eq last_sujet_id
    expect(hlast_post[:user_id]).to eq dauteur[:id]
    success 'la question a été correctement enregistrée, marquée « à valider »'

    data_mail = {
      sent_after: start_time,
      subject: 'Sujet forum à valider',
    }
    [phil,marion].each do |admin|
      expect(admin).to have_mail(data_mail)
    end
    success 'les administrateurs ont reçu une demande de validation'

    # Il rejoint l'accueil du Forum
    click_link 'Forum'
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset#last_messages')do
      without_tag('div', with:{class: 'sujet', id: "sujet-#{last_sujet_id}"})
    end
    success 'l’auteur est retourné à l’accueil du forum et ne trouve pas encore sa question)'

  end



















  scenario 'un rédacteur (grade 5) peut créer un sujet quelconque non confirmé' do


    start_time = Time.now.to_i
    dauteur = get_data_random_user(grade: 5, admin:false)

    identify dauteur
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with:{href: 'forum/sujet/new'}, text: 'Nouveau sujet/nouvelle question')
    success 'Il trouve de lien « Nouveau sujet/nouvelle question »'

    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h3', text: 'Nouveau sujet')
    expect(page).to have_tag('form#forum_sujet_form') do
      with_tag('input', with:{type: 'submit', value: 'Initier ce sujet'})
    end
    success 'il trouve un formulaire valide'

    titre_new_sujet = "Un nouveau sujet par #{dauteur[:pseudo]} le #{Time.now.to_i.as_human_date}"
    first_post_new_sujet = "Le premier message de #{titre_new_sujet}"
    within('form#forum_sujet_form') do
      fill_in(:sujet_titre, with: titre_new_sujet)
      fill_in(:sujet_first_post, with: first_post_new_sujet)
      select('Autre sujet', from: 'sujet_type_s')
      click_button 'Initier ce sujet'
    end
    success "#{dauteur[:pseudo]} peut remplir le formulaire et le soumettre avec un sujet d'un autre type"


    # ============ VÉRIFICATION ===============
    expect(page).to have_tag('h2', text: /Forum/)

    hsujet = site.db.select(:forum,'sujets',"created_at > #{start_time}").first
    sid = hsujet[:id]
    hpost  = site.db.select(:forum,'posts',"created_at > #{start_time}").first
    last_post_id = hpost[:id]

    expect(hsujet).not_to eq nil
    expect(hpost).not_to eq nil
    expect(hsujet[:titre]).to eq titre_new_sujet
    specs = hsujet[:specs]
    expect(specs[0]).to eq '0'
    expect(specs[1]).to eq '9'
    expect(specs[4]).to eq '0' # pas d'annonce pour un sujet qui doit être validé
    expect(hsujet[:count]).to eq 1
    expect(hsujet[:last_post_id]).to eq last_post_id
    expect(hpost[:options][0]).to eq '0' # doit être validé
    success 'Le nouveau sujet a été créé dans la base de donnée Forum avec les données valides.'

    expect(page).to have_content("Le nouveau sujet quelconque est créé")
    expect(page).to have_content('ce sujet doit être validé')
    expect(page).to have_tag('a', with: {href: 'forum/sujet/list'}, text: 'liste des sujets')
    success 'l’auteur arrive sur une page valide confirmant la création du sujet et sa validation nécessaire'

    # Il rejoint l'accueil du Forum
    click_link 'Forum'
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset#last_messages')do
      without_tag('div', with:{class: 'sujet', id: "sujet-#{sid}"})
    end
    success 'l’auteur peut rejoindre l’accueil mais ne verra pas encore son nouveau sujet'

    data_mail = {
      sent_after: start_time,
      subject: 'Sujet forum à valider',
    }
    [phil,marion].each do |admin|
      expect(admin).to have_mail(data_mail)
    end
    success 'les administrateurs ont reçu une demande de validation du premier post'
  end























  scenario 'un rédacteur confirmé (8) peut créer un sujet quelconque directement confirmé' do
    start_time = Time.now.to_i
    dauteur = get_data_random_user(grade: 8, admin: false)
    auteur_id = dauteur[:id]

    identify dauteur
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    within('div.forum_boutons.top'){click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('a', with:{href: 'forum/sujet/new'}, text: 'Nouveau sujet/nouvelle question')
    success 'Il trouve le lien « Nouveau sujet/nouvelle question »'

    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h3', text: 'Nouveau sujet')
    titre_new_sujet = "Un nouveau sujet par #{dauteur[:pseudo]} le #{Time.now.to_i.as_human_date}"
    new_sujet_first_post = "Premier message pour #{titre_new_sujet}"
    within('form#forum_sujet_form') do
      fill_in(:sujet_titre, with: titre_new_sujet)
      fill_in(:sujet_first_post, with: new_sujet_first_post)
      select('Question technique d’écriture', from: 'sujet_type_s')
      click_button 'Initier ce sujet'
    end
    success "#{dauteur[:pseudo]} peut remplir le formulaire et le soumettre avec un sujet de type Question"


    # ============ VÉRIFICATION ===============
    expect(page).to have_tag('h2', text: /Forum/)

    hsujet = site.db.select(:forum, 'sujets',"created_at > #{start_time} AND creator_id = #{auteur_id}").first
    sid = hsujet[:id]
    hpost = site.db.select(:forum,'posts',{user_id: auteur_id, sujet_id: sid}).first

    expect(hsujet).not_to eq nil
    expect(hsujet[:titre]).to eq titre_new_sujet
    expect(hsujet[:creator_id]).to eq dauteur[:id]
    specs = hsujet[:specs]
    expect(specs[0]).to eq '1'
    expect(specs[1]).to eq '2'
    expect(specs[4]).to eq '1' # pas d'annonce pour un sujet qui doit être validé
    success 'Le nouveau sujet a été créé dans la base de donnée Forum avec les données correctes.'

    expect(hpost).not_to eq nil # le premier post doit exister
    expect(hpost[:options][0]).to eq '1'
    success 'le premier post existe lui aussi, validé'

    # sleep 60
    expect(page).to have_content("La nouvelle question technique est créée")
    expect(page).not_to have_content('doit être validé')
    expect(page).to have_tag('a', with:{href: "forum/sujet/list?sid=#{sid}"}, text: 'la liste des sujets')
    expect(page).to have_tag('div', with: { class: 'forum_boutons'}) do
      with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
    end
    success 'l’auteur arrive sur une page valide confirmant la création'

    # Il rejoint l'accueil du Forum
    click_link 'Forum'
    # sleep 5*60
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset#last_messages')do
      with_tag('div', with:{class: 'sujet', id: "sujet-#{sid}"}) do
        with_tag('span', with:{ class: 'posts_count'}, text: '1')
        with_tag('span', with:{class: 'sujet_creator'}) do
          with_tag('a', with: {href: "user/profil/#{auteur_id}"}, text: dauteur[:pseudo])
        end
      end
    end
    success 'l’auteur peut rejoindre l’accueil et verra son nouveau sujet, conforme'

    message_init = ["forum/sujet/#{sid}?from=1", "user/profil/#{auteur_id}"]
    data_mail = {
      sent_after: start_time,
      subject:    'Création d’un nouveau sujet',
      message:    nil
    }
    data_mail[:message] = (message_init + ['Chère administratrice'])
    expect(marion).to have_mail(data_mail)
    data_mail[:message] = (message_init + ['Cher administrateur'])
    expect(phil).to have_mail(data_mail)


    success 'Un simple mail d’annonce a été envoyé à l’administration, avec l’adresse vers le sujet'

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
      click_button 'Initier ce sujet'
    end
    success 'Marion peut remplir le formulaire et le soumettre avec un sujet d’un autre type'


    # ============ VÉRIFICATION ===============
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('h3', text: /Confirmation de la création/)

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

    expect(page).to have_content("La nouvelle question technique est créée")
    expect(page).not_to have_content('doit être validé')
    expect(page).to have_tag('a', with:{href: "forum/sujet/list?sid=#{sid}"})
    expect(page).to have_tag('div', with: { class: 'forum_boutons'}) do
      with_tag('a', with: {href: 'forum/sujet/list'}, text: 'Liste des sujets')
    end
    success 'Marion arrive sur une page valide confirmant la création'

    within('div.forum_boutons.top'){ click_link 'Liste des sujets'}
    expect(page).to have_tag('h2', text: 'Forum : sujets')
    expect(page).to have_tag('fieldset', with: {id: 'forum_sujet_list'}) do
      with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
        with_tag('a', with:{ href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
        with_tag('span', with: {class: 'sujet_creator'}) do
          with_tag('a', with:{ href: "user/profil/#{marion.id}"}, text: 'Marion')
        end
        with_tag('span', with: {class: 'sujet_date'}, text: Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M'))
        with_tag('span', with:{class: 'posts_count'}, text: '1')
        with_tag('span', with:{class: 'post_date'})
      end
    end
    success 'Marion peut rejoindre la liste des sujets et verra son nouveau sujet'


    message_init = ["forum/sujet/#{sid}?from=1", "user/profil/#{marion.id}"]
    data_mail = {
      sent_after: start_time,
      subject:    'Création d’un nouveau sujet',
      message:    nil
    }
    data_mail[:message] = (message_init + ['Chère administratrice'])
    expect(marion).to have_mail(data_mail)
    data_mail[:message] = (message_init + ['Cher administrateur'])
    expect(phil).to have_mail(data_mail)

  end

end
