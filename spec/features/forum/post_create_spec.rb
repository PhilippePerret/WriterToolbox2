require_support_integration
require_support_forum

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
      with_tag('input', with: {type: 'hidden', name:'operation', value: 'answer'})
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
    puts "text_init : #{text_init.inspect}"
    expect(text_init).to start_with "[USER##{hauteur_post[:id]}]"
    expect(text_init).to end_with "[/USER##{hauteur_post[:id]}]"
    expect(text_init).to include hpost[:content][0..50]

    # Le message s'affiche entre balises
    # Il répond au message
    # il soumet la réponse
    # la réponse s'affiche correctement
  end
end
