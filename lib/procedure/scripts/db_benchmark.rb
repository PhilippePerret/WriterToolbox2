# encoding: UTF-8
=begin

  Pour faire des tests de vitesse

=end


=begin

  Tester ce qui est le plus rapide entre une requête de type :

    SUBSTRING(t,x,y) = 'v' && SUBSTRING(t,x,y) = 'v' SUBSTRING(t,x,y) = 'v'

  Et une requête qui ferait :

    T LIKE '__v___v______v'

  (avec possibilité de ne prendre que la portion de T nécessaire)

=end

  where1 = [
    "SUBSTRING(specs,1,1) = '1'",
    "SUBSTRING(specs,4,1) = '1'",
    "SUBSTRING(specs,7,1) = '0'",
  ]
  where1 = where1.join(' AND ')

  where2 = "specs LIKE '1__1__0%'"

  where3 = "SUBSTRING(specs,1,7) LIKE '1__1__0'"

  pref_request = "SELECT * FROM films_analyses WHERE "

  requests = {
    1 => "#{pref_request}#{where1}",
    2 => "#{pref_request}#{where2}",
    3 => "#{pref_request}#{where3}"
  }

  (1..3).each do |version|
    debug "\n = Version : #{requests[version]} ="
    start = Time.now.to_f
    site.db.use_database(:biblio)
    100.times do |ifois|
      site.db.execute(requests[version])
    end
    laps = (Time.now.to_f - start).round(4)
    debug "Version #{version} : #{laps}"
  end
