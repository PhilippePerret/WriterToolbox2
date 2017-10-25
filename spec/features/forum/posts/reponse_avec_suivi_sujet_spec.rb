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


  context 'avec un user de grade > 4' do
    scenario 'il peut donner une réponse en demandant à suivre un sujet' do
      start_time = Time.now.to_i
      hauteur = create_new_user(grade: 6, password: 'motdepasse')
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
      footer_jid = "div#post-#{post_id} div.post_footer"
      scrollTo("div##{next_post[:id]}", -300)
      page.execute_script("__notice('J’ai scrollé au post suivant (##{next_post[:id]})')")
      within(footer_jid){click_link 'Répondre'}

      # sleep 10
      # ============> TEST <================
      expect(page).to have_tag('h2', text: /Forum - répondre/)
      expect(page).to have_tag('form#post_answer_form')
      within('form#post_answer_form') do
        fill_in('post_answer', with: "La réponse donnée au message.")
        check('post_suivre')
        click_button 'Publier'
        shot('after-publier-with-suivi')
      end

      # ================== VÉRIFICATIONS ====================

      # sleep 4
      # Un message de confirmation
      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('div.notice', text: /Vous suivez à présent ce sujet/)
      success 'l’user reçoit un message de confirmation'

      # L'user suit le sujet
      hfollow = site.db.select(:forum,'follows',{user_id: hauteur[:id], sujet_id: sujet_id}).first
      expect(hfollow).not_to eq nil
      expect(hfollow[:created_at]).to be > start_time
      success 'un enregistrement est présent dans la table des suivis (follows)'


    end
    #/scénario un visiteur donnant une réponse peut demander à suivre un sujet

    scenario 'le user peut demander à ne plus suivre le sujet en donnant une nouvelle réponse' do

      # Note : on utilise le visiteur créé au test suivant, donc ce test doit
      # suivre le test précédent
      err_mess = "Il faut lancer ce test à la suite du précédent, pour avoir un dernier user qui suit le sujet"

      huser = site.db.select(:hot,'users',"1 = 1 ORDER BY created_at DESC LIMIT 1").first
      huser[:options][1].to_i > 4 || raise(err_mess)
      huser.merge!(password: 'motdepasse')
      user_id = huser[:id]
      hfollow = site.db.select(:forum,'follows',{user_id: huser[:id]}).first
      hfollow != nil || raise(err_mess)
      sujet_id = hfollow[:sujet_id]

      # L'user se rend sur le sujet
      identify huser
      visit "#{base_url}/forum/sujet/#{sujet_id}?from=-1"


      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('fieldset.post_list')
      posts = page.all('fieldset.post_list div.post')
      post_id = posts[1][:id].split('-')[1].to_i
      next_post_domid = posts[2][:id]
      scrollTo("post##{next_post_domid}", -300)
      within("div#post-#{post_id} div.post_footer"){click_link 'Répondre'}
      expect(page).to have_tag('h2', text: 'Forum - répondre')
      success 'l’user rejoint le forum et demande à répondre à un message avec succès'

      # =========== PRÉ-VÉRIFICATION ===========
      expect(page).to have_tag('form#post_answer_form')
      expect(page).to have_field('post_suivre', checked: true)
      success 'l’user trouve un formulaire valide avec la case « suivre le sujet » cochée'

      # ==============> TEST <===============
      within('form#post_answer_form') do
        fill_in('post_answer', with: "Une autre réponse à un autre message.")
        uncheck('post_suivre')
        # sleep 5
        click_button 'Publier'
      end
      success 'l’user peut publier un nouveau message en décochant la case de suivi'

      # =============== VÉRIFICATIONS =================
      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('div.notice', text: /Vous ne suivez plus ce sujet/)
      suivis = site.db.count(:forum,'follows',{user_id: huser[:id], sujet_id: sujet_id})
      expect(suivis).to eq 0
      success 'le suivi a été supprimé'

    end
  end
  #/ Un user de grade > 4

  context 'avec un user de grade inférieur à 4' do
    scenario 'il peut donner une réponse en demandant à suivre un sujet' do
      start_time = Time.now.to_i
      hauteur = create_new_user(grade: 3)
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
      footer_jid = "div#post-#{post_id} div.post_footer"
      scrollTo("div##{next_post[:id]}", -300)
      page.execute_script("__notice('J’ai scrollé au post suivant (##{next_post[:id]})')")
      within(footer_jid){click_link 'Répondre'}

      # sleep 10
      # ============> TEST <================
      expect(page).to have_tag('h2', text: /Forum - répondre/)
      expect(page).to have_tag('form#post_answer_form')
      within('form#post_answer_form') do
        fill_in('post_answer', with: "La réponse donnée au message.")
        check('post_suivre')
        click_button 'Publier'
        shot('after-publier-with-suivi')
      end

      # ================== VÉRIFICATIONS ====================

      # sleep 10
      # Un message de confirmation
      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('div.notice', text: /Vous suivez à présent ce sujet/)
      success 'l’user reçoit un message de confirmation'

      # L'user suit le sujet
      hfollow = site.db.select(:forum,'follows',{user_id: hauteur[:id], sujet_id: sujet_id}).first
      expect(hfollow).not_to eq nil
      expect(hfollow[:created_at]).to be > start_time
      success 'un enregistrement est présent dans la table des suivis (follows)'
    end
    #/scénario un visiteur donnant une réponse peut demander à suivre un sujet

    scenario 'le user peut demander à ne plus suivre le sujet en donnant une nouvelle réponse' do

      # Note : on utilise le visiteur créé au test suivant, donc ce test doit
      # suivre le test précédent
      err_mess = "Il faut lancer ce test à la suite du précédent, pour avoir un dernier user qui suit le sujet"

      huser = site.db.select(:hot,'users',"1 = 1 ORDER BY created_at DESC LIMIT 1").first
      huser[:options][1].to_i < 4 || raise(err_mess)
      huser.merge!(password: 'motdepasse')
      user_id = huser[:id]
      hfollow = site.db.select(:forum,'follows',{user_id: huser[:id]}).first
      hfollow != nil || raise(err_mess)
      sujet_id = hfollow[:sujet_id]

      # L'user se rend sur le sujet
      identify huser
      visit "#{base_url}/forum/sujet/#{sujet_id}?from=-1"


      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('fieldset.post_list')
      posts = page.all('fieldset.post_list div.post')
      post_id = posts[1][:id].split('-')[1].to_i
      next_post_domid = posts[2][:id]
      scrollTo("post##{next_post_domid}", -300)
      within("div#post-#{post_id} div.post_footer"){click_link 'Répondre'}
      expect(page).to have_tag('h2', text: 'Forum - répondre')
      success 'l’user rejoint le forum et demande à répondre à un message avec succès'

      # =========== PRÉ-VÉRIFICATION ===========
      expect(page).to have_tag('form#post_answer_form')
      expect(page).to have_field('post_suivre', checked: true)
      success 'l’user trouve un formulaire valide avec la case « suivre le sujet » cochée'

      # ==============> TEST <===============
      within('form#post_answer_form') do
        fill_in('post_answer', with: "Une autre réponse à un autre message.")
        uncheck('post_suivre')
        # sleep 5
        click_button 'Publier'
      end
      success 'l’user peut publier un nouveau message en décochant la case de suivi'

      # =============== VÉRIFICATIONS =================
      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('div.notice', text: /Vous ne suivez plus ce sujet/)
      suivis = site.db.count(:forum,'follows',{user_id: huser[:id], sujet_id: sujet_id})
      expect(suivis).to eq 0
      success 'le suivi a été supprimé'
    end
    #/scénario : il peut ne plus suivre le sujet

  end


end
