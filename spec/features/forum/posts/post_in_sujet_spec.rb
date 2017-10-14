
require_lib_site
require_support_integration

=begin

  Ce test teste l'affichage d'un message par l'adresse :

      forum/sujet/<id sujet>?pid=<id post>

  C'est un affichage particulier du message puisqu'on prend juste
  le panneau qui contient ce post.
  Cette opération est obtenue grâce à une requête SQL imbriquée (on prend
  les messages dont la date de création est juste antérieure à celle du
  message spécifié dans l'url)

=end
feature "Affichage d'un message particulier" do

  def get_a_post_id_in_a_sujet
    # puts "-> get_a_post_id_in_a_sujet"
    # On prend tous les messages d'un certain sujet
    @sujets_ids ||= site.db.select(:forum,'sujets',nil,[:id]).collect{|h|h[:id]}
    # puts "IDs des sujets : #{@sujets_ids.inspect}"
    @sujet_id = @sujets_ids.shift
    # puts "@sujet_id = #{@sujet_id.inspect}"

    # Il faut un sujet qui contienne au moins 60 messages
    nombre_posts = site.db.count(:forum,'posts',{sujet_id: @sujet_id})
    nombre_posts > 60 || get_a_post_id_in_a_sujet
    # puts "Nombre de posts : #{nombre_posts}"

    # # puts "ID sujet choisi : #{@sujet_id}"
    where = "sujet_id = #{@sujet_id} ORDER BY created_at ASC"
    @posts_ids = site.db.select(:forum,'posts',where,[:id, :created_at]).collect{|h|h[:id]}
    # puts "IDs des messages du sujet ##{@sujet_id} : #{@posts_ids.inspect}"
    # # On prend le message au milieu
    nombre_posts = @posts_ids.count
    @post_id = @posts_ids[nombre_posts/2]
    # puts "ID du message choisi : #{@post_id}"
    # puts "<- get_a_post_id_in_a_sujet"
  end




  scenario "=> L'url `forum/sujet/<id sujet>?pid=<id post>` permet d'afficher un message particulier et de passer aux messages suivants" do

    # On essaie 5 fois, parce que ça foire une fois sur deux…
    begin
      get_a_post_id_in_a_sujet

      # On visite l'URL voulue
      url = "forum/sujet/#{@sujet_id}?pid=#{@post_id}"
      # puts "url = #{url}"
      visit "#{base_url}/#{url}"

      expect(page).to have_tag('h2', text: /Forum/)
      if page.all("fieldset.post_list div#post-#{@post_id}").count == 0
        raise 'Essayer encore'
      end
    rescue Exception => e
      while @post_id != nil
        sleep 0.5
        retry
      end
    end
    expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
      with_tag('div', with: {class: 'post', id: "post-#{@post_id}"})
      success "Le listing contient le message voulu"
    end

    divs = page.all('fieldset.post_list > div.post')
    first_div_post = divs.first
    expect(first_div_post[:id]).to eq "post-#{@post_id}"
    success 'le div voulu est bien le premier de la liste'

    expect(page).to have_tag('a', text: /messages suivants/, match: :first)
    expect(page).to have_tag('a', text: /messages précédents/, match: :first)
    expect(page).to have_tag('a', text: /derniers messages/, match: :first)
    expect(page).to have_tag('a', text: /premiers messages/, match: :first)
    success 'des boutons permettent de voir les messages suivant, précédents et derniers'

    click_link('messages suivants →', match: :first)
    index_post_id = @posts_ids.index(@post_id)
    next_post_id = @posts_ids[index_post_id + 20]
    next2_post_id = @posts_ids[index_post_id + 21]
    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{next_post_id}"})
      with_tag('div', with: {class: 'post', id: "post-#{next2_post_id}"})
    end
    success 'elle peut passer aux messages suivants avec le bouton « messages suivants »'

    click_link('⇤ premiers messages', match: :first)
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{@posts_ids[0]}"})
      with_tag('div', with: {class: 'post', id: "post-#{@posts_ids[19]}"})
    end
    success 'elle peut revenir aux premiers messages avec le bouton « premiers messages »'

    click_link('derniers messages ⇥', match: :first)
    expect(page).to have_tag('fieldset.post_list') do
      with_tag('div', with: {class: 'post', id: "post-#{@posts_ids[-1]}"})
      with_tag('div', with: {class: 'post', id: "post-#{@posts_ids[-18]}"})
    end
    success 'elle peut aller aux derniers messages avec le bouton « derniers messages »'
  end
end
