require_support_integration
require_support_db_for_test
require_support_forum

# Mettre à true pour créer des données toutes fraiche dans
# la base de données. Mais ensuite, mettre à false pour ne pas
# le faire chaque fois qu'on lance le test.
PREMIERE_FOIS_MESS_DISP_SPEC = false


def get_user_by_pseudo pseudo
  res = site.db.select(:hot,'users',{pseudo: pseudo}).first
  if res.nil?
    reset_all_data_forum
    @all_sujets = all_sujets_forum
    return get_user_by_pseudo(pseudo)
  end
  return res
end
feature "Affichage des messages" do
  before(:all) do
    if PREMIERE_FOIS_MESS_DISP_SPEC
      reset_all_data_forum
      @all_sujets = all_sujets_forum
    else

      # Si ce n'est pas la première fois
      @drene                = get_user_by_pseudo('René').merge(password: 'motdepasserene')
      @dmaude               = get_user_by_pseudo('Maude').merge(password: 'motdepassemaude')
      @dbenoit              = get_user_by_pseudo('Benoit').merge(password: 'motdepassebenoit')
      @dlise                = get_user_by_pseudo('Lise').merge(password: 'motdepasselise')
      @dApprentiSurveilled  = get_user_by_pseudo('ApprentiSurveillé').merge(password:'motdepasse')
      @dSimpleRedactrice    = get_user_by_pseudo('SimpleRedactrice').merge(password:'simpleredactrice')
      @dRedacteur           = get_user_by_pseudo('Rédacteur').merge(password:'vrairedacteur')
      @dRedacteurEmerite    = get_user_by_pseudo('RédacteurEmérite').merge(password:'motdepasse')
      @dRedactriceConfirmee = get_user_by_pseudo('RédactriceConfirmée').merge(password:'motdepasse')
      @dMaitreRedacteur     = get_user_by_pseudo('MaitreRédacteur').merge(password:'motdepasse')
      @dExperteEcriture     = get_user_by_pseudo('ExperteEcriture').merge(password:'motdepasse')

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

  scenario '=> un VISITEUR QUELCONQUE trouve un listing de messages correct' do

    # On va vérifier l'affichage de tous les messages du premier sujet
    # qu'on trouve.

    hsujet_cur = all_sujets_forum(0,1,{grade: 0}).first

    sid = hsujet_cur[:id]

    # On récvupère tous ces messages en une seule fois
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    expect(page).to have_tag('fieldset', with:{ id: 'last_public_messages'})
    within('fieldset#last_public_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end
    success 'contient le bon titre'

    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
    end
    success 'contient les informations sur le sujet'

    success 'contient des liens pour… '
    expect(page).to have_tag('div.buttons.top') do
      # Il y a un lien pour suivre le sujet, mais qui renverra à un message indiquant
      # qu'il faut être inscrit pour pouvoir suivre un sujet
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      success '… suivre le sujet'
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts[0..19].each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
        expect(page).to have_tag('div', with: {class: 'entete_sujet'})
        expect(page).to have_tag('div.buttons.top') do
          # Le lien conduira à un message indiquant qu'il faut être inscrit
          with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
          without_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
        end
        expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"
            # Il n'y a pas de lien pour répondre au message
            without_tag('a', with: {href: "#{url}?op=answer"})
            # Il n'y a pas de ligne pour voter pour ou contre
            without_tag('a', with: {href: "#{url}?op=up"})
            without_tag('a', with: {href: "#{url}?op=down"})
            # Il n'y a pas de ligne pour détruire le message
            without_tag('a', with: {href: "#{url}?op=kill"})
            # Il n'y a pas de ligne pour signaler le message
            without_tag('a', with: {href: "#{url}?op=notify"})
          end
        end

      end
      #/Fin de boucle sur les 20 messages
      success 'contient un bon listing des 20 messages'

    end
  end
  #/Fin de scénario de listing de sujet pour un visiteur quelconque











  scenario '=> un APPRENTI SURVEILLÉ trouve un listing de messages conforme (il peut répondre)' do

    # On va vérifier l'affichage de tous les messages du premier sujet
    # qu'on trouve, avec des liens qui permettent de tout faire puisque
    # c'est un administrateur.

    huser_current = @dApprentiSurveilled
    user_current  = User.get(huser_current[:id])
    user_grade    = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # On vérifie le grade ici
    expect(user_grade).to eq 3

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère seulement quatre messages
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
      LIMIT 4
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify huser_current
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')

    # Il clique pour voir le sujet choisi
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    # Il arrive sur le listing des messages
    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end

    # Les liens pour souscrire au sujet ou non
    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
    end

    expect(page).to have_tag('div.buttons.top') do
      success 'contient des liens pour… '
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouvelle question")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouvelle question')
      success "… créer une nouvelle question"

      # Lien pour valider le sujet (grade 7) : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"})
      # Lien pour clore le sujet (grade 7) : NON
      without_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      # Lien pour détruire le sujet : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"})
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts.each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
          expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"

            # Lien pour répondre au message : OUI (si autre auteur)
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            # Lien pour valider : NON
            # if hpost[:auteur_id] != user_current.id
            #   with_tag('a', with: {href: "#{url}?op=v"})
            # else
              without_tag('a', with: {href: "#{url}?op=v"})
            # end

            # Liens pour voter pour ou contre : NON
            without_tag('a', with: {href: "#{url}?op=u"})
            without_tag('a', with: {href: "#{url}?op=d"})
            # Lien pour détruire le message : NON
            without_tag('a', with: {href: "#{url}?op=k"})
            # Lien pour signaler le message : OUI
            with_tag('a', with: {href: "#{url}?op=n"})
            # Lien pour modifier le message
            # Admin ou auteur du message
            can_modify = user_current.admin? || user_current.id == hpost[:auteur_id]
            if can_modify
              with_tag('a', with: {href: "#{url}?op=m"})
            else
              without_tag('a', with: {href: "#{url}?op=m"})
            end
          end
        end

      end
      #/Fin de boucle sur les 20 messages
      success 'contient listing valide (avec les bons boutons pour le grade donné)'

    end
  end
  #/Fin de scénario de listing de sujet pour un APPRENTI SURVEILLÉ (grade 3)










    scenario '=> une SIMPLE RÉDACTRICE trouve un listing de messages conforme (elle peut répondre)' do

      huser_current = @dSimpleRedactrice
      user_current  = User.get(huser_current[:id])
      user_grade    = user_current.data[:options][1].to_i
      notice "User courant : #{user_current.pseudo} (##{user_current.id})"
      notice "Grade de #{user_current.pseudo} : #{user_grade}"

      # On vérifie le grade ici
      expect(user_grade).to eq 4

      hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

      sid = hsujet_cur[:id]

      # On récupère seulement quatre messages
      request = <<-SQL
      SELECT p.*,
        uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
        uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
        p2.sujet_id AS auteur_last_post_sujet_id,
        p2.created_at AS auteur_last_post_date,
        u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
        c.content, v.upvotes, v.downvotes
        FROM posts p
        INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
        INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
        INNER JOIN posts_content c  ON p.id = c.id
        INNER JOIN posts_votes v    ON p.id = v.id
        INNER JOIN posts p2         ON uf.last_post_id = p2.id
        WHERE p.sujet_id = #{hsujet_cur[:id]}
        ORDER BY p.created_at DESC
        LIMIT 4
      SQL
      site.db.use_database(:forum)
      hposts = site.db.execute(request)


      identify huser_current
      visit forum_page
      expect(page).to have_tag('h2', text: 'Forum d’écriture')

      # Il clique pour voir le sujet choisi
      expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
      within('fieldset#last_messages') do
        page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
      end

      # Il arrive sur le listing des messages
      expect(page).to have_tag('h2') do
        with_tag('a', with: {href: "forum/home"}, text: 'Forum')
        with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
      end

      # Les liens pour souscrire au sujet ou non
      expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
        with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
        with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
        with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
      end

      expect(page).to have_tag('div.buttons.top') do
        success 'contient des liens pour… '
        # Liens pour souscrire au sujet ou contraire
        with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
        # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
        success '… suivre le sujet'

        # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouvelle question")
        with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouvelle question')
        success "… créer une nouvelle question"

        # Lien pour valider le sujet (grade 7) : NON
        without_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"})
        # Lien pour clore le sujet (grade 7) : NON
        without_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
        # Lien pour détruire le sujet : NON
        without_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"})
      end

      expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
        with_tag('legend', text: 'Liste des messages')

        # La liste des messages actuels
        # ------------------------------
        hposts.each do |hpost|
          # puts "POST #{hpost[:id]}"

          # Les votes pour le message
          upvotes   = hpost[:upvotes].as_id_list.count
          downvotes = hpost[:downvotes].as_id_list.count

          # Le DIV contenant tout le message
          with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

            # Le DIV de la carte de l'auteur du message
            with_tag('div', with: {class: 'user_card'}) do
              with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
              with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
              fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
              with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
              with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
              with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
              with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
              with_tag('span', with: {class: 'last_post'}) do
                with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
              end
            end

            # L'entête du message
            # Note : pour le moment, ne contient que la marque de vote, au-dessus
            # pour savoir tout de suite comment est coté le message.
            with_tag('div', with: {class: 'post_header'}) do
              with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
              with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
            end

            # Le contenu du message
            # Note : on vérifie seulement les x premiers caractères
            c = hpost[:content].gsub(/<(.*?)>/, '')
            c = c[0..50]
            with_tag('div', with: {class: 'content'}, text: /#{c}/)

            # Le pied de page du message
            # --------------------------
            # Avec le contenu, c'est lui le plus important puisqu'il permet de
            # plébisciter le message, de lui répondre, etc.
            with_tag('div', {class: 'post_footer'}) do
              with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
              with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
            end


          end #/dans le listing

          # ----------------------------------------
          # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
          # ----------------------------------------
            expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
            with_tag('div', {class: 'post_footer'}) do
              url = "forum/post/#{hpost[:id]}"

              # Lien pour répondre au message : OUI (si autre auteur)
              if hpost[:auteur_id] != user_current.id
                with_tag('a', with: {href: "#{url}?op=a"})
              else
                without_tag('a', with: {href: "#{url}?op=a"})
              end

              # Lien pour valider : NON
              # if hpost[:auteur_id] != user_current.id
              #   with_tag('a', with: {href: "#{url}?op=v"})
              # else
                without_tag('a', with: {href: "#{url}?op=v"})
              # end

              # Liens pour voter pour ou contre : NON
              without_tag('a', with: {href: "#{url}?op=u"})
              without_tag('a', with: {href: "#{url}?op=d"})
              # Lien pour détruire le message : NON
              without_tag('a', with: {href: "#{url}?op=k"})
              # Lien pour signaler le message : OUI
              with_tag('a', with: {href: "#{url}?op=n"})
              # Lien pour modifier le message
              # Admin ou auteur du message
              can_modify = user_current.admin? || user_current.id == hpost[:auteur_id]
              if can_modify
                with_tag('a', with: {href: "#{url}?op=m"})
              else
                without_tag('a', with: {href: "#{url}?op=m"})
              end
            end
          end

        end
        #/Fin de boucle sur les 20 messages
        success 'contient listing valide (avec les bons boutons pour le grade donné)'

      end
    end
    #/Fin de scénario de listing de sujet pour une SIMPLE RÉDACTRICE (grade 4)









  scenario '=> un RÉDACTEUR trouve un listing de messages conforme' do

    huser_current = @dRedacteur
    user_current  = User.get(huser_current[:id])
    user_grade    = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # On vérifie le grade ici
    expect(user_grade).to eq 5

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère seulement quatre messages
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
      LIMIT 4
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify huser_current
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')

    # Il clique pour voir le sujet choisi
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    # Il arrive sur le listing des messages
    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end

    # Les liens pour souscrire au sujet ou non
    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)

    end
    expect(page).to have_tag('div.buttons.top') do
      success 'contient des liens pour… '
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouveau sujet")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
      success '… créer un nouveau sujet'

      # Lien pour valider le sujet (grade 7) : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"})
      # Lien pour clore le sujet (grade 7) : NON
      without_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      # Lien pour détruire le sujet : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"})
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts.each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
          expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"

            # Lien pour répondre au message : OUI (si autre auteur)
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            # Lien pour valider : NON
            # if hpost[:auteur_id] != user_current.id
            #   with_tag('a', with: {href: "#{url}?op=v"})
            # else
              without_tag('a', with: {href: "#{url}?op=v"})
            # end

            # Liens pour voter pour ou contre : NON
            without_tag('a', with: {href: "#{url}?op=u"})
            without_tag('a', with: {href: "#{url}?op=d"})
            # Lien pour détruire le message : NON
            without_tag('a', with: {href: "#{url}?op=k"})
            # Lien pour signaler le message : OUI
            with_tag('a', with: {href: "#{url}?op=n"})
            # Lien pour modifier le message
            # Admin ou auteur du message
            can_modify = user_current.admin? || user_current.id == hpost[:auteur_id]
            if can_modify
              with_tag('a', with: {href: "#{url}?op=m"})
            else
              without_tag('a', with: {href: "#{url}?op=m"})
            end
          end
        end

      end
      #/Fin de boucle sur les 20 messages
      success 'contient listing valide (avec les bons boutons pour le grade donné)'

    end
  end
  #/Fin de scénario de listing de sujet pour un RÉDACTEUR (grade 5)









  scenario '=> un RÉDACTEUR ÉMÉRITE trouve un listing de messages conforme' do

    huser_current = @dRedacteurEmerite
    user_current  = User.get(huser_current[:id])
    user_grade    = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # On vérifie le grade ici
    expect(user_grade).to eq 6

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère seulement quatre messages
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
      LIMIT 4
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify huser_current
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')

    # Il clique pour voir le sujet choisi
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    # Il arrive sur le listing des messages
    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end

    # Les liens pour souscrire au sujet ou non
    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
    end
    expect(page).to have_tag('div.buttons.top') do
      success 'contient des liens pour… '
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouveau sujet")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
      success '… créer un nouveau sujet'

      # Lien pour valider le sujet (grade 7) : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"})
      # Lien pour clore le sujet (grade 7) : NON
      without_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      # Lien pour détruire le sujet : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"})
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts.each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
          expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"

            # Lien pour répondre au message : OUI (si autre auteur)
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            # Lien pour valider : OUI
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=v"})
            else
              without_tag('a', with: {href: "#{url}?op=v"})
            end

            # Liens pour voter pour ou contre : NON
            without_tag('a', with: {href: "#{url}?op=u"})
            without_tag('a', with: {href: "#{url}?op=d"})
            # Lien pour détruire le message : OUI
            with_tag('a', with: {href: "#{url}?op=k"})
            # Lien pour signaler le message : OUI
            with_tag('a', with: {href: "#{url}?op=n"})
            # Lien pour modifier le message
            # Admin ou auteur du message
            can_modify = user_current.admin? || user_current.id == hpost[:auteur_id]
            if can_modify
              with_tag('a', with: {href: "#{url}?op=m"})
            else
              without_tag('a', with: {href: "#{url}?op=m"})
            end
          end
        end

      end
      #/Fin de boucle sur les messages
      success 'contient listing valide (avec les boutons pour supprimer ou valider les messages)'

    end
  end
  #/Fin de scénario de listing de sujet pour un RÉDACTEUR ÉMÉRITE (grade 6)












  scenario '=> un RÉDACTRICE CONFIRMÉE trouve un listing de messages conforme' do

    huser_current = @dRedactriceConfirmee
    user_current  = User.get(huser_current[:id])
    user_grade    = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # On vérifie le grade ici
    expect(user_grade).to eq 7

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère seulement quatre messages
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
      LIMIT 4
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify huser_current
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')

    # Il clique pour voir le sujet choisi
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    # Il arrive sur le listing des messages
    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end

    # Les liens pour souscrire au sujet ou non
    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
    end
    expect(page).to have_tag('div.buttons.top') do
      success 'contient des liens pour… '
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouveau sujet")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
      success '… créer un nouveau sujet'
      # Lien pour valider le sujet (grade 7) : OUI
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"}, text: 'Valider ce sujet')
      success '… valider un sujet'
      # Lien pour clore le sujet (grade 7) : OUI
      with_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      success '… clore un sujet'
      # Lien pour détruire le sujet : NON
      without_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"}, text: 'Détruire ce sujet')
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts.each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
          expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"

            # Lien pour répondre au message : OUI (si autre auteur)
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            # Lien pour valider : OUI
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=v"})
            else
              without_tag('a', with: {href: "#{url}?op=v"})
            end

            # Liens pour voter pour ou contre : OUI
            with_tag('a', with: {href: "#{url}?op=u"})
            with_tag('a', with: {href: "#{url}?op=d"})

            # Lien pour détruire le message : OUI
            with_tag('a', with: {href: "#{url}?op=k"})
            # Lien pour signaler le message : OUI
            with_tag('a', with: {href: "#{url}?op=n"})
            # Lien pour modifier le message
            # Admin ou auteur du message
            can_modify = user_current.admin? || user_current.id == hpost[:auteur_id]
            if can_modify
              with_tag('a', with: {href: "#{url}?op=m"})
            else
              without_tag('a', with: {href: "#{url}?op=m"})
            end
          end
        end

      end
      #/Fin de boucle sur les messages
      success 'contient listing valide (avec les boutons pour supprimer ou valider les messages)'

    end
  end
  #/Fin de scénario de listing de sujet pour un RÉDACTRICE CONFIRMÉE (grade 7)



















  scenario '=> un MAITRE RÉDACTEUR trouve un listing de messages conforme' do

    huser_current = @dMaitreRedacteur
    user_current  = User.get(huser_current[:id])
    user_grade    = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # On vérifie le grade ici
    expect(user_grade).to eq 8

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère seulement quatre messages
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
      LIMIT 4
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify huser_current
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')

    # Il clique pour voir le sujet choisi
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    # Il arrive sur le listing des messages
    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end

    # Les liens pour souscrire au sujet ou non
    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
    end
    expect(page).to have_tag('div.buttons.top') do
      success 'possède des liens pour…'
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouveau sujet")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
      success '… créer un nouveau sujet'
      # Lien pour valider le sujet (grade 7) : OUI
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"}, text: 'Valider ce sujet')
      success '… valider le sujet'
      # Lien pour clore le sujet (grade 7) : OUI
      with_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      success '… clore le sujet'
      # Lien pour détruire le sujet : NON
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"}, text: 'Détruire ce sujet')
      success '… détruire le sujet'
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts.each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
          expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"

            # Lien pour répondre au message : OUI (si autre auteur)
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            # Lien pour valider : OUI
            if hpost[:auteur_id] != user_current.id
              with_tag('a', with: {href: "#{url}?op=v"})
            else
              without_tag('a', with: {href: "#{url}?op=v"})
            end

            # Liens pour voter pour ou contre : OUI
            with_tag('a', with: {href: "#{url}?op=u"})
            with_tag('a', with: {href: "#{url}?op=d"})

            # Lien pour détruire le message : OUI
            with_tag('a', with: {href: "#{url}?op=k"})
            # Lien pour signaler le message : OUI
            with_tag('a', with: {href: "#{url}?op=n"})
            # Lien pour modifier le message
            # Admin ou auteur du message
            can_modify = user_current.admin? || user_current.id == hpost[:auteur_id]
            if can_modify
              with_tag('a', with: {href: "#{url}?op=m"})
            else
              without_tag('a', with: {href: "#{url}?op=m"})
            end
          end
        end

      end
      #/Fin de boucle sur les messages
      success 'contient listing valide (avec les boutons pour supprimer ou valider les messages)'

    end
  end
  #/Fin de scénario de listing de sujet pour un MAITRE RÉDACTEUR (grade 8)



















  scenario '=> une EXPERTE D’ÉCRITURE trouve un listing de messages conforme' do

    # On va vérifier l'affichage de tous les messages du premier sujet
    # qu'on trouve, avec des liens qui permettent de tout faire puisque
    # c'est un administrateur.

    huser_current = @dExperteEcriture
    user_current = User.get(huser_current[:id])
    user_grade   = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # Le grade doit être le bon
    expect(user_grade).to eq 9

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère tous ces messages en une seule fois
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify huser_current
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end
    success 'contient le bon titre'

    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)

    end
    success 'contient les informations sur le sujet'
    success 'contient des liens pour…'
    expect(page).to have_tag('div.buttons.top') do
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouveau sujet")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
      success '… créer un nouveau sujet'
      # Lien pour valider le sujet (grade 8) : OUI
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"}, text: 'Valider ce sujet')
      success '… valider le sujet'
      # Lien pour clore le sujet (grade 8) : OUI
      with_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      success '… clore le sujet'
      # Lien pour détruire le sujet : OUI
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"}, text: 'Détruire ce sujet')
      success '… détruire le sujet'
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts[0..19].each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
        expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"
            # Il y un lien pour répondre au message sauf si l'auteur du
            # message est le visiteur courant
            can_answer = (hpost[:auteur_id] != user_current.id) && user_grade > 4
            if can_answer
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            can_validate = (hpost[:auteur_id] != user_current.id) && user_grade >= 6
            if can_validate
              with_tag('a', with: {href: "#{url}?op=v"}, text: 'Valider')
            else
              without_tag('a', with: {href: "#{url}?op=v"})
            end
            # Il y a des liens pour voter pour ou contre
            with_tag('a', with: {href: "#{url}?op=u"})
            with_tag('a', with: {href: "#{url}?op=d"})
            # Il y a un lien pour détruire le message
            with_tag('a', with: {href: "#{url}?op=k"})
            # Il y a un lien pour signaler le message
            with_tag('a', with: {href: "#{url}?op=n"})
            # Il y a un lien pour modifier le message si c'est l'administrateur
            # ou si c'est l'auteur du message
            with_tag('a', with: {href: "#{url}?op=m"})
          end
        end

      end
      #/Fin de boucle sur les 20 messages
      success 'contient un bon listing des 20 messages'

    end
  end
  #/Fin de scénario de listing de sujet pour une EXPERTE D'ÉCRITURE (grade 9)



















  scenario '=> un ADMINISTRATEUR trouve un listing de messages conforme' do

    # On va vérifier l'affichage de tous les messages du premier sujet
    # qu'on trouve, avec des liens qui permettent de tout faire puisque
    # c'est un administrateur.

    user_current = phil
    user_grade   = user_current.data[:options][1].to_i
    notice "User courant : #{user_current.pseudo} (##{user_current.id})"
    notice "Grade de #{user_current.pseudo} : #{user_grade}"

    # Le grade doit être le bon
    expect(user_grade).to eq 9

    hsujet_cur = all_sujets_forum(0,2,{grade: user_grade}).last

    sid = hsujet_cur[:id]

    # On récupère tous ces messages en une seule fois
    request = <<-SQL
    SELECT p.*,
      uf.upvotes AS auteur_upvotes, uf.downvotes AS auteur_downvotes,
      uf.last_post_id AS auteur_last_post_id, uf.count AS auteur_post_count,
      p2.sujet_id AS auteur_last_post_sujet_id,
      p2.created_at AS auteur_last_post_date,
      u.pseudo AS auteur_pseudo, u.id AS auteur_id, u.created_at AS auteur_created_at,
      c.content, v.upvotes, v.downvotes
      FROM posts p
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      INNER JOIN `boite-a-outils_forum`.users uf ON p.user_id = uf.id
      INNER JOIN posts_content c  ON p.id = c.id
      INNER JOIN posts_votes v    ON p.id = v.id
      INNER JOIN posts p2         ON uf.last_post_id = p2.id
      WHERE p.sujet_id = #{hsujet_cur[:id]}
      ORDER BY p.created_at DESC
    SQL
    site.db.use_database(:forum)
    hposts = site.db.execute(request)


    identify phil
    visit forum_page
    expect(page).to have_tag('h2', text: 'Forum d’écriture')
    expect(page).to have_tag('fieldset', with:{ id: 'last_messages'})
    within('fieldset#last_messages') do
      page.find("div#sujet-#{hsujet_cur[:id]} span.titre a").click
    end

    expect(page).to have_tag('h2') do
      with_tag('a', with: {href: "forum/home"}, text: 'Forum')
      with_tag('a', with: {href: "forum/sujet/#{hsujet_cur[:id]}?from=1"}, text: "sujet ##{hsujet_cur[:id]}")
    end
    success 'contient le bon titre'

    expect(page).to have_tag('div', with: {id: "entete_sujet-#{sid}", class: 'entete_sujet'}) do
      with_tag('span', with: {class: 'titre'}, text: hsujet_cur[:titre])
      with_tag('span', with: {class: 'sujet_creator'}, text: hsujet_cur[:creator_pseudo])
      with_tag('span', with: {class: 'sujet_at'}, text: hsujet_cur[:created_at].as_human_date)
    end
    success 'contient les informations sur le sujet'

    success 'contient des liens pour… '
    expect(page).to have_tag('div.buttons.top') do
      # Liens pour souscrire au sujet ou contraire
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=1"})
      success '… suivre le sujet'
      # with_tag('a', with: {href: "forum/sujet/#{sid}?op=suivre&v=0"})
      # Lien pour créer un nouveau sujet : OUI (avec le titre "Nouveau sujet")
      with_tag('a', with: {href: "forum/sujet/new"}, text: 'Nouveau sujet')
      success '… créer un nouveau sujet'
      # Lien pour valider le sujet (grade 7) : OUI
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=validate"}, text: 'Valider ce sujet')
      success '… valider le sujet'
      # Lien pour clore le sujet (grade 7) : OUI
      with_tag('a', with:{href: "forum/sujet/#{sid}?op=clore"}, text: 'Clore ce sujet')
      success '… clore le sujet'
      # Lien pour détruire le sujet : NON
      with_tag('a', with: {href: "forum/sujet/#{sid}?op=kill"}, text: 'Détruire ce sujet')
      success '… détruire le sujet'
    end

    expect(page).to have_tag('fieldset', with:{class: 'post_list', id: "post_list-#{hsujet_cur[:id]}"}) do
      with_tag('legend', text: 'Liste des messages')

      # La liste des messages actuels
      # ------------------------------
      hposts[0..19].each do |hpost|
        # puts "POST #{hpost[:id]}"

        # Les votes pour le message
        upvotes   = hpost[:upvotes].as_id_list.count
        downvotes = hpost[:downvotes].as_id_list.count

        # Le DIV contenant tout le message
        with_tag('div', with: {class: 'post', id: "post-#{hpost[:id]}"}) do

          # Le DIV de la carte de l'auteur du message
          with_tag('div', with: {class: 'user_card'}) do
            with_tag('span', with: {class: 'pseudo'}, text: hpost[:auteur_pseudo])
            with_tag('span', with: {class: 'created_at'}, text: hpost[:auteur_created_at].as_human_date)
            fame = hpost[:auteur_upvotes] - hpost[:auteur_downvotes]
            with_tag('span', with: {class: "fame #{fame > 0 ? 'bon' : 'bad'}"}, text: fame.to_s)
            with_tag('span', with: {class: 'ups'}, text: hpost[:auteur_upvotes].to_s)
            with_tag('span', with: {class: 'downs'}, text: hpost[:auteur_downvotes].to_s)
            with_tag('span', with: {class: 'post_count'}, text: hpost[:auteur_post_count].to_s)
            with_tag('span', with: {class: 'last_post'}) do
              with_tag('a', with: {href: "forum/sujet/#{hpost[:auteur_last_post_sujet_id]}?pid=#{hpost[:auteur_last_post_id]}"}, text: hpost[:auteur_last_post_date].as_human_date)
            end
          end

          # L'entête du message
          # Note : pour le moment, ne contient que la marque de vote, au-dessus
          # pour savoir tout de suite comment est coté le message.
          with_tag('div', with: {class: 'post_header'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end

          # Le contenu du message
          # Note : on vérifie seulement les x premiers caractères
          c = hpost[:content].gsub(/<(.*?)>/, '')
          c = c[0..50]
          with_tag('div', with: {class: 'content'}, text: /#{c}/)

          # Le pied de page du message
          # --------------------------
          # Avec le contenu, c'est lui le plus important puisqu'il permet de
          # plébisciter le message, de lui répondre, etc.
          with_tag('div', {class: 'post_footer'}) do
            with_tag('span', with: {class: 'post_upvotes'}, text: upvotes)
            with_tag('span', with: {class: 'post_downvotes'}, text: downvotes)
          end


        end #/dans le listing

        # ----------------------------------------
        # CE QU'IL PEUT Y AVOIR OU NE PAS Y AVOIR
        # ----------------------------------------
          expect(page).to have_tag('fieldset', with: {class: 'post_list'}) do
          with_tag('div', {class: 'post_footer'}) do
            url = "forum/post/#{hpost[:id]}"
            # Il y un lien pour répondre au message sauf si l'auteur du
            # message est le visiteur courant
            can_answer = hpost[:auteur_id] != user_current.id && user_grade > 4
            if can_answer
              with_tag('a', with: {href: "#{url}?op=a"})
            else
              without_tag('a', with: {href: "#{url}?op=a"})
            end

            can_validate = (hpost[:auteur_id] != user_current.id) && user_grade >= 6
            if can_validate
              with_tag('a', with: {href: "#{url}?op=v"}, text: 'Valider')
            else
              without_tag('a', with: {href: "#{url}?op=v"})
            end
            # Il y a des liens pour voter pour ou contre
            with_tag('a', with: {href: "#{url}?op=u"})
            with_tag('a', with: {href: "#{url}?op=d"})
            # Il y a un lien pour détruire le message
            with_tag('a', with: {href: "#{url}?op=k"})
            # Il y a un lien pour signaler le message
            with_tag('a', with: {href: "#{url}?op=n"})
            # Il y a un lien pour modifier le message si c'est l'administrateur
            # ou si c'est l'auteur du message
            with_tag('a', with: {href: "#{url}?op=m"})
          end
        end

      end
      #/Fin de boucle sur les 20 messages
      success 'contient un bon listing des 20 messages'

    end
  end
  #/Fin de scénario de listing de sujet pour un adminitrateur














end
