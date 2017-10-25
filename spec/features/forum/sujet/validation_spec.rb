=begin

  Test de la validation d'un nouveau sujet
  ----------------------------------------

  Scénarios
  =========

  Scénario 1
  ==========
  - Un visiteur de grade < 5 vient créer une nouvelle question technique
  - L'administrateur reçoit la demande de validation
  - L'administrateur valide la question technique
  - L'auteur revient sur le site constater que sa question a été validée

  Scénario 2 (refus de question technique)
  ========================================
  - Un auteur de grade < 5 (3) vient créer une nouvelle question technique
  - L'administrateur refuse cette question technique
  - L'auteur reçoit le refus et le motif

  Scénario 3 (validation de sujet)
  ================================
  - Un auteur de grade 6  vient créer un sujet
  - L'administrateur valide le sujet
  - l'auteur vient constater que son sujet a été validé
  - Un visiteur de grade 4 peut participer au sujet

  Scénario 4 (refus de sujet)
  ===========================
  - Un auteur de grade 6 vient créer un sujet
  - L'administrateur refuse le sujet
  - L'auteur reçoit la notification du refus


  * L'auteur du sujet reçoit l'annonce de la validation de son sujet/question
    quand son (premier) message (de sujet/question) est validé

=end

require_support_integration
require_lib_site
require_support_db_for_test
require_support_mail_for_test

feature 'Validation ou refus de nouveau sujet' do

  before(:all) do
    remove_mails
  end

  before(:each) do
    @start_time = Time.now.to_i
  end
  let(:start_time) { @start_time }



  scenario '=> Un auteur de grade 3 peut créer une question technique validée' do
    dauteur = get_data_random_user(grade: 3, admin: false)
    auteur_id = dauteur[:id]
    pseudo    = dauteur[:pseudo]

    hforum_user = site.db.select(:forum,'users',{id: auteur_id}).first
    # Nombre de messages de l'auteur
    init_count_posts = hforum_user.nil? ? 0 : hforum_user[:count]

    identify dauteur
    visit forum_page
    within('div.forum_boutons.top'){click_link 'Nouvelle question'}
    expect(page).to have_tag('h2',text:'Forum')
    expect(page).to have_tag('h3',text:'Nouvelle question')
    success "#{pseudo} s'identifie et rejoint le formulaire de création de sujet"

    titre_sujet = "Question de #{dauteur[:pseudo]} du #{start_time.as_human_date}"
    first_post  = "Premier message pour la question #{titre_sujet}"
    within('form#forum_sujet_form') do
      fill_in('sujet_titre', with: titre_sujet)
      fill_in('sujet_first_post', with: first_post)
      click_button 'Poser cette question'
    end
    success "#{pseudo} crée la nouvelle question"

    hsujet = site.db.select(:forum,'sujets',"created_at > #{start_time} AND creator_id = #{auteur_id}").first
    hpost  = site.db.select(:forum,'posts',"created_at > #{start_time} AND sujet_id = #{hsujet[:id]}").first
    expect(hsujet).not_to eq nil
    expect(hpost).not_to eq nil
    expect(hsujet[:specs][0]).to eq '0'
    expect(hsujet[:specs][1]).to eq '2'
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    expect(hpost[:options][0]).to eq '0'
    success 'la question et son message ont bien été créés, non validés'

    [phil, marion].each do |admin|
      expect(admin).to have_mail({
        sent_after: start_time,
        subject: 'Sujet forum à valider', # trop compliqué ici de mettre "Question"
        message: ["forum/post/#{hpost[:id]}?op=v", 'valider le message']
      })
    end
    success 'les administrateur ont reçu un mail de demande de validation'

    within('section#header'){click_link 'se déconnecter'}
    expect(page).to have_tag('div.notice', text: /À très bientôt/)
    success "#{pseudo} se déconnecte."

    # ---------------------------------------------------------------------
    # Un administrateur va valider ce sujet

    # Marion veut se rendre directement au post sans s'identifier (depuis
    # son mail)
    visit "#{base_url}/forum/post/#{hpost[:id]}?op=v"
    expect(page).not_to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form') do
      fill_in('user_mail',      with: data_marion[:mail])
      fill_in('user_password',  with: data_marion[:password])
      click_button 'OK'
    end
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_content("Validation du message ##{hpost[:id]}")
    expect(page).to have_tag('form#post_validate_form') do
      with_tag('input', with: {type: 'hidden', name: 'op', value:'validate'})
    end
    success 'après un détour par l’identification, Marion rejoint la page conforme de validation'

    # ============> TEST <===================
    within('form#post_validate_form') do
      click_button 'Valider le message'
    end
    success 'Marion valide la nouvelle question'

    # =============== VÉRIFICATIONS ===============
    expect(page).to have_tag('div.notice', text: /Le message est validé/)
    expect(page).to have_tag('h2', text: /Forum/)
    # On reprend les données actuelles
    hsujet  = site.db.select(:forum,'sujets',{id: hsujet[:id]}).first
    hpost   = site.db.select(:forum,'posts',{id: hpost[:id]}).first
    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    # Le premier bit du post doit être passé à 1
    expect(hpost[:options][0]).to eq '1' # validé
    success 'les nouvelles données du post sont correctes'
    # Le premier bit du sujet doit être passé à 1
    expect(hsujet[:specs][0]).to eq '1' # validé
    expect(hsujet[:specs][4]).to eq '1' # annonce
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    success 'les nouvelles données du sujet sont correctes'
    expect(hauteur[:last_post_id]).to eq hpost[:id]
    expect(hauteur[:count]).to eq init_count_posts + 1
    success 'les nouvelles données de l’auteur sont correctes'

    nombre_suivi = site.db.count(:forum,'follows',{user_id: auteur_id, sujet_id: hsujet[:id]})
    expect(nombre_suivi).to eq 1
    success 'le créateur suit automatiquement sa question'

    within('h2'){click_link 'Forum'}
    expect(page).to have_tag('fieldset#last_messages') do
      with_tag('div', with: {class: 'sujet', id: "sujet-#{hsujet[:id]}"}) do

      end
    end

    # Le créateur du question doit être informé par mail de la validation de sa question
    auteur = User.get(auteur_id)
    expect(auteur).to have_mail({
      sent_after: start_time,
      subject: "",
      message: ["forum/sujet/#{hsujet[:id]}?pid=#{hpost[:id]}"]
    })
    success 'le créateur de la question a reçu un mail de confirmation'

    within('section#header'){click_link 'boite'}
    expect(page).to have_tag('fieldset#last_updates') do
      with_tag('li', text: /Message forum de #{auteur.pseudo}/)
    end
    success 'le nouveau message est annoncé en page d’accueil'


  end








  scenario '=> Un auteur de grade 3 crée une question technique refusée' do

    # Il faut commencer par supprimer toutes les updates pour ne pas avoir
    # de problème avec le message d'accueil
    site.db.use_database(:cold)
    site.db.execute('TRUNCATE TABLE updates;')

    dauteur = get_data_random_user(grade: 3, admin: false)
    auteur_id = dauteur[:id]
    pseudo    = dauteur[:pseudo]

    hforum_user = site.db.select(:forum,'users',{id: auteur_id}).first
    # Nombre de messages de l'auteur
    init_count_posts = hforum_user.nil? ? 0 : hforum_user[:count]

    identify dauteur
    visit forum_page
    within('div.forum_boutons.top'){click_link 'Nouvelle question'}
    expect(page).to have_tag('h2',text:'Forum')
    expect(page).to have_tag('h3',text:'Nouvelle question')
    success "#{pseudo} s'identifie et rejoint le formulaire de création de sujet"

    titre_sujet = "Question de #{dauteur[:pseudo]} du #{start_time.as_human_date}"
    first_post  = "Premier message pour la question #{titre_sujet}"
    within('form#forum_sujet_form') do
      fill_in('sujet_titre', with: titre_sujet)
      fill_in('sujet_first_post', with: first_post)
      click_button 'Poser cette question'
    end
    success "#{pseudo} crée la nouvelle question"

    hsujet = site.db.select(:forum,'sujets',"created_at > #{start_time} AND creator_id = #{auteur_id}").first
    hpost  = site.db.select(:forum,'posts',"created_at > #{start_time} AND sujet_id = #{hsujet[:id]}").first
    expect(hsujet).not_to eq nil
    expect(hpost).not_to eq nil
    expect(hsujet[:specs][0]).to eq '0'
    expect(hsujet[:specs][1]).to eq '2'
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    expect(hpost[:options][0]).to eq '0'
    success 'la question et son message ont bien été créés, non validés'

    [marion, phil].each do |admin|
      expect(phil).to have_mail({
        sent_after: start_time,
        subject: 'Sujet forum à valider', # trop compliqué ici de mettre "Question"
        message: ["forum/post/#{hpost[:id]}?op=v", 'valider le message']
      })
    end
    success 'Les administrateurs ont reçu un mail d’information'

    within('section#header'){click_link 'se déconnecter'}
    expect(page).to have_tag('div.notice', text: /À très bientôt/)
    success "#{pseudo} se déconnecte."

    # ---------------------------------------------------------------------
    # Marion va refuser ce sujet

    # Marion veut se rendre directement au post sans s'identifier (depuis
    # son mail)
    visit "#{base_url}/forum/post/#{hpost[:id]}?op=v"
    expect(page).not_to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form') do
      fill_in('user_mail',      with: data_marion[:mail])
      fill_in('user_password',  with: data_marion[:password])
      click_button 'OK'
    end
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_content("Validation du message ##{hpost[:id]}")
    expect(page).to have_tag('form#post_validate_form') do
      with_tag('input', with: {type: 'hidden', name: 'op', value:'validate'})
    end
    success 'après un détour par l’identification, Marion rejoint la page conforme de validation'


    # ============> TEST <===================
    motif_refus = "Motif du refus du message #{hpost[:id]}"
    within('form#post_validate_form') do
      fill_in('post_motif', with: motif_refus)
      click_button 'Refuser le message'
    end
    success 'Marion refuse la nouvelle question'

    # =============== VÉRIFICATIONS ===============
    expect(page).to have_tag('div.notice', text: /Le message est refusé/)
    expect(page).to have_tag('h2', text: /Forum/)
    # On reprend les données actuelles
    hsujet  = site.db.select(:forum,'sujets',{id: hsujet[:id]}).first
    hpost   = site.db.select(:forum,'posts',{id: hpost[:id]}).first
    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    # Le premier bit du post doit être resté à 0
    expect(hpost[:options][0]).to eq '0' # non validé
    expect(hpost[:options][2]).to eq '1' # refusé
    success 'les nouvelles données du post sont correctes'
    # Le premier bit du sujet doit être resté à 1
    expect(hsujet[:specs][0]).to eq '0' # non validé
    expect(hsujet[:specs][4]).to eq '0' # pas annonce
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    success 'les données du sujet sont correctes (restées les mêmes)'
    expect(hauteur[:last_post_id]).not_to eq hpost[:id]
    expect(hauteur[:count]).to eq init_count_posts
    success 'les données de l’auteur n’ont pas changé'

    nombre_suivi = site.db.count(:forum,'follows',{user_id: auteur_id, sujet_id: hsujet[:id]})
    expect(nombre_suivi).to eq 0
    success 'le créateur ne suit pas sa question'

    within('h2'){click_link 'Forum'}
    expect(page).to have_tag('fieldset#last_messages') do
      without_tag('div', with: {class: 'sujet', id: "sujet-#{hsujet[:id]}"})
    end

    # Le créateur de la question est informé par mail du refus de sa question
    auteur = User.get(auteur_id)
    expect(auteur).to have_mail({
      sent_after: start_time,
      subject: "Votre message sur le forum a été refusé",
      message: ["forum/post/#{hpost[:id]}?op=m", motif_refus]
    })
    success 'le créateur de la question a reçu un mail l’informant du refus avec un lien pour modifier sa question'

    within('section#header'){click_link 'boite'}
    expect(page).to have_tag('fieldset#last_updates') do
      without_tag('li', text: /Message forum de #{auteur.pseudo}/)
    end
    success 'le nouveau message n’est pas annoncé en page d’accueil'



  end











  scenario '=> Un auteur de grade 6 peut créer un sujet validé' do

    dauteur = get_data_random_user(grade: 6, admin: false)
    auteur_id = dauteur[:id]
    pseudo    = dauteur[:pseudo]

    hforum_user = site.db.select(:forum,'users',{id: auteur_id}).first
    # Nombre de messages de l'auteur
    init_count_posts = hforum_user.nil? ? 0 : hforum_user[:count]

    identify dauteur
    visit forum_page
    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h2',text:'Forum')
    expect(page).to have_tag('h3',text:'Nouveau sujet')
    success "#{pseudo} s'identifie et rejoint le formulaire de création de sujet"

    titre_sujet = "Titre de #{dauteur[:pseudo]} du #{start_time.as_human_date}"
    first_post  = "Premier message pour le sujet #{titre_sujet}"
    within('form#forum_sujet_form') do
      fill_in('sujet_titre', with: titre_sujet)
      fill_in('sujet_first_post', with: first_post)
      click_button 'Initier ce sujet'
    end
    success "#{pseudo} crée le nouveau sujet"

    hsujet = site.db.select(:forum,'sujets',"created_at > #{start_time} AND creator_id = #{auteur_id}").first
    hpost  = site.db.select(:forum,'posts',"created_at > #{start_time} AND sujet_id = #{hsujet[:id]}").first
    expect(hsujet).not_to eq nil
    expect(hpost).not_to eq nil
    expect(hsujet[:specs][0]).to eq '0'
    expect(hsujet[:specs][1]).to eq '0' # un sujet (défaut)
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    expect(hpost[:options][0]).to eq '0' # <= important
    success 'le sujet et son message ont bien été créés, non validés'

    [marion,phil].each do |admin|
      expect(admin).to have_mail({
        sent_after: start_time,
        subject: 'Sujet forum à valider',
        message: ["forum/post/#{hpost[:id]}?op=v", 'valider le message']
      })
    end
    success 'les administrateurs ont reçu un mail de demande de validation du message'

    within('section#header'){click_link 'se déconnecter'}
    expect(page).to have_tag('div.notice', text: /À très bientôt/)
    success "#{pseudo} se déconnecte."

    # ---------------------------------------------------------------------
    # Marion va valider ce sujet

    # Marion veut se rendre directement au post sans s'identifier (depuis
    # son mail)
    visit "#{base_url}/forum/post/#{hpost[:id]}?op=v"
    expect(page).not_to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form') do
      fill_in('user_mail',      with: data_marion[:mail])
      fill_in('user_password',  with: data_marion[:password])
      click_button 'OK'
    end
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_content("Validation du message ##{hpost[:id]}")
    expect(page).to have_tag('form#post_validate_form') do
      with_tag('input', with: {type: 'hidden', name: 'op', value:'validate'})
    end
    success 'après un détour par l’identification, Marion rejoint la page conforme de validation'

    # ============> TEST <===================
    within('form#post_validate_form') do
      click_button 'Valider le message'
    end
    success 'Marion valide le nouveau sujet (en validant le message)'

    # =============== VÉRIFICATIONS ===============
    expect(page).to have_tag('div.notice', text: /Le message est validé/)
    expect(page).to have_tag('h2', text: /Forum/)
    # On reprend les données actuelles
    hsujet  = site.db.select(:forum,'sujets',{id: hsujet[:id]}).first
    hpost   = site.db.select(:forum,'posts',{id: hpost[:id]}).first
    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    # Le premier bit du post doit être passé à 1
    expect(hpost[:options][0]).to eq '1' # validé
    success 'les nouvelles données du post sont correctes'
    # Le premier bit du sujet doit être passé à 1
    expect(hsujet[:specs][0]).to eq '1' # validé
    expect(hsujet[:specs][4]).to eq '1' # annonce
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    success 'les nouvelles données du sujet sont correctes'
    expect(hauteur[:last_post_id]).to eq hpost[:id]
    expect(hauteur[:count]).to eq init_count_posts + 1
    success 'les nouvelles données de l’auteur sont correctes'

    nombre_suivi = site.db.count(:forum,'follows',{user_id: auteur_id, sujet_id: hsujet[:id]})
    expect(nombre_suivi).to eq 1
    success 'le créateur suit automatiquement son sujet'

    within('h2'){click_link 'Forum'}
    expect(page).to have_tag('fieldset#last_messages') do
      with_tag('div', with: {class: 'sujet', id: "sujet-#{hsujet[:id]}"}) do

      end
    end

    # Le créateur du question doit être informé par mail de la validation de sa question
    auteur = User.get(auteur_id)
    expect(auteur).to have_mail({
      sent_after: start_time,
      subject: "",
      message: ["forum/sujet/#{hsujet[:id]}?pid=#{hpost[:id]}"]
    })
    success 'le créateur du sujet a reçu un mail de confirmation'

    within('section#header'){click_link 'boite'}
    expect(page).to have_tag('fieldset#last_updates') do
      with_tag('li', text: /Message forum de #{auteur.pseudo}/)
    end
    success 'le nouveau message est annoncé en page d’accueil'

  end











  scenario '=> Un auteur de grade 6 crée un sujet refusé' do

    # Il faut commencer par supprimer toutes les updates pour ne pas avoir
    # de problème avec le message d'accueil
    site.db.use_database(:cold)
    site.db.execute('TRUNCATE TABLE updates;')


    dauteur = get_data_random_user(grade: 6, admin: false)
    auteur_id = dauteur[:id]
    pseudo    = dauteur[:pseudo]

    hforum_user = site.db.select(:forum,'users',{id: auteur_id}).first
    # Nombre de messages de l'auteur
    init_count_posts = hforum_user.nil? ? 0 : hforum_user[:count]

    identify dauteur
    visit forum_page
    within('div.forum_boutons.top'){click_link 'Nouveau sujet/nouvelle question'}
    expect(page).to have_tag('h2',text:'Forum')
    expect(page).to have_tag('h3',text:'Nouveau sujet')
    success "#{pseudo} s'identifie et rejoint le formulaire de création de sujet"

    titre_sujet = "Titre de #{dauteur[:pseudo]} du #{start_time.as_human_date}"
    first_post  = "Premier message pour le sujet #{titre_sujet}"
    within('form#forum_sujet_form') do
      fill_in('sujet_titre', with: titre_sujet)
      fill_in('sujet_first_post', with: first_post)
      click_button 'Initier ce sujet'
    end
    success "#{pseudo} crée le nouveau sujet"

    hsujet = site.db.select(:forum,'sujets',"created_at > #{start_time} AND creator_id = #{auteur_id}").first
    hpost  = site.db.select(:forum,'posts',"created_at > #{start_time} AND sujet_id = #{hsujet[:id]}").first
    expect(hsujet).not_to eq nil
    expect(hpost).not_to eq nil
    expect(hsujet[:specs][0]).to eq '0'
    expect(hsujet[:specs][1]).to eq '0'
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    expect(hpost[:options][0]).to eq '0'
    success 'le sujet et son message ont bien été créés, non validés'

    [marion, phil].each do |admin|
      expect(admin).to have_mail({
        sent_after: start_time,
        subject: 'Sujet forum à valider',
        message: ["forum/post/#{hpost[:id]}?op=v", 'valider le message']
      })
    end
    success 'les administrateurs ont reçu un mail d’information'

    within('section#header'){click_link 'se déconnecter'}
    expect(page).to have_tag('div.notice', text: /À très bientôt/)
    success "#{pseudo} se déconnecte."

    # ---------------------------------------------------------------------
    # Marion va valider ce sujet

    # Marion veut se rendre directement au post sans s'identifier (depuis
    # son mail)
    visit "#{base_url}/forum/post/#{hpost[:id]}?op=v"
    expect(page).not_to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form') do
      fill_in('user_mail',      with: data_marion[:mail])
      fill_in('user_password',  with: data_marion[:password])
      click_button 'OK'
    end
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_content("Validation du message ##{hpost[:id]}")
    expect(page).to have_tag('form#post_validate_form') do
      with_tag('input', with: {type: 'hidden', name: 'op', value:'validate'})
    end
    success 'après un détour par l’identification, Marion rejoint la page conforme de validation'



    # ============> TEST <===================
    motif_refus = "Motif du refus du message #{hpost[:id]}"
    within('form#post_validate_form') do
      fill_in('post_motif', with: motif_refus)
      click_button 'Refuser le message'
    end
    success 'Marion refuse le nouveau sujet'

    # =============== VÉRIFICATIONS ===============
    expect(page).to have_tag('div.notice', text: /Le message est refusé/)
    expect(page).to have_tag('h2', text: /Forum/)
    # On reprend les données actuelles
    hsujet  = site.db.select(:forum,'sujets',{id: hsujet[:id]}).first
    hpost   = site.db.select(:forum,'posts',{id: hpost[:id]}).first
    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    # Le premier bit du post doit être resté à 0
    expect(hpost[:options][0]).to eq '0' # non validé
    expect(hpost[:options][2]).to eq '1' # refusé
    success 'les nouvelles données du post sont correctes'
    # Le premier bit du sujet doit être resté à 1
    expect(hsujet[:specs][0]).to eq '0' # non validé
    expect(hsujet[:specs][4]).to eq '0' # pas annonce
    expect(hsujet[:last_post_id]).to eq hpost[:id]
    success 'les données du sujet sont correctes (restées les mêmes)'
    expect(hauteur[:last_post_id]).not_to eq hpost[:id]
    expect(hauteur[:count]).to eq init_count_posts
    success 'les données de l’auteur n’ont pas changé'

    nombre_suivi = site.db.count(:forum,'follows',{user_id: auteur_id, sujet_id: hsujet[:id]})
    expect(nombre_suivi).to eq 0
    success 'le créateur ne suit pas sa question'

    within('h2'){click_link 'Forum'}
    expect(page).to have_tag('fieldset#last_messages') do
      without_tag('div', with: {class: 'sujet', id: "sujet-#{hsujet[:id]}"})
    end

    # Le créateur de la question est informé par mail du refus de sa question
    auteur = User.get(auteur_id)
    expect(auteur).to have_mail({
      sent_after: start_time,
      subject: "Votre message sur le forum a été refusé",
      message: ["forum/post/#{hpost[:id]}?op=m", motif_refus]
    })
    success 'le créateur de la question a reçu un mail l’informant du refus avec un lien pour modifier sa question'

    within('section#header'){click_link 'boite'}
    expect(page).to have_tag('fieldset#last_updates') do
      without_tag('li', text: /Message forum de #{auteur.pseudo}/)
    end
    success 'le nouveau message n’est pas annoncé en page d’accueil'



  end

end
