
# Création de sujets
#
#   :auteurs        Liste des IDs des auteurs (pouvant créer des sujets)
#   :validate       1: tous les sujets sont validés, 0: tous les sujets
#                   sont non validés, 2: l'un et l'autre, au hasard
#   :types_s        Les « types S » pour le bit 2 des specs (cf. le manuel).
#                   Par défaut : [0, 1, 2, 9]. Si la donnée n'est pas spécifiée
#                   les types S seront choisis aléatoirement.
#
def forum_create_sujets nombre, params = nil
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

    values << ["Titre du sujet forum #{itime + 1}", creator_id, created, updated, specs]
  end
  site.db.execute(request, values)
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

# Retourne les données d'un sujet choisi au hasard
#
# @param {Hash|Nil} options
#                   :minimum_count    Si défini, correspond au minimum de messages
#                                     que doit posséder le sujet demandé.
def forum_get_sujet options = nil
  options ||= Hash.new
  where = Array.new
  options[:minimum_count] && where << "count >= #{options[:minimum_count]}"
  options[:maximum_count] && where << "count <= #{options[:maximum_count]}"

  where =
    if where.count > 0
      where.join(' AND ')
    else
      nil
    end
  sujet_id = site.db.select(:forum,'sujets',where,[:id]).shuffle.shuffle.first[:id]
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
