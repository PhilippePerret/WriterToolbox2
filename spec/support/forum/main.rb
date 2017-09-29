=begin

  Fichier principal du support pour le forum

=end

def forum_truncate_all_tables
  site.db.use_database :forum
  forum_tables.each do |table_name|
    site.db.execute("TRUNCATE TABLE #{table_name};")
  end
end

# Création de sujets
#
#   :auteurs        Liste des IDs des auteurs (pouvant créer des sujets)
#   :validate       1: tous les sujets sont validés, 0: tous les sujets
#                   sont non validés, 2: l'un et l'autre, au hasard
#   :types_s        Les « types S » pour le bit 2 des specs (cf. le manuel).
#                   Par défaut : [0, 1, 2, 9]
#   :messages       true      Il faut créer des messages, en nombre variable
#                   <fixnum>  Il faut créer ce nombre précis de messages
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


def forum_tables
  @forum_tables ||= ['sujets', 'posts', 'follows', 'posts_content', 'posts_votes']
end
