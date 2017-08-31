# encoding: utf-8
#
# Gestion du formulaire d'enregistrement d'un nouveau coup de projecteur

class Spotlight
  class << self
    # Enregistrement du coup de projecteur
    def save
      dspotlight = param(:spotlight)
      [:text_before, :text_after, :objet, :route].each do |prop|
        site.set_var("spotlight_#{prop}", dspotlight[prop])
      end
      __notice('Nouveau coup de projecteur enregistré.')
    end
  end #/ << self
end #/Spotlight
