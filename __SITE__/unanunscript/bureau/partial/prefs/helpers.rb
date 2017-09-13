# encoding: utf-8
class Site

  def menu_partage_projet params = nil
    Form.build_select({
      id: 'prefs_partage', name: 'prefs[partage]',
      values: Unan::SHARINGS, selected: params[:selected]
    })
  end
end #/Site
