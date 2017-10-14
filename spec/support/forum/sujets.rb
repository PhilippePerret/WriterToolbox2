
# Création de sujets
#
#   :auteurs        Liste des IDs des auteurs (pouvant créer des sujets)
#   :validate       1: tous les sujets sont validés, 0: tous les sujets
#                   sont non validés, 2: l'un et l'autre, au hasard
#   :types_s        Les « types S » pour le bit 2 des specs (cf. le manuel).
#                   Par défaut : [0, 1, 2, 9]. Si la donnée n'est pas spécifiée
#                   les types S seront choisis aléatoirement.
#   :with_posts     Si true, on crée des messages en nombre aléatoire
#                   Si un rang (p.e. '10..20') on crée ce nombre de message
#                   aléatoirement
#   :with_votes     Si true, on crée des votes pour les messages (donc :with_posts
#                   doit être true).
#
def forum_create_sujets nombre, params = nil
  start_time = Time.now.to_i
  params ||= Hash.new
  params[:auteurs] ||= [1,2,3]
  site.db.use_database(:forum)
  request = "INSERT INTO sujets (titre, creator_id, created_at, updated_at, specs) VALUES (?, ?, ?, ?, ?)"
  values = Array.new
  now = Time.now.to_i
  last_creator = params[:auteurs].count - 1
  nombre.times do |itime|
    creator_id = params[:auteurs][rand(0..last_creator)]
    created = now - rand(0..3600000)
    updated = created + rand(0..360000)
    updated < now || updated = now
    specs = '0'*8
    specs[0] =
      case params[:validate]
      when 0, false then '0'
      when 1, true  then '1'
      when 2, nil   then rand(0..1)
      end
    types_s = (params[:types_s] || [0,1,2,9])
    last_type_s = types_s.count - 1
    specs[1] = types_s[rand(0..last_type_s)].to_s

    values << [titre_hasard(Time.now.to_i.as_human_date), creator_id, created, updated, specs]
  end
  site.db.execute(request, values)

  # --------------------------------------------
  # Faut-il créer des messages pour les sujets ?
  # --------------------------------------------
  if params[:with_posts]
    rang_nombre =
      if params[:with_posts] === true
        10..50
      elsif params[:with_posts].is_a?(Array)
        params[:with_posts][0]..params[:with_posts[1]]
      else
        params[:with_posts]
      end
    posts_params = {authors: params[:auteurs], moderators: [1,3], validate: true, votes: params[:with_votes]}
    site.db.select(:forum,'sujets',"1 = 1 ORDER BY id DESC LIMIT #{nombre}").each do |hsujet|
      forum_create_posts hsujet[:id], rand(rang_nombre), posts_params
    end
  end
end

def titre_hasard date = nil
  a = Array.new
  case rand(4)
  when 0 then
    a << mot_masculin_hasard(true,false)
    a << ['est-il','a-t-il','suit-il','vaut-il','mange-t-il'][rand(5)]
    a << mot_feminin_hasard
  when 1 then
    a << mot_feminin_hasard(true)
    a << ['est-elle','a-t-elle','suit-elle','vaut-elle'][rand(4)]
    a << mot_masculin_hasard
  when 2 then
    a << mot_masculin_hasard(true,true)
    a << ['sont-ils','ont-t-ils','suivent-ils','valent-ils'][rand(4)]
    a << mot_feminin_hasard(false,true)
  when 3 then
    a << mot_feminin_hasard(true,true)
    a << ['sont-elles','ont-t-elles','suivent-elles','valent-elles'][rand(4)]
    a << mot_masculin_hasard(false,true)
  end
  date && a << "le #{date}"
  return a.join(' ')
end
def mot_feminin_hasard maj = false, plur = false
  res =
    if plur
      ['les','des'][rand(2)]
    else
      ['la','une'][rand(2)]
    end +' ' +
  ['petite','grande','longue','lointaine'][rand(4)] +
  (plur ? 's' : '') + ' ' +
  ['chambre','rangée','tige','chenille','caravane','pierre','table'][rand(7)] +
  (plur ? 's' : '')
  maj && res = res.titleize
  return res
end
def mot_masculin_hasard maj = false, plur = false
  res =
    if plur
      ['les', 'des'][rand(2)]
    else
      ['le','un'][rand(2)]
    end + ' ' +
  ['petit','grand','long','lointain'][rand(4)] + (plur ? 's' : '')+ ' ' +
  ['cousin','véhicule','avion','portique','cornichon','ver'][rand(6)] + (plur ? 's' : '')
  maj && res = res.titleize
  return res
end


# Retourne tous les sujets du forum
# Chaque élément est un hash des données du sujet, auquel est ajouté
# la donnée `creator_pseudo` qui est le pseudo du créateur du sujet.
#
def all_sujets_forum from = nil, nombre = nil, options = nil
  options ||= Hash.new
  where =
    if options.key?(:grade)
      " WHERE CAST(SUBSTRING(s.specs,6,1) AS UNSIGNED) <= #{options[:grade]}"
    else
      ''
    end
  limit =
    if nombre != nil
      from ||= 0
      " LIMIT #{from}, #{nombre}"
    else
      ''
    end

  request = <<-SQL
  SELECT s.*, u.pseudo AS creator_pseudo
    FROM sujets s
    INNER JOIN `boite-a-outils_hot`.users u
      ON s.creator_id = u.id
    #{where}
    ORDER BY updated_at DESC
    #{limit}
  SQL

  site.db.use_database(:forum)
  site.db.execute(request)
end

# Retourne les données {Hash} d'un sujet choisi au hasard
#
# @param {Hash|Nil} options
#                   :minimum_count    Si défini, correspond au minimum de messages
#                                     que doit posséder le sujet demandé.
def forum_get_sujet options = nil
  options ||= Hash.new
  where = Array.new
  options[:minimum_count] && where << "count >= #{options[:minimum_count]}"
  options[:maximum_count] && where << "count <= #{options[:maximum_count]}"

  # Si on ne trouve pas de sujets, on initialise tout
  begin
    sujets = site.db.select(
      :forum,'sujets',
      (where.count > 0 ? where.join(' AND ') : nil),
      [:id])
    sujets.count > 0 || raise
  rescue
    reset_all_data_forum
    retry
  end
  # On mélange les sujets et on prend le premier
  sujet_id = sujets.shuffle.shuffle.first[:id]
  site.db.select(:forum,'sujets',{id: sujet_id}).first
end

# Retourne tous les messages du sujet +sujet_id+, avec les données
# complète
def forum_get_posts_of_sujet sujet_id
  request = <<-SQL
  SELECT p.*
  , u.pseudo AS auteur_pseudo, u.id AS auteur_id
  , c.content
  , v.vote, v.upvotes, v.downvotes
  FROM posts p
  INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
  INNER JOIN posts_content c ON p.id = c.id
  INNER JOIN posts_votes v ON p.id = v.id
  WHERE sujet_id = #{sujet_id}
  ORDER BY p.created_at ASC
  SQL
  site.db.use_database(:forum)
  site.db.execute(request)
end
