require_lib_site
require_support_integration
require_support_forum
require_support_db_for_test
require_support_mails_for_test

=begin

  Ce test teste qu'un administrateur (Marion ici) puisse répondre à
  n'importe quel message dans n'importe quel sujet.
  Son message est automatiquement validé, c'est-à-dire, en d'autres termes :
  - qu'il apparait dans le listing du sujet
  - qu'il est annoncé en page d'accueil
  - qu'il est annoncé à l'user concernéa

=end

feature "Création de message" do
# feature "Création de message", teste: true do
  before(:all) do
    # Si les données ont besoin d'être rafraîchies :
    # reset_all_data_forum
    require_folder('./__SITE__/forum/_lib/_required')
    expect(defined?(Forum)).to eq 'constant'
  end
  scenario '=> Un ADMINISTRATEUR peut créer un message dans n’importe quel sujet' do

    identify marion

    # Marion clique sur le premier sujet (dernier message)
    begin
      visit forum_page
      expect(page).to have_tag('h2', text: 'Forum d’écriture')
      n = page.all('fieldset#last_messages div.sujet')[0]
      # sleep 15
      n != nil || raise
    rescue Exception => e
      if site.db.count(:forum,'posts') == 0
        reset_all_data_forum
        retry
      else
        raise "Impossible d'effectuer ce test : il y a des messages, mais je ne les trouve pas…"
      end
    end
    sujet_id = n[:id].split('-').last.to_i
    notice "ID Sujet : #{sujet_id}"

    page.find("span#sujet-#{sujet_id}-titre a").click

    # Pour savoir si le sujet est bien affiché
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sujet_id}"})

    # Pour choisir au hasard un message
    post_divs = page.all('div.post')
    nombre_posts = post_divs.count

    post_id = nil
    hpost   = nil
    begin
      post_div = post_divs[rand(0..nombre_posts-1)]
      post_id = post_div[:id].split('-').last.to_i
      hpost = site.db.select(:forum,'posts',{id: post_id}).first
      # puts "hpost: #{hpost.inspect}"
    end while hpost[:user_id] == marion.id
    notice "ID Post : #{post_id}"
    hauteur_post = site.db.select(:hot,'users',{id: hpost[:user_id]}).first
    notice "ID Auteur post : #{hauteur_post[:id]}"
    hpost.merge!( content: site.db.select(:forum,'posts_content',{id: post_id},[:content]).first[:content])


    # On supprimer le pied de page pour ne pas avoir de problème
    # (parfois, on clique dessus au lieu de cliquer sur "Répondre", même en scrollant)
    page.execute_script("document.querySelector('section#footer').style.display='none';")

    # L'admin clique sur le bouton "Répondre" du message
    scrollTo("div#post-#{post_id} div.post_footer")
    within("div#post-#{post_id} div.post_footer div.buttons"){click_link 'Répondre'}

    # Il rejoint le formulaire de réponse
    expect(page).to have_tag('h2', text: /Forum/)

    expect(page).to have_tag('form', with: {id: "post_answer_form"}) do
      with_tag('input', with: {type: 'hidden', name:'post[id]', id: 'post_id', value: post_id.to_s})
      with_tag('input', with: {type: 'hidden', name:'op', value: 'save'})
      with_tag('input', with: {type: 'hidden', name:'post[auteur_reponse_id]', value: marion.id.to_s})
      with_tag('label', text: 'Votre réponse')
      with_tag('textarea', with: {name: 'post[answer]', id: 'post_answer'})
      with_tag('div.buttons') do
        # with_tag('button', with: {onclick: "setOperationApercu(this.form);"}, text: 'Aperçu')
        with_tag('input', with: {type: 'submit', value: 'Publier'})
      end
    end
    success 'Marion rejoint un formulaire de réponse valide'

    # Le textarea doit contenir le texte du message original
    text_init = page.execute_script("return document.getElementById('post_answer').value;")
    # puts "text_init : #{text_init.inspect}"
    # Le message s'affiche entre balises
    user_tag = "USER##{hauteur_post[:pseudo]}"
    expect(text_init).to start_with "[#{user_tag}]"
    expect(text_init).to end_with "[/#{user_tag}]"
    expect(text_init).to include hpost[:content][0..50]

    # Marion répond au message
    # Note : on garde seulement la première citation
    citIn = text_init.index("[#{user_tag}]")
    citOut = text_init.index("[/#{user_tag}]") + "[/#{user_tag}]".length - 1
    extrait = text_init[citIn..citOut]
    reponse = extrait + "\n\nLa réponse de Marion du #{Time.now}.\n\nC'est une réponse en plusieurs lignes."

    # sleep 5*60
    within('form#post_answer_form') do
      fill_in('post_answer', with: reponse)
      shot 'before-submit-reponse-marion'
      scrollTo('form#post_answer_form div.buttons')
      click_button 'Publier'
    end

    # sleep 60
    expect(page).to have_tag('h2', text: /Forum/)

    # La réponse est enregistrée
    hpost = site.db.select(:forum,'posts',{parent_id: post_id, user_id: marion.id}).first
    expect(hpost).not_to eq nil
    # On vérifie la réponse enregistrée
    expect(hpost[:options][0]).to eq '1' # le message est validé
    rep_post = Forum::Post.get(hpost[:id])
    rep_post.data # pour charger les données complètes (tout à fait complète)

    reponse_expected  = reponse.strip.gsub(/^\s+/, '').gsub(/\n/,'').gsub(/<.*?>/,'')
    post_content      = rep_post.data[:content].gsub(/<.*?>/,'')
    expect(post_content).to eq reponse_expected
    success 'la réponse est correctement enregistrée'
  end




  scenario '=> Un rédacteur de grade 4 peut émettre un message sans validation' do

    start_time = Time.new.to_i

    # On trouve un sujet qui possède au moins 30 messages
    hsujet = forum_get_sujet(minimum_count: 30)
    hposts = forum_get_posts_of_sujet(hsujet[:id])

    first_post  = hposts.first
    last_post   = hposts.last

    hmarceline = site.db.select(:hot,'users',{pseudo: 'MarcelineRédactrice'}).first
    if hmarceline
      # Si MarcelineRédactrice existe déjà, il faut supprimer tous ses
      # messages, au cas où (pour ne pas arriver sur une page qui contiendrait
      # tous ses messages et donc aucun lien pour "Répondre")
      delete_all_posts_of(hmarceline[:id])
    else
      hmarceline = create_new_user({
        mail_confirmed: true,
        grade:  4,
        pseudo: 'MarcelineRédactrice',
        sexe:   'F',
        password:  'marceline'
        })
    end
    hmarceline.merge!(password: 'marceline')

    # Nombre de messages au départ, doit être 0
    initial_count = 0
    hmar = site.db.select(:forum,'users',{id: hmarceline[:id]}).first
    if hmar
      initial_count = hmar[:count]
    end
    expect(initial_count).to eq 0

    # puts "Premier post : #{hposts.first.inspect}"

    # Marceline rejoint un sujet quelconque pour répondre au dernier message
    identify hmarceline
    visit "#{base_url}/forum/sujet/#{hsujet[:id]}?from=1"
    expect(page).to have_tag('h2', text: /Forum/)

    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{first_post[:id]}"}) do
        with_tag('a', text: 'Répondre')
      end
      without_tag('div', with: {class: 'post', id: "post-#{last_post[:id]}"})
    end
    success 'Marceline trouve le premier sujet avec le premier message (et un bouton pour y répondre)'

    within('fieldset.post_list div.btns_other_posts.top'){click_link 'derniers messages'}
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{last_post[:id]}"}) do
        with_tag('a', text: 'Répondre')
      end
      without_tag('div', with: {class: 'post', id: "post-#{first_post[:id]}"})
    end
    success 'Marceline peut rejoindre le tout dernier message (avec bouton « Répondre ») grâce au bouton « derniers messages »'


    # Marceline va répondre au tout dernier message
    # (par mesure de prudence, on supprime le pied de page)
    page.execute_script("document.querySelector('section#footer').style.display='none';")
    scrollTo("fieldset.post_list div#post-#{last_post[:id]}")
    # sleep 5
    within("div#post-#{last_post[:id]} div.post_footer"){click_link 'Répondre'}
    # sleep 10
    expect(page).to have_tag('h2', text: 'Forum - répondre')
    expect(page).to have_tag('form#post_answer_form') do
      with_tag('input', with: {type: 'hidden', id: "post_id", value: last_post[:id].to_s})
    end
    success 'Marceline peut rejoindre le formulaire de réponse au dernier message'

    # Marceline donne sa réponse
    reponse_marceline = <<-TXT
    Bonjour,

    Je m'appelle [i]Marceline[/i] et je suis d'accord avec [strong]vous[/strong].

    [center]Attention ![/center]

    Cependant, vous devriez lire la page d'[BOA=narration/home]accueil de la collection[/BOA] pour savoir de quoi vous parlez.

    Bien à vous,

    Marceline
    TXT
    within('form#post_answer_form') do
      fill_in('post_answer', with: reponse_marceline)
      # sleep 30
      click_button 'Publier'
    end
    success 'Marceline peut transmettre sa réponse'

    # sleep 30


    # On récupère le nouveau message créé
    hlast = forum_get_last_post

    expect(hlast).not_to eq nil
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{hlast[:id]}"}) do
        with_tag('div.user_card') do
          with_tag('span.pseudo', text: 'MarcelineRédactrice')
        end
      end
    end
    success 'Marceline se retrouve sur le fil de discussion, avec son message affiché'

    # La réponse est bien enregistré dans la base de donnée
    reponse_formated = reponse_marceline.split("\n\n").collect{|p| "<p>#{p.strip}</p>"}.join('')
    expect(hlast[:content]).to eq reponse_formated
    expect(hlast[:user_id]).to eq hmarceline[:id]
    expect(hlast[:sujet_id]).to eq hsujet[:id]
    expect(hlast[:parent_id]).to eq last_post[:id]
    success 'la réponse est correctement enregistrée dans la DB'

    hmar = site.db.select(:forum,'users',{id: hmarceline[:id]}).first
    expect(hmar[:count]).to eq initial_count + 1
    success 'le nombre de messages de Marceline a été incrémenté'
    expect(hmar[:last_post_id]).to eq hlast[:id]
    success 'l’ID du dernier message de Marceline a été correctement réglé'
    hsuj = site.db.select(:forum,'sujets',{id: hsujet[:id]}).first
    expect(hsuj[:last_post_id]).to eq hlast[:id]
    success 'l’ID du dernier message du sujet a été correctement réglé'

    # Un mail a été envoyé à l'auteur du message original
    auteur_post = User.get(last_post[:auteur_id])
    expect(auteur_post).to have_mail({
      sent_after: start_time,
      subject:    'Votre message a reçu une réponse sur le forum'
      })
    success 'un message a été envoyé à l’auteur du message original'

    # On récupère la dernière actualité dans la base de données
    where = "created_at > #{start_time} LIMIT 1"
    hupdate = site.db.select(:cold,'updates',where).first
    expect(hupdate).not_to eq nil
    expect(hupdate[:type]).to eq 'forum'
    expect(hupdate[:annonce]).to eq nil
    expect(hupdate[:options][0]).to eq '1' # à annoncer à tout le monde + accueil
    expect(hupdate[:route]).to eq "forum/sujet/#{hsujet[:id]}?pid=#{hlast[:id]}"

    visit home_page
    expect(page).to have_tag('fieldset#last_updates') do
      with_tag('ul.updates') do
        with_tag('li', with:{class:'update', id: "update-#{hupdate[:id]}"}) do
          with_tag('span', with:{class: 'date'}, text: Time.now.strftime('%d %m %Y'))
          with_tag('span', text: 'Message forum de MarcelineRédactrice.')
        end
      end
    end
    success 'Marceline revient en page d’accueil et voit une annonce affichée (enregistrée dans l’historique)'

  end
  # / Marceline peut répondre directement à un message

end
