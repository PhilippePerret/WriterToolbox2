
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
  before(:all) do

    # On prend tous les messages d'un certain sujet
    sujets_ids = site.db.select(:forum,'sujets',nil,[:id]).collect{|h|h[:id]}
    # puts "IDs des sujets : #{sujets_ids.inspect}"
    @sujet_id = sujets_ids[rand(0..sujets_ids.count-1)]
    # puts "ID sujet choisi : #{@sujet_id}"
    posts_ids = site.db.select(:forum,'posts',{sujet_id: @sujet_id},[:id]).collect{|h|h[:id]}
    # puts "IDs des messages du sujet ##{@sujet_id} : #{posts_ids.inspect}"
    # On prend le message au milieu
    nombre_posts = posts_ids.count
    @post_id = posts_ids[nombre_posts/2]
    # puts "ID du message choisi : #{@post_id}"
  end
  scenario "L'url `forum/sujet/<id sujet>?pid=<id post>` permet d'afficher un message particulier" do

    # On visite l'URL voulue
    url = "forum/sujet/#{@sujet_id}?pid=#{@post_id}"
    visit "#{base_url}/#{url}"

    expect(page).to have_tag('h2', text: /Forum/)
    expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
      with_tag('div', with: {class: 'post', id: "post-#{@post_id}"})
      success "Le listing contient le message voulu"
    end

    divs = page.all('fieldset.post_list > div.post')
    last_div_post = divs.last
    expect(last_div_post[:id]).to eq "post-#{@post_id}"
    success 'le div voulu est bien le dernier de la liste'

    expect(page).to have_tag('a', text: 'Messages suivants', match: :first)

    pending "Des boutons permettent de voir les messages suivants"
    pending "des boutons permettent de revenir au message voulu"

    expect(page).to have_tag('a', text: 'Messages précédents', match: :first)
    pending "des boutons permettent de voir les messages précédents"

  end
end
