# encoding: UTF-8
class Site

  # @return {String}
  #         Toutes les balises pour charger les feuilles de style propres
  #         à la section visitée.
  #         Ces feuilles de styles se trouve dans site@all_css.
  def stylesheet_links
    all_css.map do |css_file|
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{css_file}\">"
    end.join("\n")
  end

  def all_javascript_tags
    all_javascript.map do |js_file|
      "<script type=\"type/javascript\" src=\"#{js_file}\"></script>"
    end.join("\n")
  end

  def all_meta_tags
    all_meta.map do |meta_tag|
      "<meta #{meta_tag} />"
    end.join("\n")
  end

end
