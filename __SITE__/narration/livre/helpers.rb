# encoding: utf-8
#
# Helper pour l'affichage de la table des matières d'un livre
#
class Site

  def link_edit_tdm_if_admin
    user.admin? || (return '')
    "<a href=\"admin/narration/#{livre.id}?op=edit_tdm\">éditer</a>"
  end

end #/Site
