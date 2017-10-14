

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

def admin_page
  "#{base_url}/admin"
end

def narration_page
  "#{base_url}/narration"
end

def forum_page
  "#{base_url}/forum/home"
end

def base_url
  url = offline? ? 'localhost/WriterToolbox2' : 'www.laboiteaoutilsdelauteur.fr'
  "http://#{url}"
end

def offline?
  true # pour le moment, toujours vrai
end
