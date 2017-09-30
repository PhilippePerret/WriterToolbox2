# encoding: UTF-8
=begin

  Pour faire des tests sur les bases de données

=end
# 's' est la table sujets
# 'p' est la table posts
# 'u' est la table users

from = 0

RC = "\n"

req  = 'SELECT s.id AS sujet_id, s.last_post_id, s.creator_id, s.created_at' + RC
req << ', us.pseudo AS sujet_creator_pseudo' + RC
req << ', p.created_at AS post_date, p.user_id AS post_auteur_id'+ RC
req << ', up.pseudo AS post_auteur_pseudo'+ RC
req << ' FROM sujets s'+ RC
req << ' INNER JOIN posts p' + RC
req << '   ON s.last_post_id = p.id'
req << ' INNER JOIN `boite-a-outils_hot`.users us'+ RC
req << '   ON s.creator_id = us.id' + RC
req << ' INNER JOIN `boite-a-outils_hot`.users up' + RC
req << '   ON p.user_id = up.id' + RC
req << ' AND CAST(SUBSTRING(specs,6,1) AS UNSIGNED) >= 4'+ RC
req << ' ORDER BY s.updated_at DESC'+ RC
req << " LIMIT #{from}, 20;"

site.db.use_database(:forum)
res = site.db.execute(req)

res.each do |hsujet|
  debug "\nhsujet : #{hsujet.inspect}"
end
