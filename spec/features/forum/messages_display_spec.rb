require_support_integration
require_support_db_for_test
require_support_forum

# Mettre à true pour créer des données toutes fraiche dans
# la base de données. Mais ensuite, mettre à false pour ne pas
# le faire chaque fois qu'on lance le test.
PREMIERE_FOIS_MESS_DISP_SPEC = false

feature "Affichage des messages" do
  before(:all) do
    if PREMIERE_FOIS_MESS_DISP_SPEC
      puts "JE RECRÉE TOUTES LES DONNÉES FORUM"
      # Effacement de toutes les tables
      forum_truncate_all_tables
      truncate_table_users
      @drene = create_new_user(pseudo: 'René', sexe: 'H', password: 'motdepasserene', mail_confirmed: true)
      @rene = User.get(@drene[:id])
      @dlise = create_new_user(pseudo: 'Lise', sexe: 'F', password: 'motdepasselise', mail_confirmed: true)
      @lise = User.get(@dlise[:id])
      @dbenoit = create_new_user(pseudo: 'Benoit', sexe: 'H', password: 'motdepassebenoit', mail_confirmed: true)
      @benoit = User.get(@dbenoit[:id])
      @dmaude = create_new_user(pseudo: 'Maude', sexe: 'F', password: 'motdepassemaude', mail_confirmed: true)
      @maude  = User.get(@dmaude[:id])
      # Création de 50 sujets
      forum_create_sujets 50, {validate: true, auteurs: [1,2,3, @lise.id, @rene.id, @benoit.id, @maude.id]}
      # Pour chaque sujet, on va créer de 10 à 100 messages
      # La table @nombre_posts_by_sujet contiendra en clé l'ID du sujet et
      # en valeur son nombre de messages
      params = {
        validate:   true,
        votes:      true,
        authors:    [@rene.id, @lise.id, @benoit.id, @maude.id, 1, 2, 3],
        moderators: [1, 3]
      }
      @nombre_posts_by_sujet = Hash.new
      @all_sujets = all_sujets_forum.shuffle # mélangé (pour public)

      liste_hsujets_non_publics = Array.new

      @all_sujets.each do |hsujet|
        nombre_messages = rand(10..100)
        forum_create_posts( hsujet[:id], nombre_messages, params )
        @nombre_posts_by_sujet.merge!(hsujet[:id] => nombre_messages)
        if liste_hsujets_non_publics.count < 20
          liste_hsujets_non_publics << hsujet
        end
      end
      puts "@nombre_posts_by_sujet = #{@nombre_posts_by_sujet.inspect}"

      liste_hsujets_non_publics.each do |hs|
        s = hs[:specs]
        s[5] = '4'
        site.db.update(:forum,'sujets',{specs: s},{id: hs[:id]})
      end

      # On reprend les sujets car les specs ont été modifiés pour les
      # sujets non publics et en plus on les a shufflé.
      @all_sujets = all_sujets_forum
    else

      # Si ce n'est pas la première fois
      @drene    = site.db.select(:hot,'users',{pseudo: 'René'}).first.merge(password: 'motdepasserene')
      @dmaude   = site.db.select(:hot,'users',{pseudo: 'Maude'}).first.merge(password: 'motdepassemaude')
      @dbenoit  = site.db.select(:hot,'users',{pseudo: 'Benoit'}).first.merge(password: 'motdepassebenoit')
      @dlise  = site.db.select(:hot,'users',{pseudo: 'Lise'}).first.merge(password: 'motdepasselise')
      @all_sujets = all_sujets_forum
    end
  end

  context 'pour un visiteur quelconque' do
    scenario '=> l’accueil du forum affiche les tout derniers messages TOUT PUBLIC (20)' do
      # On récupère les 20 derniers sujets publics
      sujets_publics = @all_sujets.reject{|hs| hs[:specs][5] != '0'}
      sujets_publics = sujets_publics.sort_by{|hs| - hs[:updated_at]}

      visit forum_page
      expect(page).to have_tag('h2', text: 'Forum d’écriture')

      expect(page).to have_tag('fieldset', with: {id: 'last_public_messages'}) do
        # On doit trouver les 20 plus récents sur la page
        sujets_publics[0..19].each do |hsujet|
          sid = hsujet[:id]
          hpost = forum_get_post(hsujet[:last_post_id])
          # puts "hpost : #{hpost.inspect}"
          # puts "#{hsujet[:created_at]} | #{hsujet[:id]} | #{hsujet[:titre]}"
          with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
            with_tag('span', with: {class: 'titre', id: "sujet-#{sid}-titre"}, text: hsujet[:titre])
            with_tag('span', with: {class: 'type_s'})
            with_tag('span', with: {class: 'sujet_creator', 'data-id' => hsujet[:creator_id]}, text: hsujet[:creator_pseudo])
            with_tag('span', with: {class: 'sujet_date'}, text: hsujet[:created_at].as_human_date)
            with_tag('span', with: {class: 'post_auteur', 'data-id' => hpost[:auteur_id]}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'post_date'}, text: hpost[:created_at].as_human_date)
            with_tag('span', with: {class: 'posts_count'}, text: hsujet[:count])
          end
        end
      end
      success 'il trouve une liste des sujets correcte'

      expect(page).to have_tag('div', class: 'forum_boutons.top') do
        with_tag('a', with:{ href: "forum/home?from=20&nombre=20"}, text: 'Suivants')
        without_tag('a', text: 'Précédents')
      end
      within('div.forum_boutons.top'){click_link 'Suivants'}
      success 'il trouve des boutons pour aller aux sujets suivants et clique dessus'

      expect(page).to have_tag('h2', text: 'Forum d’écriture')
      expect(page).to have_tag('div', class: 'forum_boutons.top') do
        with_tag('a', with:{ href: "forum/home?from=40&nombre=20"}, text: 'Suivants')
        with_tag('a', with:{ href: "forum/home?from=0&nombre=20"}, text: 'Précédents')
      end
      success 'il trouve des boutons pour aller aux sujets précédents et suivants'
    end #/scénario
  end #/context (un visiteur quelconque)

  context 'pour un visiteur juste identifié' do
    scenario '=> l’accueil du forum affiche les tout derniers messages (20)' do

      # On récupère tous les sujets
      # Noter qu'ils sont déjà classés dans l'ordre des updated_at
      sujets = all_sujets_forum(0, nil, {grade: 1})

      # sujets[0..19].each do |hsujet|
      #   puts "Sujet #{hsujet[:id].to_s.rjust(3,' ')} : #{hsujet[:updated_at]}"
      # end

      identify @dmaude
      within('section#header') do
        expect(page).to have_link('se déconnecter')
      end
      visit forum_page
      expect(page).to have_tag('h2', text: 'Forum d’écriture')

      expect(page).to have_tag('fieldset', with: {id: 'last_messages'}) do
        # On doit trouver les 20 plus récents sur la page
        sujets[0..19].each do |hsujet|
          sid = hsujet[:id]
          # puts "- SUJET #{sid}"
          hpost = forum_get_post(hsujet[:last_post_id])
          # puts "hpost : #{hpost.inspect}"
          # puts "#{hsujet[:created_at]} | #{hsujet[:id]} | #{hsujet[:titre]}"
          with_tag('div', with: {class: 'sujet', id: "sujet-#{sid}"}) do
            with_tag('span', with: {class: 'titre', id: "sujet-#{sid}-titre"}) do
              with_tag('a', with: {href: "forum/sujet/#{sid}?from=-1"}, text: hsujet[:titre])
            end
            with_tag('span', with: {class: 'type_s'})
            with_tag('span', with: {class: 'sujet_creator', 'data-id' => hsujet[:creator_id]}, text: hsujet[:creator_pseudo])
            with_tag('span', with: {class: 'sujet_date'}, text: hsujet[:created_at].as_human_date)
            with_tag('span', with: {class: 'post_auteur', 'data-id' => hpost[:auteur_id]}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'post_date'}, text: hpost[:created_at].as_human_date)
            with_tag('span', with: {class: 'posts_count'}, text: hsujet[:count])
          end
        end
      end
      success 'il trouve une liste des sujets correcte'

      expect(page).to have_tag('div', class: 'forum_boutons.top') do
        with_tag('a', with:{ href: "forum/home?from=20&nombre=20"}, text: 'Suivants')
        without_tag('a', text: 'Précédents')
      end
      within('div.forum_boutons.top'){click_link 'Suivants'}
      success 'il trouve des boutons pour aller aux sujets suivants et clique dessus'

      expect(page).to have_tag('h2', text: 'Forum d’écriture')
      expect(page).to have_tag('div', class: 'forum_boutons.top') do
        with_tag('a', with:{ href: "forum/home?from=40&nombre=20"}, text: 'Suivants')
        with_tag('a', with:{ href: "forum/home?from=0&nombre=20"}, text: 'Précédents')
      end
      success 'il trouve des boutons pour aller aux sujets précédents et suivants'

    end
  end

  scenario '=> un sujet quelconque affiche tous ses messages' do

    hsujet_un = all_sujets_forum(0,1,{grade: 0}).first

    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    expect(page).to have_tag('fieldset', with:{ id: 'last_public_messages'})
    within('fieldset#last_public_messages') do
      page.find("div#sujet-#{hsujet_un[:id]} span.titre a").click
    end

    sleep 60
    expect(page).to have_tag('h2', text: "Forum : sujet ##{hsujet_un[:id]}")
    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_un[:id]}"}) do
      # TODO La liste des derniers messages du sujet
    end
  end
end
