require 'betterlorem'

# Crée +nombre_posts+ posts pour le sujet d'ID +sujet_id+ avec
# les paramètres +params+
#
# @param {Hash} params
#               === OBLIGATOIRE ===
#               authors:      Array des IDs des auteurs des messages
#               moderators:   Array des modérateurs pouvant valider les
#                             messages (si :validate est true ou nil)
#               === OPTIONNEL ===
#               :validate   True : tous les messages sont validés
#                           False : aucun message n'est validés
#                           Nil   : certains validés, d'autres nom (défaut)
#               :votes      True : on crée des votes pour le message
#
DATA_POST_PROPS     = [:sujet_id, :user_id, :valided_by, :options, :created_at, :updated_at]
CONTENT_POST_PROPS  = [:id, :content, :created_at, :updated_at]
VOTE_POST_PROPS     = [:id, :vote, :upvotes, :downvotes, :created_at, :updated_at]
def forum_create_posts sujet_id, nombre_posts, params
  auteurs   = params[:authors]
  last_index_auteur = auteurs.count - 1
  modos     = params[:moderators]
  last_index_modo = modos.count - 1
  all_users_ids = (auteurs + modos).uniq
  nombre_users  = all_users_ids.count
  last_index_user = nombre_users - 1
  with_vote = params[:votes]
  now       = Time.now.to_i
  params.key?(:validate) || params.merge!(validate: nil)


  colonnes_data = DATA_POST_PROPS.collect{|p| p.to_s}.join(', ')
  interros_data = DATA_POST_PROPS.collect{|p| '?'}.join(', ')
  colonnes_content  = CONTENT_POST_PROPS.collect{|p| p.to_s}.join(', ')
  interros_content  = CONTENT_POST_PROPS.collect{|p| '?'}.join(', ')
  colonnes_vote     = VOTE_POST_PROPS.collect{|p| p.to_s}.join(', ')
  interros_vote     = VOTE_POST_PROPS.collect{|p| '?'}.join(', ')

  request_data = "INSERT INTO posts (#{colonnes_data}) VALUES (#{interros_data});"
  request_content = "INSERT INTO posts_content (#{colonnes_content}) VALUES (#{interros_content});"
  request_vote    = "INSERT INTO posts_votes (#{colonnes_vote}) VALUES (#{interros_vote});"

  site.db.use_database(:forum)

  # Pour connaitre le message le plus récent et l'enregistrer
  # dans le sujet (sauf si le sujet possède un message encore plus récent
  # déjà enregistré)
  created_plus_recent = 0
  last_post_id        = nil
  last_post_date      = nil

  # Boucle sur le nombre de posts
  nombre_posts.times do |itime|

    is_valided =
      case params[:validate]
      when true   then true
      when false  then false
      when nil    then [true, false][rand(0..1)]
      end
    ctime = now - rand(1000..3600000)
    mtime = ctime + rand(1000..40000)
    mtime < now || mtime = now

    options = '0'*16
    options[0] = (is_valided ? '1' : '0')


    data_post = {
      sujet_id:   sujet_id,
      user_id:    auteurs[rand(0..last_index_auteur)],
      created_at: ctime,
      updated_at: mtime,
      valided_by: (is_valided ? modos[rand(0..last_index_modo)] : nil),
      options:    options
    }
    values_data = DATA_POST_PROPS.collect{|prop| data_post[prop]}
    site.db.execute(request_data, values_data)
    post_id = site.db.last_id_of(:forum)
    post_id != nil || raise("Le message n'a pas pu être créé")

    # On mémorise le message si c'est le plus récent jusqu'à présent
    if ctime > created_plus_recent
      created_plus_recent = ctime
      last_post_id        = post_id
      last_post_date      = ctime   # pour updated_at du sujet
    end

    nombre_paragraphes = rand(1..20)
    contenu = BetterLorem.p(nombre_paragraphes)
    content_post = {
      id: post_id,
      created_at: ctime,
      updated_at: mtime,
      content: contenu
    }
    values_content = CONTENT_POST_PROPS.collect{|p| content_post[p]}
    site.db.execute(request_content, values_content)

    if with_vote
      nombre_votants = rand(0..nombre_users)
      upvotes   = nil
      downvotes = nil
      if nombre_votants > 0
        nombre_upvoteurs    = rand(0..nombre_votants)
        nombre_downvoteurs  = nombre_votants - nombre_upvoteurs
        uids = all_users_ids.shuffle.shuffle
        # puts "uids = #{uids.inspect}"
        if nombre_upvoteurs > 0
          upvotes   = uids[0..nombre_upvoteurs-1].join(' ')
          # puts "upvotes   = uids[0..#{nombre_upvoteurs-1}] = #{upvotes}"
        end
        if nombre_downvoteurs > 0
          downvotes = uids[nombre_upvoteurs..(nombre_upvoteurs+nombre_downvoteurs-1)].join(' ')
          # puts "downvotes = uids[#{nombre_upvoteurs}..#{nombre_upvoteurs+nombre_downvoteurs-1}] = #{downvotes}"
        end
        vote      = nombre_upvoteurs - nombre_downvoteurs
      else
        vote      = 0
      end
      vote_post = {
        id: post_id,
        created_at: ctime,
        updated_at: mtime,
        vote:       vote,
        upvotes:    upvotes,
        downvotes:  downvotes
      }
      values_vote = VOTE_POST_PROPS.collect{|p| vote_post[p]}
      site.db.execute(request_vote, values_vote)
    end
    #/Fin de s'il faut des votes

  end
  # / fin de boucle sur chaque message créé

  hsujet = site.db.select(:forum,'sujets',{id: sujet_id}).first

  # S'il avait déjà un dernier message, on le charge pour voir s'il y en
  # a un plus récent
  if hsujet[:last_post_id]
    hlast_post = site.db.select(:forum,'posts',{id: hsujet[:last_post_id]}).first
    if created_plus_recent < hlast_post[:created_at]
      last_post_id    = hsujet[:last_post_id]
      last_post_date  = hlast_post[:created_at]
    end
  end

  # Ensuite, il faut faire des ajustements sur le sujet
  new_sujet_data = {
    last_post_id: last_post_id,
    updated_at:   last_post_date,
    count:        (hsujet[:count]||0) + nombre_posts,
    views:        rand(10..1000)
  }
  site.db.update(:forum, 'sujets', new_sujet_data, {id: sujet_id})

end

# Retourne les données du post d'id +post_id+ en ajoutant des
# données comme le pseudo de l'auteur (:auteur_pseudo)
#     :content        Contenu textuel du message
#     :vote           Fixnum de la note de vote
#     :upvotes        (as_id_list) pour avoir une liste d'identifiants d'user
#     :downvotes      (as_id_list) pour avoir une liste d'id d'users
#
def forum_get_post post_id
  req = 'SELECT p.*, u.id AS auteur_id, u.pseudo AS auteur_pseudo, c.content, v.*'
  req << ' FROM posts p'
  req << ' INNER JOIN `boite-a-outils_hot`.users u'
  req << '   ON p.user_id = u.id'
  req << ' INNER JOIN posts_content c'
  req << '   ON p.id = c.id'
  req << ' INNER JOIN posts_votes v'
  req << '   ON p.id = v.id'
  req << " WHERE p.id = #{post_id}"
  site.db.use_database(:forum)
  site.db.execute(req).first
end
