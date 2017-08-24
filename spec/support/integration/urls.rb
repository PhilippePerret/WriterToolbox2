

def home_page
  "#{base_url}"
end

def profil_page
  "#{base_url}/user/profil"
end

def signin_page
  "#{base_url}/user/signin"
end

def signup_page
  "#{base_url}/user/signup"
end

def base_url
  url = offline? ? 'localhost/WriterToolbox2' : 'www.laboiteaoutilsdelauteur.fr'
  "http://#{url}"
end

def offline?
  true # pour le moment, toujours vrai
end
