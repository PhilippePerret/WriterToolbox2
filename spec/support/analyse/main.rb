# @param {Hash} params
#               :access     :public, ou :inscrit ou :suscribed
#                           Pour définir le niveau d'accès des films à 
#                           prendre. Correspond à l'accès du visiteur.
def get_film_analyse params = nil
  defined?(Site) || require_lib_site
  params ||= Hash.new
  where_clause = Array.new

  specs_req =
    case params[:access]
    when :public    then '100'
    when :inscrit  then specs_req = '110'
    when :suscribed then specs_req = '111'
    else nil
    end
  specs_req && where_clause << "SUBSTRING(specs,1,3) = #{specs_req}"

  where_clause =
    if where_clause.count > 0
      "WHERE #{where_clause.join(' AND ')}"
    else '' end
  request = <<-SQL
  SELECT fa.*
    FROM films_analyses fa
    INNER JOIN filmodico f ON f.id = fa.id
    #{where_clause}
    LIMIT 1
  SQL
  site.db.use_database(:biblio)
  hfilm = site.db.execute(request).first
  expect(hfilm).not_to eq nil
  return hfilm
end
