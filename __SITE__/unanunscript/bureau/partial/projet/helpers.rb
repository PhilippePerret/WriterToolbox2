# encoding: utf-8
class Site

  def menu_types_projet params = nil
    Form.build_select({
      id:'projet_type', name: 'projet[type]', 
      values: Unan::UUProjet::TYPES, selected: params[:selected]})
  end

end
