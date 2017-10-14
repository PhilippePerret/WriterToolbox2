=begin

  Cette feuille présente un test complet du cycle de refus d'un message,
  jusqu'à sa validation :

  - Un user dépose un message (son grade est insuffisant, le post doit être validé)
  - Un administrateur (Phil) refuse le message
  - L'user vient modifier son message et le soumet à nouveau
  - Un administrateur (Marion) vient accepter le message
  
=end
require_lib_site
require_support_integration
require_support_forum
require_support_db_for_test
require_support_mails_for_test

feature "Forum : réponse à un message et REFUS ARGUMENTÉ par un administrateur" do
  before(:all) do
      # Si les données ont besoin d'être rafraîchies :
      # reset_all_data_forum
      require_folder('./__SITE__/forum/_lib/_required')
      expect(defined?(Forum)).to eq 'constant'
    end
  scenario "=> Un utilisateur de grade inférieur à 4 doit être validé pour être publié" do

    remove_mails
    start_time = Time.now.to_i

    happrenti = site.db.select(:hot,'users',{pseudo: 'Apprenti Surveillé'}).first
    if happrenti
      delete_all_posts_of(happrenti[:id])
      happrenti.merge!(password: 'apprenti')
    else
      happrenti = create_new_user({
        mail_confirmed: true,
        grade: 3,
        pseudo:   'Apprenti Surveillé',
        password: 'apprenti'
      })
    end

    hsujet = forum_get_sujet(minimum_count: 30)
    hposts = forum_get_posts_of_sujet(hsujet[:id])

    first_post  = hposts.first
    last_post   = hposts.last

    # puts "Premier post : #{hposts.first.inspect}"

    # Apprenti rejoint un sujet quelconque
    identify happrenti
    visit "#{base_url}/forum/sujet/#{hsujet[:id]}?from=1"
    expect(page).to have_tag('h2', text: /Forum/)

    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{first_post[:id]}"}) do
        with_tag('a', text: 'Répondre')
      end
      without_tag('div', with: {class: 'post', id: "post-#{last_post[:id]}"})
    end
    success 'Apprenti trouve le premier sujet avec le premier message (et un bouton pour y répondre)'

    within('fieldset.post_list div.btns_other_posts.top'){click_link 'derniers messages'}
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{last_post[:id]}"}) do
        with_tag('a', text: 'Répondre')
      end
      without_tag('div', with: {class: 'post', id: "post-#{first_post[:id]}"})
    end
    success 'Apprenti peut rejoindre le tout dernier message (avec bouton « Répondre ») grâce au bouton « derniers messages »'


    # Apprenti va répondre au tout dernier message
    # (par mesure de prudence, on supprime le pied de page, sinon, on risque de cliquer dessus)
    page.execute_script("document.querySelector('section#footer').style.display='none';")
    scrollTo("fieldset.post_list div#post-#{last_post[:id]}")
    # sleep 5
    within("div#post-#{last_post[:id]} div.post_footer"){click_link 'Répondre'}
    # sleep 10
    expect(page).to have_tag('h2', text: 'Forum - répondre')
    expect(page).to have_tag('form#post_answer_form') do
      with_tag('input', with: {type: 'hidden', id: "post_id", value: last_post[:id].to_s})
    end
    success 'Apprenti peut rejoindre le formulaire de réponse au dernier message'

    # Apprenti donne sa réponse
    reponse_apprenti = <<-TXT
    Bonjour,

    Je suis un [b]apprenti[/b] et je suis d'accord avec [del]vous[/del] [ins]toi[/ins].

    [center]Attention ![/center]

    Cependant, vous devriez lire la page d'[BOA=narration/home]accueil de la collection[/BOA] pour savoir de quoi vous parlez.

    Bien à vous,

    Apprenti Surveillé
    TXT
    within('form#post_answer_form') do
      fill_in('post_answer', with: reponse_apprenti)
      click_button 'Publier'
    end
    success 'Apprenti peut transmettre sa réponse'

    # sleep 30


    # On récupère le nouveau message
    hlast = forum_get_last_post

    expect(hlast).not_to eq nil
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('div.notice', text: /Votre réponse a été enregistrée/)
    expect(page).to have_tag('div.notice', text: /elle devra être validée/)

    expect(hlast[:user_id]).to eq happrenti[:id]
    expect(hlast[:options][0]).to eq '0'
    expect(hlast[:parent_id]).to eq last_post[:id]
    expect(hlast[:sujet_id]).to eq hsujet[:id]
    success 'le message est enregistré correctement dans la DB'

    hu = site.db.select(:forum,'users',{id: happrenti[:id]}).first
    if hu != nil
      expect(hu[:last_post_id]).not_to eq hlast[:id]
    end
    hs = site.db.select(:forum,'sujets',{id: hsujet[:id]}).first
    expect(hs[:last_post_id]).not_to eq hlast[:id]
    success 'le message n’est pas mis ne dernier message du sujet ni en dernier message d’Apprenti'

    data_mail = {
      sent_after: start_time,
      subject: 'Message forum à valider',
      message: ["Message ##{hlast[:id]}", "forum/post/#{hlast[:id]}?op=v", "Apprenti Surveillé"]
      }
    expect(phil).to have_mail(data_mail)
    expect(marion).to have_mail(data_mail)
    success 'Un message valide a été envoyé aux administrateurs pour valider le message'


    expect(page).to have_tag('a', with: {href: "forum/sujet/#{hsujet[:id]}?from=-1"}, text: 'Retourner au sujet')
    success 'La page contient un lien pour retourner sur le fil du sujet'

    # S'il rejoint la liste du sujet, Apprenti ne voit pas son nouveau message

    click_link "Retourner au sujet"
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset.post_list') do
      without_tag('div', with: {class: 'post', id: "post-#{hlast[:id]}"})
    end
    success 'Le message d’Apprenti ne se retrouve pas sur le fil de discussion'
  end












  scenario '=> Un administrateur peut REFUSER le message' do

    start_time = Time.now.to_i

    # Note : ce scénario suit le précédent, il se sert du mail envoyé à
    # moi (phil@laboiteaoutilsdelauteur.fr) pour relever le lien
    mails_validation = Array.new
    Dir["./xtmp/mails/*.msh"].reverse.each do |mpath|
      mdata = Marshal.load(File.read(mpath))
      if mdata[:to] == 'phil@laboiteaoutilsdelauteur.fr'
        if mdata[:subject] =~ /Message forum à valider/
          mails_validation << mdata
        end
      end
    end
    # Parmi la liste des messages de validation, on prend le message qui n'est
    # pas encore validé
    post_id         = nil
    url_validation  = nil
    mails_validation.each do |mdata|
      pid = mdata[:message].match(/forum\/post\/([0-9]+)\?op=v/).to_a[1].to_i
      opts = site.db.select(:forum,'posts',{id: pid},[:options]).first[:options]
      if opts[0..2] == '000' # => non validé
        post_id = pid
        url_validation = mdata[:message].match(/forum\/post\/([0-9]+)\?op=v/).to_a[0]
        break
      end
    end

    if post_id.nil?
      raise "Impossible de procéder à ce test, aucun message n'est à valider. Lancer le test de toute la feuille pour procéder à ce scénario."
    else
      # puts "Message à valider : #{post_id}"
      # puts "URL de validation : #{url_validation}"
      hpost = site.db.select(:forum,'posts',{id: post_id}).first
      hpost.merge!(
        content: site.db.select(:forum,'posts_content',{id: post_id},[:content]).first[:content]
      )
    end

    # L'administrateur essaie de se rendre directement à l'adresse de validation
    visit "#{base_url}/#{url_validation}"
    # sleep 30
    expect(page).not_to have_tag('h2', text: 'Forum - validation de message')
    expect(page).to have_tag('div.notice', text: /vous devez être identifié/)
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form') do
      fill_in('user_mail',      with: data_phil[:mail])
      fill_in('user_password',  with: data_phil[:password])
      click_button 'OK'
    end
    # sleep 15
    expect(page).to have_tag('h2', text: 'Forum - validation de message')
    success 'l’administrateur a été redirigé vers la page de validation après son identification'

    expect(page).to have_tag('form', with: {id: 'post_validate_form'}) do
      extrait = hpost[:content].gsub(/\[(.*?)\]/, '').gsub(/<.*?>/,'')[0..50]
      with_tag('div', with: {id: 'post_content'}, text: /#{extrait}/)
      with_tag('input', with: {type: 'hidden', name:'op', value: 'validate'})
      with_tag('textarea', with: {name: 'post[motif]', id: 'post_motif'})
      with_tag('input', with:{ type: 'submit', value: 'Valider le message'})
      with_tag('button', text: 'Refuser le message')
    end
    success 'l’administrateur trouve un formulaire de validation valide'

    within('form#post_validate_form') do
      fill_in('post_motif', with: "Votre message a malheureusement été refusé.\n\nLes raisons en sont les suivantes.\n")
      scrollTo('form#post_validate_form div.buttons')
      click_button 'Refuser le message'
    end
    success 'l’administrateur refuse le message en rédigeant un motif de refus'
    # sleep 10
    # ============ VÉRIFICATION ============
    expect(page).to have_tag('div.notice', text: /Le message est refusé/)
    hpost = site.db.select(:forum,'posts',{id: post_id}).first
    expect(hpost[:options][0..2]).to eq '001'
    expect(hpost[:valided_by]).to eq nil
    success 'le message existe toujours mais n’est pas validé et possède la marque de refus'

    visit "#{base_url}/forum/sujet/#{hpost[:sujet_id]}?pid=#{hpost[:id]}"
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset.post_list') do
      without_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"})
    end
    success 'on ne trouve pas le message dans le fil du sujet'

    auteur = User.get(hpost[:user_id])
    expect(auteur).to have_mail({
      sent_after: start_time,
      subject: 'Votre message sur le forum a été refusé',
      message: [
        'a malheureusement été refusé pour le motif suivant',
        'Vous avez la possibilité de le modifier',
        "forum/post/#{hpost[:id]}?op=m"
      ]
    })
    success 'l’auteur du message reçoit une notification de refus de son message'

    original_post_id = hpost[:parent_id]
    auteur_original_id = site.db.select(:forum,'posts',{id: original_post_id}).first[:user_id]
    auteur_original = User.get(auteur_original_id)
    expect(auteur_original).not_to have_mail({
      sent_after: start_time,
      subject: "Votre message a reçu une réponse sur le forum"
      })
    success 'l’auteur du message dont le message est la réponse n’est averti de rien'
  end
  #/Fin du scénario de validation du mail par un administrateur









  scenario '=> l’auteur du message peut venir rectifier son message' do
    start_time = Time.now.to_i

    # Les données de l'auteur du message
    happrenti = site.db.select(:hot,'users',{pseudo: 'Apprenti Surveillé'}).first
    happrenti.merge!(password: 'apprenti')

    # Note : ce scénario suit le précédent, il se sert du mail envoyé à
    # l'auteur (apprenti surveillé) pour relever le lien
    mails_validation = Array.new
    Dir["./xtmp/mails/*.msh"].reverse.each do |mpath|
      mdata = Marshal.load(File.read(mpath))
      if mdata[:to] == happrenti[:mail]
        if mdata[:subject] =~ /Votre message sur le forum a été refusé/
          mails_validation << mdata
        end
      end
    end
    # Parmi la liste des messages de validation, on prend le message qui a été
    # refusé
    post_id         = nil
    url_validation  = nil
    mails_validation.each do |mdata|
      pid = mdata[:message].match(/forum\/post\/([0-9]+)\?op=m/).to_a[1].to_i
      opts = site.db.select(:forum,'posts',{id: pid},[:options]).first[:options]
      if opts[0..2] == '001' # => non validé
        post_id = pid
        url_validation = mdata[:message].match(/forum\/post\/([0-9]+)\?op=m/).to_a[0]
        break
      end
    end

    if post_id.nil?
      raise "Impossible de procéder à ce test, aucun message n'est à valider. Lancer le test de toute la feuille pour procéder à ce scénario."
    else
      # puts "Message à valider : #{post_id}"
      # puts "URL de validation : #{url_validation}"
      hpost = site.db.select(:forum,'posts',{id: post_id}).first
      old_content = site.db.select(:forum,'posts_content',{id: post_id},[:content]).first[:content]
      hpost.merge!(content: old_content)
    end

    # L'auteur essaie de se rendre directement à l'adresse de validation, mais
    # il est redirigé vers la page d'identification
    visit "#{base_url}/#{url_validation}"
    # sleep 30
    expect(page).not_to have_tag('h2', text: 'Forum - édition de message')
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form')do
      fill_in('user_mail', with: happrenti[:mail])
      fill_in('user_password', with: happrenti[:password])
      click_button 'OK'
    end
    expect(page).to have_tag('h2', text: 'Forum - édition de message')
    success 'après avoir été redirigé vers l’identification, l’auteur rejoint l’édition de son message'

    edited_content = page.execute_script("return document.getElementById('post_content').value;")
    edited_content = edited_content.gsub(/\[.*?\]/,'').gsub(/<.*?>/,'')
    checked_old_content = old_content.gsub(/\[.*?\]/,'').gsub(/<.*?>/,'')

    expect(page).to have_tag('form#post_edit_form') do
      with_tag('textarea', with:{id: "post_content", name:'post[content]'})
    end
    expect(edited_content).to eq checked_old_content

    new_content = "Le nouveau contenu après #{start_time}."
    within('form#post_edit_form') do
      fill_in('post_content', with: new_content)
      click_button 'Modifier'
    end
    success 'Il trouve un formulaire pour modifier son message et le modifie'

    # sleep 4

    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('div.notice', text: /Une nouvelle demande de validation a été envoyée/)
    success 'un message de confirmation est donné à l’auteur'

    hafter = site.db.select(:forum,'posts',{id: post_id}).first
    hcafter = site.db.select(:forum,'posts_content',{id: post_id},[:content,:updated_at]).first
    expect(hcafter[:content]).to eq "<p>#{new_content}</p>"
    expect(hcafter[:updated_at]).to be > start_time
    expect(hafter[:modified_by]).to eq happrenti[:id]
    success 'le nouveau contenu est enregistré et le modificateur aussi'

    [phil, marion].each do |admin|
      expect(admin).to have_mail({
        subject:    "Message forum modifié à valider",
        sent_after: start_time,
        message: ["forum/post/#{post_id}?op=v", 'Valider le message']
      })
    end
    success 'les administrateurs ont reçu la nouvelle demande de validation'
  end










  scenario '=> Un autre administrateur peut valider le message modifié' do
    start_time = Time.now.to_i

    # Note : ce scénario suit le précédent, il se sert du mail envoyé à
    # moi (phil@laboiteaoutilsdelauteur.fr) pour relever le lien
    mails_validation = Array.new
    Dir["./xtmp/mails/*.msh"].reverse.each do |mpath|
      mdata = Marshal.load(File.read(mpath))
      if mdata[:to] == marion.mail
        if mdata[:subject] =~ /Message forum modifié à valider/
          mails_validation << mdata
        end
      end
    end

    # Parmi la liste des messages de validation, on prend le message qui n'est
    # pas encore validé
    post_id         = nil
    url_validation  = nil
    mails_validation.each do |mdata|
      pid = mdata[:message].match(/forum\/post\/([0-9]+)\?op=v/).to_a[1].to_i
      opts = site.db.select(:forum,'posts',{id: pid},[:options]).first[:options]
      if opts[0..2] == '001' # => non validé, non détruit, mais refusé
        post_id = pid
        url_validation = mdata[:message].match(/forum\/post\/([0-9]+)\?op=v/).to_a[0]
        break
      end
    end

    if post_id.nil?
      raise "Impossible de procéder à ce test, aucun message refusé et modifié n'est à valider. Lancer le test de toute la feuille pour procéder à ce scénario."
    else
      # puts "Message à valider : #{post_id}"
      # puts "URL de validation : #{url_validation}"
      hpost = site.db.select(:forum,'posts',{id: post_id}).first
      hpost.merge!(
        content: site.db.select(:forum,'posts_content',{id: post_id},[:content]).first[:content]
      )
    end

    hauteur = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    count_initial = hauteur ? hauteur[:count] : 0

    # Marion essaie de se rendre directement à l'adresse de validation
    visit "#{base_url}/#{url_validation}"
    # sleep 30
    expect(page).not_to have_tag('h2', text: 'Forum - validation de message')
    expect(page).to have_tag('div.notice', text: /vous devez être identifié/)
    expect(page).to have_tag('form#signin_form')
    within('form#signin_form') do
      fill_in('user_mail',      with: data_marion[:mail])
      fill_in('user_password',  with: data_marion[:password])
      click_button 'OK'
    end
    # sleep 15
    expect(page).to have_tag('h2', text: 'Forum - validation de message')
    success 'l’administrateur a été redirigé vers la page de validation après son identification'

    expect(page).to have_tag('form', with: {id: 'post_validate_form'}) do
      extrait = hpost[:content].gsub(/\[(.*?)\]/, '').gsub(/<.*?>/,'')[0..50]
      with_tag('div', with: {id: 'post_content'}, text: /#{extrait}/)
      with_tag('input', with: {type: 'hidden', name:'op', value: 'validate'})
      with_tag('textarea', with: {name: 'post[motif]', id: 'post_motif'})
      with_tag('input', with:{ type: 'submit', value: 'Valider le message'})
      with_tag('button', text: 'Refuser le message')
    end
    success 'l’administrateur trouve un formulaire de validation valide'

    within('form#post_validate_form') do
      click_button 'Valider le message'
    end
    success 'l’administrateur peut valider le message'

    # ============ VÉRIFICATION ============
    expect(page).to have_tag('div.notice', text: /Le message est validé/)
    hpost = site.db.select(:forum,'posts',{id: post_id}).first
    expect(hpost[:options][0..2]).to eq '100'
    expect(hpost[:valided_by]).to eq marion.id
    success 'le message est validé avec les bonnes données (options, validateur)'

    happ = site.db.select(:forum,'users',{id: hpost[:user_id]}).first
    expect(happ[:count]).to eq count_initial + 1
    success 'le nombre de messages de l’auteur a été incrémenté'
    expect(happ[:last_post_id]).to eq hpost[:id]
    success 'l’ID du dernier message de l’auteur a été modifié'
    hsuj = site.db.select(:forum,'sujets',{id: hpost[:sujet_id]}).first
    expect(hsuj[:last_post_id]).to eq hpost[:id]
    success 'l’ID du dernier message du sujet a été modifié'

    visit "#{base_url}/forum/sujet/#{hpost[:sujet_id]}?pid=#{hpost[:id]}"
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"})
    end
    success 'on trouve le message dans le fil du sujet'

    auteur = User.get(hpost[:user_id])
    expect(auteur).to have_mail({
      sent_after: start_time,
      subject: 'Validation de votre message sur le forum'
    })
    success 'l’auteur du message reçoit une notification de la validation de son message'

    original_post_id = hpost[:parent_id]
    auteur_original_id = site.db.select(:forum,'posts',{id: original_post_id}).first[:user_id]
    auteur_original = User.get(auteur_original_id)
    expect(auteur_original).to have_mail({
      sent_after: start_time,
      subject: "Votre message a reçu une réponse sur le forum"
      })
    success 'l’auteur du message dont le message est la réponse est averti de la réponse'
  end
end
