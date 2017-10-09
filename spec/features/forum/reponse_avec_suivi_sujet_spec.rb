=begin

  Cette feuille teste la réponse donné à un sujet avec ou non
  option de suivre le sujet

  Pour simplifier, on prend un user qui a le grade suffisant pour
  ne pas avoir à valider son message.

=end

require_lib_site
require_support_integration
require_support_forum
require_support_db_for_test
require_support_mails_for_test

feature "Suivi d'un sujet en donnant une réponse" do
  scenario 'Un visiteur donnant une réponse peut suivre un sujet' do
    hauteur = create_new_user(mail_confirmed: true, grade: 6)
    hsujet = forum_get_sujet
    sujet_id = hsujet[:id]

    # Le visiteur rejoint le site, s'identifie, puis rejoint le sujet
    identify hauteur
    visit "#{base_url}/forum/sujet/#{sujet_id}?from=-1"

    expect(page).to have_tag('fieldset.post_list')

    # Le visiteur clique un bouton "Répondre" quelconque
    posts = page.all("fieldset.post_list div.post")
    index_dernier_post = posts.count - 2
    post_index = rand(index_dernier_post)
    post = posts[post_index]
    next_post = posts[post_index + 1] # Pour scroller
    post_id = post[:id].split('-')[1].to_i
    puts "post_id = #{post_id}"
    footer_jid = "div#post-#{post_id} div.post_footer"
    scrollTo("div##{next_post[:id]}")
    scrollTo(footer_jid)
    within(footer_jid){click_link 'Répondre'}

    # sleep 10
    # Le visiteur arrive sur la page de réponse
    expect(page).to have_tag('h2', text: /Forum - répondre/)
    expect(page).to have_tag('form#post_answer_form')
    within('form#post_answer_form') do
      
    end
  end

  scenario 'Un visiteur donnant une réponse peut ne plus suivre un sujet' do
    # Le visiteur suit le sujet
    hfollower = create_new_user(mail_confirmed: true, grade: 6)
    hsujet = forum_get_sujet
    sujet_id = hsujet[:id]

    # Requête pour que le visiteur suive le sujet
    site.db.use_database(:forum)
    site.db.execute(
      "INSERT INTO follows (user_id, sujet_id, created_at) VALUES (?, ?, ?)",
      [hfollower[:id], sujet_id, Time.now.to_i - 2.mois]
    )

  end
end
