
# scenodico_get_mot(<clause where ou ID>)
#
# Retourne les données du mot remonté par +where_clause+
#
# @return {Hash} data
#                 Retourne les données du mot.
#                 C'est un Hash beaucoup plus complet que l'enregistrement
#                 lui-même puisqu'il retourne :
#                 :data_relatifs => Hash contenant les données des relatifs,
#                                   avec en clé l'ID du mot et en valeur le
#                                   hash de ses données simples (db)
#                 :data_categories => Hash contenant les données des
#                                     catégories avec en clé l'id et en
#                                     valeur le hash des données db de la
#                                     catégorie.
#                 :categories_by_cate_id Hash avec en clé le cate_id et en
#                                     valeur l'hash de données.
# @param {String|Fixnum} where_clause
#                         Peut être l'ID du mot.
#                         Peut-être la condition where exprimée en string
#
def scenodico_get_mot where_clause
  defined?(site) || require_lib_site
  where_clause =
    case where_clause
    when Fixnum then "id = #{where_clause}"
    else where_clause
    end
    where_clause << " LIMIT 1"
  hmot = site.db.select(:biblio,'scenodico',where_clause).first

  # Récupération des données des relatifs
  # -------------------------------------
  allrels = hmot[:relatifs].as_id_list
  allrels += hmot[:synonymes].as_id_list
  allrels += hmot[:contraires].as_id_list
  allrels.uniq!
  hrels = Hash.new
  if allrels.count > 0
    site.db.select(:biblio,'scenodico',"id IN (#{allrels.join(',')})").each do |hmot|
      hrels.merge!(hmot[:id] => hmot)
    end
  end
  hmot.merge!(data_relatifs: hrels)

  # Récupération des données des catégories du mot
  # ----------------------------------------------
  # (en vérité, on prend simplement les données de toutes les catégories)
  hcats_by_cate_id = Hash.new
  hcats_by_ids = Hash.new
  site.db.select(:biblio,'categories').each do |hcat|
    hcats_by_cate_id.merge!(hcat[:cate_id] => hcat)
    hcats_by_ids.merge!(hcat[:id] => hcat)
  end
  hmot.merge!({
    categories_by_cate_id: hcats_by_cate_id,
    data_categories: hcats_by_ids
  })

  return hmot
end
