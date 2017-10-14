=begin

  Test des votes pour les messages

=end

require_lib_site
require_support_integration
require_support_forum
require_support_db_for_test
require_support_mails_for_test

feature 'Vote pour les messages' do
  before(:all) do
    # S'il n'y a aucun message validé, on reset le forum pour les tests
    if site.db.count(:forum,'posts', "SUBSTRING(options,1,1) = '1'") == 0
      reset_all_data_forum
    end
  end

  scenario '=> Un simple visiteur ne peut pas voter (il trouve les boutons mais inactifs)' do
    visit forum_page
    first_sujet = page.all("fieldset#last_public_messages div.sujet")[0]
    sujet_domid = first_sujet[:id]
    within("fieldset#last_public_messages div##{sujet_domid} div.last_post"){click_link 'Dernier message'}
    # sleep 2*60
    allposts = page.all("fieldset.post_list div.post")
    first_post = allposts[0]
    first_post_domid = first_post[:id]
    first_post_id = first_post_domid.split('-').last.to_i
    vote_init = site.db.select(:forum,'posts_votes',{id: first_post_id},[:vote]).first[:vote]
    # puts "ID premier post : #{first_post_id}"
    expect(page).to have_selector("fieldset.post_list div##{first_post_domid} div.post_header a[href=\"forum/post/#{first_post_id}?op=u\"]")
    expect(page).to have_selector("fieldset.post_list div##{first_post_domid} div.post_header a[href=\"forum/post/#{first_post_id}?op=d\"]")
    success 'il trouve les boutons pour voter'

    # L'user essaie de cliquer les boutons
    scrollTo("fieldset.post_list div##{first_post_domid} div.post_header",+100)
    within("fieldset.post_list div##{first_post_domid} div.post_header"){
      click_link '👍'
    }
    expect(page).to have_tag('div.error', text: /vous n’avez pas encore le droit de voter/)

    scrollTo("fieldset.post_list div##{first_post_domid} div.post_header",+100)
    within("fieldset.post_list div##{first_post_domid} div.post_header"){
      click_link '👎'
    }
    expect(page).to have_tag('div.error', text: /vous n’avez pas encore le droit de voter/)

    new_votes = site.db.select(:forum,'posts_votes',{id: first_post_id},[:vote]).first[:vote]
    expect(new_votes).to eq vote_init
    success 'les données du message n’ont pas été modifiées'
  end

  scenario '=> Un simple visiteur ne peut pas forcer le vote (up ou down) par l’URL' do
    post_id = site.db.select(:forum,'posts',"1 = 1 LIMIT 1",[:id]).first[:id]
    # puts "Post-ID = #{post_id}"
    post_votes = site.db.select(:forum,'posts_votes',{id: post_id}).first
    vote_init = post_votes[:vote].to_i
    visit home_page # Pour avoir :last_page
    visit "#{base_url}/forum/post/#{post_id}?op=u"
    expect(page).to have_tag('div.error', text: /mais vous n’avez pas encore le droit de voter/)
    post_votes = site.db.select(:forum,'posts_votes',{id: post_id}).first
    expect(post_votes[:vote]).to eq vote_init
    success 'il ne peut pas forcer un up-vote'

    visit home_page # Pour avoir :last_page
    visit "#{base_url}/forum/post/#{post_id}?op=d"
    expect(page).to have_tag('div.error', text: /mais vous n’avez pas encore le droit de voter/)
    post_votes = site.db.select(:forum,'posts_votes',{id: post_id}).first
    expect(post_votes[:vote]).to eq vote_init
    success 'il ne peut pas forcer un down-vote'
  end


  scenario '=> un inscrit de grade 2 peut up-voter pour un message' do
    hreader = create_new_user(mail_confirmed: true, grade: 2)
    hpost = forum_get_random_post(not_user_id: hreader[:id])
    # On prend aussi les données initiales de l'user
    # ATTENTION : il s'agit de la table users dans le forum
    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first

    post_id = hpost[:id]
    # puts "hpost: #{hpost.inspect}"
    sujet_id = hpost[:sujet_id]
    notice "Données pour test du UP-vote"
    notice "ID Post   : #{post_id}"
    notice "ID Sujet  : #{sujet_id}"
    notice "ID Auteur : #{hpost[:user_id]}"
    notice "ID Reader : #{hreader[:id]}"

    identify hreader
    visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{hpost[:id]}"
    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_header a[href=\"forum/post/#{post_id}?op=u\"]")
    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_header a[href=\"forum/post/#{post_id}?op=d\"]")
    success 'le message présente les deux boutons pour up-voter et down-voter'

    # ===========> TEST <===============
    within("fieldset.post_list div#post-#{post_id} div.post_header") do
      click_link '👍'
    end

    # sleep 15

    # ============== VÉRIFICATION ==============
    expect(page).to have_tag('div.notice', text: /Votre vote a été enregistré/)
    expect(page).to have_tag('div.notice', text: /Merci à vous/)
    newhpost = forum_get_post(post_id)
    expect(newhpost[:vote]).to eq hpost[:vote] + 1
    upvotes = newhpost[:upvotes].as_id_list
    expect(upvotes).to include hreader[:id]
    success 'le post a été incrémenté d’une unité et l’ID du lecteur ajouté à upvotes'

    newhauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    expect(newhauteur[:upvotes]).to eq hauteur[:upvotes] + 1
    expect(newhauteur[:count]).to eq hauteur[:count]
    success 'la cote de l’auteur du post a été incrémentée d’une unité mais pas son count de messages'

    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_footer") do
      with_tag('a', {href: "forum/post/#{post_id}?op=d"}, text: "- up")
      without_tag('a', text: /\+ ?1/)
      without_tag('a', text: /\- ?1/)
      without_tag('a', text: '- down')
    end
    success 'la page présente les bons nouveaux boutons'


    # ============> TEST 2 : retirer le up-vote <===================
    visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{post_id}"
    success 'le reader peut-il retirer son up-vote ?'
    scrollTo("fieldset.post_list div#post-#{post_id} div.post_footer", +300)
    # sleep 4
    within("fieldset.post_list div#post-#{post_id} div.post_footer") do
      click_link("- up")
      sleep 3
      shot('after-click-moins-up')
    end
    expect(page).to have_tag('div.notice', text: /Votre vote a été enregistré/)
    expect(page).to have_tag('div.notice', text: /Merci à vous/)
    newhpost = forum_get_post(post_id)
    expect(newhpost[:vote]).to eq hpost[:vote]
    upvotes = newhpost[:upvotes].as_id_list
    expect(upvotes).not_to include hreader[:id]
    success 'le post a retrouvé sa valeur initial et le lecteur a été retiré des up-votants'

    newhauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    expect(newhauteur[:upvotes]).to eq hauteur[:upvotes]
    success 'la cote de l’auteur du post a retrouvé sa valeur initiale'

    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_footer") do
      without_tag('a', {href: "forum/post/#{post_id}?op=d"}, text: "- up")
      without_tag('a', {href: "forum/post/#{post_id}?op=u"}, text: "- down")
      with_tag('a', text: /\+ ?1/)
      with_tag('a', text: /\- ?1/)
    end
    success 'la page présente les bons nouveaux boutons'

  end

  scenario '=> un inscrit de grade 2 peut down-voter pour un message' do
    hreader = create_new_user(mail_confirmed: true, grade: 2)
    hpost = forum_get_random_post(not_user_id: hreader[:id])
    # On prend aussi les données initiales de l'user
    # ATTENTION : il s'agit de la table users dans le forum
    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first

    post_id = hpost[:id]
    # puts "hpost: #{hpost.inspect}"
    sujet_id = hpost[:sujet_id]
    notice "Données pour test du DOWN-vote"
    notice "ID Post   : #{post_id}"
    notice "ID Sujet  : #{sujet_id}"
    notice "ID Auteur : #{hpost[:user_id]}"
    notice "ID Reader : #{hreader[:id]}"

    identify hreader
    visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{hpost[:id]}"
    shot 'page-forum-pour-down-vote'
    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_header a[href=\"forum/post/#{post_id}?op=u\"]")
    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_header a[href=\"forum/post/#{post_id}?op=d\"]")
    success 'le message présente les deux boutons pour up-voter et down-voter'

    # ===========> TEST <===============
    scrollTo("fieldset.post_list div#post-#{post_id} div.post_header", +200)
    within("fieldset.post_list div#post-#{post_id} div.post_header") do
      click_link '👎'
    end

    # sleep 15

    # ============== VÉRIFICATION ==============
    expect(page).to have_tag('div.notice', text: /Votre vote a été enregistré/)
    expect(page).to have_tag('div.notice', text: /Merci à vous/)
    newhpost = forum_get_post(post_id)
    expect(newhpost[:vote]).to eq hpost[:vote] - 1
    downvotes = newhpost[:downvotes].as_id_list
    expect(downvotes).to include hreader[:id]
    success 'le post a été décrémenté d’une unité et l’ID du lecteur ajouté à downvotes'

    newhauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    expect(newhauteur[:downvotes]).to eq hauteur[:downvotes] + 1
    expect(newhauteur[:count]).to eq hauteur[:count]
    success 'la cote de l’auteur du post a été décrémenté d’une unité mais pas son count de messages'


    # ================> TEST 2 (retirer le downvote) <====================
    visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{post_id}"
    success 'le reader peut-il retirer son down-vote ?'
    # sleep 4
    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_footer") do
      with_tag('a', with:{href: "forum/post/#{post_id}?op=u"}, text: '- down')
    end
    scrollTo("fieldset.post_list div#post-#{post_id} div.post_footer", +100)
    within("fieldset.post_list div#post-#{post_id} div.post_footer") do
      # sleep 60
      click_link("- down")
      sleep 2
      shot('after-click-moins-down')
    end
    expect(page).to have_tag('div.notice', text: /Votre vote a été enregistré/)
    expect(page).to have_tag('div.notice', text: /Merci à vous/)
    newhpost = forum_get_post(post_id)
    expect(newhpost[:vote]).to eq hpost[:vote]
    downvotes = newhpost[:downvotes].as_id_list
    expect(downvotes).not_to include hreader[:id]
    success 'le post a retrouvé sa valeur initial et le lecteur a été retiré des down-votants'

    newhauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    expect(newhauteur[:downvotes]).to eq hauteur[:downvotes]
    success 'la cote de l’auteur du post a retrouvé sa valeur initiale'

    expect(page).to have_selector("fieldset.post_list div#post-#{post_id} div.post_footer") do
      without_tag('a', {href: "forum/post/#{post_id}?op=d"}, text: "- up")
      without_tag('a', {href: "forum/post/#{post_id}?op=u"}, text: "- down")
      with_tag('a', text: /\+ ?1/)
      with_tag('a', text: /\- ?1/)
    end
    success 'la page présente les bons nouveaux boutons (+1 et -1)'
  end

  scenario '=> un lecteur de grade 2 peut voter pour un message' do
    hreader = create_new_user(mail_confirmed: true, grade: 2)

  end

  scenario '=> un lecteur qui a déjà up-voté pour un message ne peut pas forcer un autre upvote' do

    reader_id = nil
    while reader_id.nil?
      hpost = forum_get_random_post(upvoted: true)
      post_id = hpost[:id]
      auteur_id = hpost[:user_id]
      upvotants = hpost[:upvotes].as_id_list
      rid = upvotants[rand(upvotants.count)]
      if rid != auteur_id && User.get(rid).grade >= 2
        reader_id = rid
        break
      else
        "Reader essayé : ##{rid}"
      end
    end
    # notice "Données pour forcer deuxième UP-vote"
    # notice "ID post   : #{post_id}"
    # notice "ID auteur : #{auteur_id}"
    # notice "Upvotant  : #{reader_id} (choisi au hasard)"

    case reader_id
    when 1 then identify phil
    when 3 then identify marion
    else
      hreader = get_data_user(reader_id)
      identify hreader
    end

    # =========== PRÉPARATION ===============
    # On prend les données initiales de votes
    hpost   = site.db.select(:forum,'posts_votes',{id: post_id},[:upvotes, :vote]).first
    auteur_upvotes = site.db.select(:forum,'users',{id: auteur_id},[:upvotes]).first[:upvotes]

    # =============> TEST <==============
    visit home_page # pour avoir une :last_page
    visit "#{base_url}/forum/post/#{post_id}?op=u"
    # sleep 5

    # ============= VÉRIFICATION ============
    expect(page).to have_tag('div.error', text: /Vous avez déjà up-voté pour ce message/)
    success 'un message informe l’user de son erreur'
    newhpost   = site.db.select(:forum,'posts_votes',{id: post_id},[:upvotes, :vote]).first
    expect(newhpost[:upvotes]).to eq hpost[:upvotes]
    expect(newhpost[:vote]).to eq hpost[:vote]
    new_auteur_upvotes = site.db.select(:forum,'users',{id: auteur_id},[:upvotes]).first[:upvotes]
    expect(new_auteur_upvotes).to eq auteur_upvotes
    success 'les données des votes (post et auteur du post n’ont pas modifié)'

  end




  scenario '=> un lecteur qui a déjà down-voté pour un message ne peut pas forcer un autre downvote' do

    reader_id = nil
    while reader_id.nil?
      hpost = forum_get_random_post(downvoted: true)
      post_id = hpost[:id]
      auteur_id = hpost[:user_id]
      downvotants = hpost[:downvotes].as_id_list
      rid = downvotants[rand(downvotants.count)]
      if rid != auteur_id && User.get(rid).grade >= 2
        reader_id = rid
        break
      end
    end
    # notice "Données pour forcer deuxième UP-vote"
    # notice "ID post   : #{post_id}"
    # notice "ID auteur : #{auteur_id}"
    # notice "Upvotant  : #{reader_id} (choisi au hasard)"

    case reader_id
    when 1 then identify phil
    when 3 then identify marion
    else
      hreader = get_data_user(reader_id)
      identify hreader
    end

    # =========== PRÉPARATION ===============
    # On prend les données initiales de votes
    hpost   = site.db.select(:forum,'posts_votes',{id: post_id},[:downvotes, :vote]).first
    auteur_downvotes = site.db.select(:forum,'users',{id: auteur_id},[:downvotes]).first[:downvotes]

    # =============> TEST <==============
    visit home_page # pour avoir une :last_page
    visit "#{base_url}/forum/post/#{post_id}?op=d"
    # sleep 5

    # ============= VÉRIFICATION ============
    expect(page).to have_tag('div.error', text: /Vous avez déjà down-voté pour ce message/)
    success 'un message informe l’user de son erreur'
    newhpost   = site.db.select(:forum,'posts_votes',{id: post_id},[:downvotes, :vote]).first
    expect(newhpost[:downvotes]).to eq hpost[:downvotes]
    expect(newhpost[:vote]).to eq hpost[:vote]
    new_auteur_downvotes = site.db.select(:forum,'users',{id: auteur_id},[:downvotes]).first[:downvotes]
    expect(new_auteur_downvotes).to eq auteur_downvotes
    success 'les données des votes (post et auteur du post n’ont pas modifié)'

  end

end
