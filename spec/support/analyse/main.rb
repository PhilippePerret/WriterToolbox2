# @param {Hash} params
#               :access     :public, ou :inscrit ou :suscribed
#                           Pour définir le niveau d'accès des films à
#                           prendre. Correspond à l'accès du visiteur.
#               :all        Si true, retourne tous les films correspondants
#                           à la rechercher
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
  SELECT fa.*, fa.realisateur AS director,
    f.*
    FROM films_analyses fa
    INNER JOIN filmodico f ON f.id = fa.id
    #{where_clause}
  SQL
  unless params[:all]
    request << ' LIMIT 1'
  end
  site.db.use_database(:biblio)
  if params[:all]
    return site.db.execute(request)
  else
    # Un seul film
    hfilm = site.db.execute(request).first
    expect(hfilm).not_to eq nil
    return hfilm
  end
end

def get_films_analyse params = nil
  get_film_analyse params.merge(all: true)
end
