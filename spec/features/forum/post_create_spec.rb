require_support_integration
require_support_forum

=begin

  Ce test teste qu'un administrateur (Marion ici) puisse répondre à
  n'importe quel message dans n'importe quel sujet.
  Son message est automatiquement validé, c'est-à-dire, en d'autres termes :
  - qu'il apparait dans le listing du sujet
  - qu'il est annoncé en page d'accueil
  - qu'il est annoncé à l'user concernéa

=end

feature "Création de message" do
  before(:all) do
    # Si les données ont besoin d'être rafraîchies :
    # reset_all_data_forum
  end
  scenario '=> Un ADMINISTRATEUR peut créer un message dans n’importe quel sujet' do

    identify marion

    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')

    # Marion clique sur le premier sujet (dernier message)
    n = page.all('fieldset#last_messages div.sujet')[0]
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


    # L'admin clique sur le bouton "Répondre" du message
    scrollTo("div#post-#{post_id}")
    within("div#post-#{post_id} div.post_footer div.buttons"){click_link 'Répondre'}

    # Il rejoint le formulaire de réponse
    expect(page).to have_tag('h2', text: /Forum/)

    expect(page).to have_tag('form', with: {id: "post_answer_form"}) do
      with_tag('input', with: {type: 'hidden', name:'post[id]', id: 'post_id', value: post_id.to_s})
      with_tag('input', with: {type: 'hidden', name:'operation', value: 'save'})
      with_tag('input', with: {type: 'hidden', name:'post[auteur_reponse_id]', value: marion.id.to_s})
      with_tag('label', text: 'Votre réponse')
      with_tag('textarea', with: {name: 'post[answer]', id: 'post_answer'})
      with_tag('div.buttons') do
        with_tag('button', with: {onclick: "setOperationApercu(this.form);"}, text: 'Aperçu')
        with_tag('input', with: {type: 'submit', value: 'Publier'})
      end
    end
    success 'Marion rejoint un formulaire de réponse valide'

    # Le textarea doit contenir le texte du message original
    text_init = page.execute_script("return document.getElementById('post_answer').value;")
    # puts "text_init : #{text_init.inspect}"
    # Le message s'affiche entre balises
    user_tag = "USER##{hauteur_post[:id]}"
    expect(text_init).to start_with "[#{user_tag}]"
    expect(text_init).to end_with "[/#{user_tag}]"
    expect(text_init).to include hpost[:content][0..50]

    # Il répond au message
    # Note : on garde seulement la première citation
    offset = text_init.index("[#{user_tag}]", text_init.index("[/#{user_tag}]"))
    extrait = text_init[0..offset-1]

    reponse = extrait + "\n\nLa réponse de Marion.\n\nC'est une réponse en plusieurs lignes."

    within('form#post_answer_form') do
      fill_in('post_answer', with: reponse)
      shot 'before-submit-reponse-marion'
      click_button 'Publier'
    end

    expect(page).to have_tag('h2', text: /Forum/)

    # La réponse est enregistrée
    hpost = site.db.select(:forum,'posts',{parent_id: post_id, user_id: marion.id}).first
    expect(hpost).not_to eq nil
    # On vérifie la réponse enregistrée
    expect(hpost[:options][0]).to eq '1' # le message est validé
    rep_post = Forum::Post.get(hpost[:id])
    rep_post.data # pour charger les données complètes
    reponse_content = <<-HTML
    <p>#{extrait}</p><p>La réponse de Marion.</p><p>C'est une réponse en plusieurs lignes.</p>
    HTML
    expect(rep_post.data[:content]).to eq reponse_content.strip.gsub(/^\s+/, '')
    # la réponse s'affiche correctement
  end
end
