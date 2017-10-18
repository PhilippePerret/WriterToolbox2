# encoding: utf-8
class User
  class << self

    # Retourne le pseudo de l'user dans les données sont +udata+
    # avec l'ID si +with_id+ est true, et la class CSS +classe+ appliquée au
    # lien si elle est définie.
    #
    # @param {Hash|User}  hu
    #                     Soit les données Hash de l'user,
    #                     Soit son instance User
    # @param {Bool|Nil}   with_id
    #                     Si TRUE, on ajoute l'ID au titre du lien
    # @param {String|Nil} classe
    #                     Optionnellement, la classe CSS du lien
    #
    def pseudo_linked hu, with_id = false, classe = nil
      upseu, uid = hu.is_a?(User) ? [hu.pseudo, hu.id] : [hu[:pseudo], hu[:id]]
      with_id && upseu << " (<span class=\"small\">#</span>#{uid})"
      simple_link("user/profil/#{uid}", upseu, classe)
    end

  end #/<< self
end #/User
