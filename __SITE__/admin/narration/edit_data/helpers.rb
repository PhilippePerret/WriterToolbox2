# encoding: utf-8
class Site


  def menu_livres params = nil
    params ||= Hash.new
    require './__SITE__/narration/_lib/_required/constants'

    c = String.new
    c << "<select name=\"page[livre_id]\" id=\"page_livre_id\" class=\"medium\">"
    Narration::LIVRES.each do |bid, bdata|
      selected = bid == params[:selected] ? ' selected="SELECTED"' : ''
      c << "<option value=\"#{bid}\"#{selected}>#{bdata[:hname]}</option>"
    end
    c << '</select>'
    return c
  end

  def menu_type_page params = nil
    params ||= Hash.new
    c = String.new
    c << "<select name=\"page[type]\" id=\"page_type\" class=\"max-medium\">"
    [
      ['0', 'page'],
      ['1', 'sous-chapitre'],
      ['2', 'chapitre'],
      ['5', 'texte type']
    ].each do |val, tit|
      sel = val == params[:selected] ? 'selected="SELECTED"' : ''
      c << "<option value=\"#{val}\"#{sel}>#{tit}</option>"
    end
    c << '</select>'
    return c
  end
end #/Site
