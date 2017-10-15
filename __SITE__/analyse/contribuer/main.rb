# encoding: utf-8
class Analyse
  class << self

    # Retourne le texte d'invite en fonction du niveau de 
    # l'user, qui peut être :
    # - simple visiteur (non identifié)
    # - inscrit au site et identifié
    # - analyste
    def invite_by_niveau he
      
      case 
      when he.analyste? then 'Vous êtes analyste.' 
      when he.postulant? || param(:op) == 'candidater' 
        'Vous n’êtes pas encore analyste mais votre candidature est à l’étude. Merci de votre patience.'
      when he.identified?
        lien = simple_link("analyse/contribuer?op=candidater", 'soumettre une demande de participation', 'exergue')
        "Pour contribuer aux analyses, puisque vous êtes déjà inscrit#{he.f_e}, il vous suffit de #{lien}."
      else
        lien_signup = simple_link('user/signup', 'vous inscrire sur le site', 'exergue')
        "Pour contribuer aux analyses, vous devez au préalable #{lien_signup}."
      end
    end


  end #/<<self Analyse
end #/Analyse
