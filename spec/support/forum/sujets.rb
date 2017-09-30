
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
  req = String.new
  req << 'SELECT s.*, u.pseudo AS creator_pseudo'
  req << ' FROM sujets s'
  req << ' INNER JOIN `boite-a-outils_hot`.users u'
  req << '   ON s.creator_id = u.id'
  if options.key?(:grade)
    req << " WHERE CAST(SUBSTRING(s.specs,6,1) AS UNSIGNED) <= #{options[:grade]}"
  end
  req << ' ORDER BY updated_at DESC'
  if nombre != nil
    from ||= 0
    req << " LIMIT #{from}, #{nombre}"
  end
  site.db.use_database(:forum)
  site.db.execute(req)
end
