=begin

  Test de la modification de message

=end

require_lib_site
require_support_integration
require_support_forum
require_support_db_for_test
require_support_mails_for_test

feature 'Modification de message' do
  context 'avec un auteur de grade qui nécessite la validation' do

    scenario '=> l’auteur du message peut modifier son message' do

      start_time = Time.now.to_i

      # On trouve un message par un auteur de grade donné
      request = <<-SQL
      SELECT u.id, u.mail
        FROM posts p
        INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
        WHERE CAST(SUBSTRING(u.options,2,1) AS UNSIGNED) < 4
          AND SUBSTRING(p.options,1,1) = '1'
      SQL
      site.db.use_database(:forum)
      uid = site.db.execute(request).first[:id]
      pwd = User.get(uid).var['password']
      hauteur = db_get_user_by_id(uid)
      hauteur.merge!(password: pwd)
      pseudo = hauteur[:pseudo]
      # puts "hauteur : #{hauteur.inspect}"

      # On prend un message de l'auteur au hasard
      hpost = forum_get_random_post(user_id: hauteur[:id])
      # puts "hpost: #{hpost.inspect}"
      post_id   = hpost[:id]
      sujet_id  = hpost[:sujet_id]
      notice "Données pour test de modification de message :"
      notice "ID Post   : #{post_id}"
      notice "ID Sujet  : #{sujet_id}"
      notice "ID Auteur : #{hauteur[:id]} (#{pseudo})"

      # On se rend au message
      identify hauteur
      visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{post_id}"

      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_selector('fieldset.post_list') do
        with_tag('div', with: {class: 'post', id: "post-#{post_id}"}) do
          with_tag('div', with: {class: 'post_footer'}) do
            with_tag('a', with: {href: "forum/post/#{post_id}?op=m"})
          end
        end
      end
      success "#{pseudo} trouve un de ses messages, avec un bouton pour le modifier"

      # L'auteur met le message en édition
      scrollTo("div#post-#{post_id} div.post_footer", -100)
      within("div#post-#{post_id} div.post_footer"){click_link 'Modifier'}

      expect(page).to have_tag('h2', text: 'Forum - édition de message')
      expect(page).to have_tag('form#post_edit_form') do
        with_tag('textarea', with: {name: 'post[content]', id: 'post_content'})
        with_tag('div.buttons') do
          with_tag('input', with: {type: 'submit', value: 'Modifier'})
          with_tag('a', with:{href: "forum/sujet/#{sujet_id}?pid=#{post_id}"}, text: 'Revenir au sujet')
        end
      end
      success "en cliquant sur le bouton « Modifier », #{pseudo} se retrouve sur le formulaire d'édition."

      texte = page.execute_script("return document.querySelector('textarea#post_content').value")
      # puts "texte : #{texte}"

      expect(texte).not_to include '<p>'
      expect(texte).not_to include '</p>'
      expect(texte).not_to match /<.*?>/
      success 'le texte du message a été correctement modifié (aucune balise HTML)'

      # ================> TEST <===============

      new_content = "Nouveau contenu du message modifié le #{Time.now.to_i}."
      within("form#post_edit_form") do
        fill_in('post_content', with: new_content)
        click_button 'Modifier'
      end
      success "#{pseudo} modifie le texte et le soumet"

      # sleep 4

      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('fieldset.post_list') do
        with_tag('div', with: {class: 'post', id: "post-#{post_id}"}) do
          with_tag('p', text: /#{Regexp.escape new_content}/)
        end
      end
      success "#{pseudo} revient sur la liste du sujet et trouve son message modifié"

      hcontent = site.db.select(:forum,'posts_content',{id: post_id}).first
      expect(hcontent[:content]).to eq "<p>#{new_content}</p>"
      expect(hcontent[:updated_at]).to be > start_time
      expect(hcontent[:modified_by]).to eq hauteur[:id]
      success 'les données DB pour le contenu du post sont valides'

      newhpost = site.db.select(:forum,'posts',{id: post_id}).first
      expect(newhpost[:options][0]).to eq '1'
      expect(newhpost[:options][3]).to eq '1'
      success 'le message est marqué à REvalider (4e bit à 1)'

      data_mail = {
        sent_after: start_time,
        subject:    'Message forum modifié à valider',
        message: ["forum/post/#{post_id}?op=v"]
        }
      expect(phil).to have_mail(data_mail)
      expect(marion).to have_mail(data_mail)
      success 'les administrateurs ont reçu un mail pour valider le nouveau message'

    end









    scenario '=> si l’auteur du message re-modifie son message, pas de nouvelle alerte admin' do

      start_time = Time.now.to_i

      # On trouve un message par un auteur de grade donné
      request = <<-SQL
      SELECT u.id
        FROM posts p
        INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
        WHERE CAST(SUBSTRING(u.options,2,1) AS UNSIGNED) < 4
          AND SUBSTRING(p.options,1,1) = '1'
        LIMIT 20
      SQL
      site.db.use_database(:forum)
      uid = site.db.execute(request).shuffle.shuffle.first[:id]
      pwd = User.get(uid).var['password']
      hauteur = db_get_user_by_id(uid)
      hauteur.merge!(password: pwd)
      pseudo = hauteur[:pseudo]
      # puts "hauteur : #{hauteur.inspect}"

      # On prend un message de l'auteur au hasard
      hpost = forum_get_random_post(user_id: hauteur[:id])
      # puts "hpost: #{hpost.inspect}"
      post_id   = hpost[:id]
      sujet_id  = hpost[:sujet_id]
      notice "Données pour test de modification de message :"
      notice "ID Post   : #{post_id}"
      notice "ID Sujet  : #{sujet_id}"
      notice "ID Auteur : #{hauteur[:id]} (#{pseudo})"

      # On se rend au message
      identify hauteur
      visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{post_id}"

      # L'auteur met le message en édition
      scrollTo("div#post-#{post_id} div.post_footer")
      within("div#post-#{post_id} div.post_footer"){click_link 'Modifier'}

      new_content = "Contenu du message modifié une première fois le #{Time.now.to_i}."
      within("form#post_edit_form") do
        fill_in('post_content', with: new_content)
        click_button 'Modifier'
      end
      success "#{pseudo} modifie le texte une première fois et le soumet"

      # sleep 4

      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('fieldset.post_list') do
        with_tag('div', with: {class: 'post', id: "post-#{post_id}"}) do
          with_tag('p', text: /#{Regexp.escape new_content}/)
        end
      end
      success "#{pseudo} revient sur la liste du sujet et trouve son message modifié"

      hcontent = site.db.select(:forum,'posts_content',{id: post_id}).first
      expect(hcontent[:content]).to eq "<p>#{new_content}</p>"
      expect(hcontent[:updated_at]).to be > start_time
      expect(hcontent[:modified_by]).to eq hauteur[:id]
      success 'les données DB pour le contenu du post sont valides'

      newhpost = site.db.select(:forum,'posts',{id: post_id}).first
      expect(newhpost[:options][0]).to eq '1'
      expect(newhpost[:options][3]).to eq '1'
      success 'le message est marqué à RE-valider (4e bit à 1)'

      data_mail = {
        sent_after: start_time,
        subject:    'Message forum modifié à valider',
        message: ["forum/post/#{post_id}?op=v"]
        }
      expect(phil).to have_mail(data_mail)
      expect(marion).to have_mail(data_mail)
      success 'les administrateurs ont reçu un mail pour valider le nouveau message'

      # ---------------------------------------------------------------------
      #
      #   DEUXIÈME MODIFICATION
      #
      # ---------------------------------------------------------------------
      start_time_twice = Time.now.to_i

      # L'auteur remet le message en édition
      scrollTo("div#post-#{post_id} div.post_footer")
      within("div#post-#{post_id} div.post_footer"){click_link 'Modifier'}

      new_content_twice = "Contenu du message modifié une deuxième fois le #{Time.now.to_i}."
      within("form#post_edit_form") do
        fill_in('post_content', with: new_content_twice)
        click_button 'Modifier'
      end
      success "#{pseudo} modifie le texte une seconde fois et le soumet"

      # sleep 4

      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('fieldset.post_list') do
        with_tag('div', with: {class: 'post', id: "post-#{post_id}"}) do
          with_tag('p', text: /#{Regexp.escape new_content_twice}/)
        end
      end
      success "#{pseudo} revient sur la liste du sujet et trouve son message encore modifié"

      hcontent = site.db.select(:forum,'posts_content',{id: post_id}).first
      expect(hcontent[:content]).to eq "<p>#{new_content_twice}</p>"
      expect(hcontent[:updated_at]).to be > start_time_twice
      expect(hcontent[:modified_by]).to eq hauteur[:id]
      success 'les données DB pour le contenu du post sont valides (notamment updated_at)'

      newhpost = site.db.select(:forum,'posts',{id: post_id}).first
      expect(newhpost[:options][0]).to eq '1'
      expect(newhpost[:options][3]).to eq '1'
      success 'le message est toujours marqué valide et à RE-valider (4e bit à 1)'

      expect(phil).not_to have_mail({sent_after: start_time_twice})
      expect(marion).not_to have_mail({sent_after: start_time_twice})
      success 'les administrateurs ne reçoivent pas de nouvelle alerte'
    end
    #/scénario pour une double modification

  end
  #/context auteur grade nécessitant validation










  context 'avec un auteur de grade ne nécessitant pas la validation' do

    scenario '=> l’auteur du message peut modifier son message qui sera aussitôt validé' do

      start_time = Time.now.to_i

      # On trouve un message par un auteur de grade donné
      request = <<-SQL
      SELECT u.id, u.mail
        FROM posts p
        INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
        WHERE CAST(SUBSTRING(u.options,2,1) AS UNSIGNED) > 3
          AND SUBSTRING(p.options,1,1) = '1'
          AND u.id > 49
      SQL
      site.db.use_database(:forum)
      uid = site.db.execute(request).first[:id]
      pwd = User.get(uid).var['password']
      hauteur = db_get_user_by_id(uid)
      hauteur.merge!(password: pwd)
      pseudo = hauteur[:pseudo]
      # puts "hauteur : #{hauteur.inspect}"

      # On prend un message de l'auteur au hasard
      hpost = forum_get_random_post(user_id: hauteur[:id])
      # puts "hpost: #{hpost.inspect}"
      post_id   = hpost[:id]
      sujet_id  = hpost[:sujet_id]
      notice "Données pour test de modification de message :"
      notice "ID Post   : #{post_id}"
      notice "ID Sujet  : #{sujet_id}"
      notice "ID Auteur : #{hauteur[:id]} (#{pseudo})"

      # On se rend au message
      identify hauteur
      visit "#{base_url}/forum/sujet/#{sujet_id}?pid=#{post_id}"

      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_selector('fieldset.post_list') do
        with_tag('div', with: {class: 'post', id: "post-#{post_id}"}) do
          with_tag('div', with: {class: 'post_footer'}) do
            with_tag('a', with: {href: "forum/post/#{post_id}?op=m"})
          end
        end
      end
      success "#{pseudo} trouve un de ses messages, avec un bouton pour le modifier"

      # L'auteur met le message en édition
      scrollTo("div#post-#{post_id} div.post_footer", -100)
      within("div#post-#{post_id} div.post_footer"){click_link 'Modifier'}

      expect(page).to have_tag('h2', text: 'Forum - édition de message')
      expect(page).to have_tag('form#post_edit_form') do
        with_tag('textarea', with: {name: 'post[content]', id: 'post_content'})
        with_tag('div.buttons') do
          with_tag('input', with: {type: 'submit', value: 'Modifier'})
          with_tag('a', with:{href: "forum/sujet/#{sujet_id}?pid=#{post_id}"}, text: 'Revenir au sujet')
        end
      end
      success "en cliquant sur le bouton « Modifier », #{pseudo} se retrouve sur le formulaire d'édition."

      texte = page.execute_script("return document.querySelector('textarea#post_content').value")
      # puts "texte : #{texte}"

      expect(texte).not_to include '<p>'
      expect(texte).not_to include '</p>'
      expect(texte).not_to match /<.*?>/
      success 'le texte du message a été correctement modifié (aucune balise HTML)'

      # ================> TEST <===============

      new_content = "Nouveau contenu du message modifié le #{Time.now.to_i}."
      within("form#post_edit_form") do
        fill_in('post_content', with: new_content)
        click_button 'Modifier'
      end
      success "#{pseudo} modifie le texte et le soumet"

      # sleep 4

      expect(page).to have_tag('h2', text: /Forum/)
      expect(page).to have_tag('fieldset.post_list') do
        with_tag('div', with: {class: 'post', id: "post-#{post_id}"}) do
          with_tag('p', text: /#{Regexp.escape new_content}/)
        end
      end
      success "#{pseudo} revient sur la liste du sujet et trouve son message modifié"

      hcontent = site.db.select(:forum,'posts_content',{id: post_id}).first
      expect(hcontent[:content]).to eq "<p>#{new_content}</p>"
      expect(hcontent[:updated_at]).to be > start_time
      expect(hcontent[:modified_by]).to eq hauteur[:id]
      success 'les données DB pour le contenu du post sont valides'

      newhpost = site.db.select(:forum,'posts',{id: post_id}).first
      expect(newhpost[:options][0]).to eq '1'
      expect(newhpost[:options][3]).to eq '0'
      success 'le message n’est pas marqué à valider ou revalidé (=> il est validé)'

      data_mail = {
        sent_after: start_time,
        subject:    'Message forum modifié à valider'
        }
      expect(phil).not_to have_mail(data_mail)
      success 'les administrateurs ne reçoivent pas de mail pour valider le nouveau message'

    end


  end
end
