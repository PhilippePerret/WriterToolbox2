require 'betterlorem'

# Retourne les données d'un post pris au hasard
#
# @param {Hash} params
#               :validated      Si true (défault), cherche un mail validé
#                               Si false, cherche un mail non validé
#               :destroyed      Si true, cherche un mail détruit
#                               False par défaut
#               :refused        Si true, cherche un mail refusé
#                               false par défaut
#               :not_user_id    Un mail qui ne soit pas de cet auteur
#               :user_id        Un mail de cet auteur
#               :sujet_id       Un mail de ce sujet
#
#               :upvoted        Si true, il faut un message qui a reçu des
#                               upvote. Si false => sans upvotes
#               :downvoted      Si true, il faut un message qui a reçu des
#                               downvotes. Si false => sans downvotes
#               :vote_zero      Si true, le vote doit être égal à zéro. Si
#                               false, il doit être différent de zéro.
#               :vote_positif   true: vote doit > 0, false: doit être <= 0.
#               :vote_negatif   true: vote doit < 0, false: doit être >= 0.
#
def forum_get_random_post params = nil
  params ||= Hash.new
  params.key?(:validated) || params.merge!(validated: true)
  params.key?(:destroyded)|| params.merge!(destroyed: false)
  params.key?(:refused)   || params.merge!(refused: false)

  # Les conditions générales pour la table 'posts'
  conditions = Array.new


  # S'il y a des conditions sur les votes, il faut impérativement charger
  # la liste d'IDs de posts_votes puis chercher les posts dans cette liste
  if params.key?(:upvoted) || params.key?(:downvoted)
    condvotes = Array.new
    case params[:upvoted]
    when true   then condvotes << 'upvotes IS NOT NULL'
    when false  then condvotes << 'upvotes = NULL'
    end
    case params[:downvoted]
    when true   then condvotes << 'downvotes IS NOT NULL'
    when false  then condvotes << 'downvotes = NULL'
    end
    case params[:vote_positif]
    when true   then condvotes << 'vote > 0'
    when false  then condvotes << 'vote <= 0'
    end
    case params[:vote_negatif]
    when true   then condvotes << 'vote < 0'
    when false  then condvotes << 'vote >= 0'
    end
    case params[:vote_zero]
    when true   then condvotes << 'vote = 0'
    when false  then condvotes << 'vote != 0'
    end

    condvotes = condvotes.join(' AND ')
    ids = site.db.select(:forum,'posts_votes',condvotes,[:id]).collect{|h|h[:id]}
    if ids.count < 0
      raise "Malheureusement, il est impossible d'appliquer la condition #{condvotes} à la table `posts_votes`. Elle ne retourne aucun message, donc aucun message aléatoire ne pourra être renvoyé… Il faut modifier les conditions, ou, peut-être, relancer le reset du forum pour les tests."
    end
    conditions << "id IN (#{ids.join(', ')})"
  end



  opts = "000"
  case params[:validated]
  when true   then opts[0] = '1'
  when false  then opts[0] = '0'
  end

  case params[:destroyed]
  when true   then opts[1] = '1'
  when false  then opts[1] = '0'
  end

  case params[:refused]
  when true   then opts[2] = '1'
  when false  then opts[2] = '0'
  end

  conditions << "SUBSTRING(options,1,3) = '#{opts}'"

  params[:not_user_id]  && conditions << "user_id != #{params[:not_user_id]}"
  params[:user_id]      && conditions << "user_id = #{params[:user_id]}"
  params[:sujet_id]     && conditions << "sujet_id = #{params[:sujet_id]}"

  conditions = conditions.join(' AND ')
  conditions << " LIMIT 200"
  ids = site.db.select(:forum,'posts',conditions,[:id])
  if ids.count == 0
    raise "Malheureusement, aucun message forum n'a été trouvé avec les conditions : #{conditions}. Il faut modifier le filtre ou resetter les données du forum pour les tests."
  end
  # On retourne les données d'un post pris au hasard dans la liste
  return forum_get_post(ids.shuffle.shuffle.first[:id])
end


# Crée +nombre_posts+ posts pour le sujet d'ID +sujet_id+ avec
# les paramètres +params+
#
# NOTES
#   * Actualise aussi la table users avec le nombre de messages (count),
#     et l'id du dernier message (last_post_id).
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


  colonnes_data     = DATA_POST_PROPS.collect{|p| p.to_s}.join(', ')
  interros_data     = DATA_POST_PROPS.collect{|p| '?'}.join(', ')
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

  # Une table pour retenir les informations des users pour la
  # table `forum.users`. On doit retenir :
  # - le nombre de messages
  # - l'id du dernier message (en fonction de la date, mais on vérifiera
  #   au moment de le faire)
  user_posts = Hash.new

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

    uid = data_post[:user_id]
    user_posts.key?(uid) || begin
      user_posts.merge!(uid => {
        count:        0,
        last_post_id: nil,
        last_post_at: 0,
        upvotes:      0,
        downvotes:    0
        })
    end
    user_posts[uid][:count] += 1
    # Si le message est plus vieux que le plus vieux message créé jusqu'à
    # maintenant, on le mémorise.
    # Noter que si l'user possède déjà des messages, ses données courantes
    # seront comparées à celles-ci avant d'être modifiées.
    if user_posts[uid][:last_post_at] < data_post[:created_at]
      user_posts[uid].merge!(
        last_post_id: post_id,
        last_post_at: data_post[:created_at]
      )
    end

    nombre_paragraphes = rand(1..10)
    contenu = BetterLorem.p(nombre_paragraphes)
    content_post = {
      id:         post_id,
      created_at: ctime,
      updated_at: mtime,
      content:    contenu
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

        # L'auteur de ce message doit hérité de ce vote pour sa réputation
        # c'est-à-dire ses propres upvotes et downvotes
        user_posts[uid][:upvotes]   += nombre_upvoteurs
        user_posts[uid][:downvotes] += nombre_downvoteurs

      else
        vote      = 0
      end
      vote_post = {
        id:         post_id,
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

  # Il faut tenir à jour la table forum.users pour informer du nombre de
  # message et du dernier message de chaque user
  # +udata+ ci-dessous contient:
  #   :count    Le nombre de message créés ici (à ajouter à ce que l'auteur a)
  #   :last_post_id   ID du dernier post CRÉÉ ICI
  #   :last_post_at   Time du dernier post CRÉÉ ICI pour voir s'il faut actualiser
  #                   cette valeur.
  user_posts.each do |uid, udata|
    site.db.use_database(:forum)
    huser = site.db.execute("SELECT * FROM users WHERE id = #{uid}").first
    not_exists = huser == nil
    count         = nil
    last_post_id  = nil
    unless not_exists
      udata[:upvotes] += huser[:upvotes]
      udata[:downvotes] += huser[:downvotes]
      if huser[:last_post_id]
        # <= Il y a déjà un dernier post enregistré
        # => Il faut comparer sa date pour voir s'il doit être modifié
        hp = site.db.select(:forum,'posts',{id: huser[:last_post_id]},[:created_at]).first
        if hp[:created_at] > udata[:last_post_at]
          last_post_id = huser[:last_post_id] # inchangé
        end
      end
      count = huser[:count] + udata[:count]
    end

    count         ||= udata[:count]
    last_post_id  ||= udata[:last_post_id]
    upvotes       = udata[:upvotes]
    downvotes     = udata[:downvotes]

    request =
      if not_exists
        "INSERT INTO users (id, count, last_post_id, upvotes, downvotes) VALUES (#{uid}, #{count}, #{last_post_id}, #{upvotes}, #{downvotes});"
      else
        "UPDATE users SET count = #{count}, last_post_id = #{last_post_id}, upvotes = #{upvotes}, downvotes = #{downvotes} WHERE id = #{uid};"
      end
    site.db.use_database(:forum)
    site.db.execute(request)
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

# Pour correspondre à la forme `create_new_user`
#
# Contrairement à la méthode précédente, on se contente ici de créer
# le message dans ses trois tables 'posts', 'posts_content' et 'posts_votes',
# sans ajouter le message à son auteur ou son sujet (c'est justement pour tester
# ce genre de chose qu'on utilise cette méthode) — sauf indication contraire
#
# @param {Hash} params
#      DONNÉES OBLIGATOIRES
#     ======================
#     :auteur_id        ID de l'auteur du message
#                       Il peut avoir été créé par create_new_user
#
#      DONNÉES OPTIONNELLES
#     ======================
#       :sujet_id
#       :content
#       :validate       Si true, le post est validé et il faut l'information
#                       suivante
#       :validator_id   Si :validate est true, il faut l'ID du validateur. Sinon 1
#       :nombre_paragraphes     10 par défaut
#
def create_new_post params

  # Le contenu du message
  params[:content] ||= begin
    params[:nombre_paragraphes] ||= 10
    BetterLorem.p(params[:nombre_paragraphes])
  end

  # Si aucun sujet n'est défini, on le choisi au hasard
  params[:sujet_id] ||= begin
    uids = site.db.select(:forum,'sujets',nil,[:id]).collect{|h|h[:id]}
    uids.shuffle.shuffle.first
  end
  if params.key?(:validate) && params[:validate]
    params[:validator_id] ||= 1
  else
    params.merge!(validate: false)
    params[:validator_id] = nil
  end

  options = "#{params[:validate] ? '1' : '0'}0000000"

  new_post_id = site.db.insert(
    :forum, 'posts',
    {
      user_id:    params[:auteur_id],
      sujet_id:   params[:sujet_id],
      options:    options,
     valided_by:  params[:validator_id]}
  )
  site.db.insert(
    :forum, 'posts_content',
    {id: new_post_id, content: params[:content]}
  )
  site.db.insert(
    :forum, 'posts_votes',
    {id: new_post_id, vote: 0}
  )

  request = <<-SQL
  SELECT p.*, c.content, v.vote
  FROM posts p
  INNER JOIN posts_content c ON p.id = c.id
  INNER JOIN posts_votes v   ON p.id = v.id
  WHERE p.id = #{new_post_id}
  LIMIT 1
  SQL
  site.db.use_database(:forum)
  return site.db.execute(request).first
end

# POUR LA LISTE DES MESSAGES D'UN SUJET PARTICULIER, VOIR LE MODULE sujet.rb

# Retourne les DONNÉES COMPLÈTES du post d'id +post_id+
#
#     :auteur_id      ID de l'auteur du message (ou user_id)
#     :auteur_pseudo  Pseudo de l'auteur du message
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

# Retourne le tout dernier message déposé
def forum_get_last_post
  last_post_id = site.db.select(:forum,'posts',"1 = 1 ORDER BY created_at DESC LIMIT 1",[:id]).first[:id]
  forum_get_post(last_post_id)
end

# Retourne les posts de +from+ pour un nombre +nombre+ en respectant la
# clause +clause+
#
# @param {Hash} clause
#   :where      le 'where'
#   :order      le 'order by'
def forum_get_posts clause = nil, from = nil, nombre = nil
  req = 'SELECT p.*, u.*, c.content, v.*' +
        ' FROM posts p' +
        ' INNER JOIN `boite-a-outils_hot`.users u' +
        '   ON p.user_id = u.id' +
        ' INNER JOIN posts_content c' +
        '   ON p.id = c.id' +
        ' INNER JOIN posts_votes v' +
        '   ON p.id = v.id'
  clause[:where]  && req << " WHERE #{clause[:where]}"
  clause[:order]  && req << " ORDER BY #{clause[:order]}"
  nombre  && req << " LIMIT #{nombre}"
  from    && req << " OFFSET #{from}"
end

# Détruit tous les posts de l'utilisateur d'identifiant +user_id+ (qui peut
# être aussi une instance User)
def delete_all_posts_of user_id
  user_id.is_a?(User) && user_id = user_id.id
  ids = site.db.select(:forum,'posts',{user_id: user_id},[:id]).collect{|h|h[:id]}
  if ids.count > 0
    where = "id IN (#{ids.join(', ')})"
    site.db.delete(:forum,'posts',where)
    site.db.delete(:forum,'posts_content', where)
    site.db.delete(:forum,'posts_votes', where)
  end
  # Réglage de la donnée du user, on met son compte de messages à 0
  # et son dernier ID à nil.
  if site.db.count(:forum,'users',{id: user_id}) > 0
    request = "UPDATE users SET count = 0, last_post_id = NULL WHERE id = #{user_id};"
    site.db.use_database(:forum)
    site.db.execute(request)
  end
end
