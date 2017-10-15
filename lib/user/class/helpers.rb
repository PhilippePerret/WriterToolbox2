# encoding: utf-8
class User
  class << self

    # Rtourne le pseudo de l'user dans les données sont +udata+
    # avec l'ID si +with_id+ est true, et la class CSS +classe+ appliquée au
    # lien si elle est définie.
    def pseudo_linked udata, with_id = false, classe = nil
      p = udata[:pseudo]
      with_id && p << " (<span class=\"small\">#</span>#{udata[:id]})"
      simple_link("user/profil/#{udata[:id]}", p, classe)
    end

  end #/<< self
end #/User
