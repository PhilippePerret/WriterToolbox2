# encoding: UTF-8
class Form
class << self

  # Construit un select (menu) et le renvoie
  #
  # Note : pour pouvoir utiliser cette méthode, il faut requérir le
  # support de formulaire :
  #   require_form_support
  #
  # @param {Hash} attrs
  #       {
  #         id:     Identifiant du select
  #         name:   Name du select
  #         class:  Class CSS
  #         options: Liste des options [ [v1, lab1], [v2, lab2] ...]
  #         selected: Item sélectionné
  #       }
  def select_field attrs
    c = '<select'
    attrs[:id]    && c << " id=\"#{attrs[:id]}\""
    attrs[:name]  && c << " name=\"#{attrs[:name]}\""
    attrs[:class] && c << " class=\"#{attrs[:class]}\""
    attrs[:options] ||= attrs[:values]

    c << '>'
    if attrs[:options].is_a?(Array)
      c << attrs[:options].collect do |option|
        val, lab = option
        sel = val == attrs[:selected] ? ' selected="SELECTED"' : ''
        "<option value=\"#{val}\"#{sel}>#{lab}</option>"
      end.join('')
    elsif attrs[:options].is_a?(Hash)
      c << attrs[:options].collect do |val, dopt|
        sel = val == attrs[:selected] ? ' selected="SELECTED"' : ''
        "<option value=\"#{val}\"#{sel}>#{dopt[:hname]}</option>"
      end.join('')
    else
      raise "Les valeurs pour la construction d'un menu select doivent être une liste ou un Hash."
    end
    c << '</select>'
    if attrs[:id] && attrs.key?(:selected)
      c << "<script type=\"text/javascript\">document.getElementById('#{attrs[:id]}').value = '#{attrs[:selected]}';</script>"
    end
    return c
  end
  alias :build_select :select_field

  # Avant de procéder à l'opération sur le formulaire, il est bon d'envoyer
  # son FORMID à cette fonction pour savoir si le formulaire n'a pas déjà
  # été soumis
  def form_already_submitted? form_id
    site.db.use_database(:hot)
    res = site.db.execute("SELECT * FROM tickets WHERE id = ?", [form_id])
    if res.nil?
      true
    else
      debug "DELETE FORMID #{form_id}"
      site.db.execute('DELETE FROM tickets WHERE id = ?', [form_id])
      false
    end
  end


  # Retourne un identifiant unique pour le formulaire, en l'enregistrant
  # dans le dossier temporaire
  def unique_id
    uid = Time.now.to_i.to_s(36) + user.pseudo
    uid.length <= 32 || uid = uid[-32..-1]
    site.db.insert(:hot, 'tickets', {id: uid, code:'FORMID'})
    return uid
  end

end #/<<self
end #/Form
