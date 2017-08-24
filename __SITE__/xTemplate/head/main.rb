# encoding: UTF-8
class Site

  # @return {String}
  #         Toutes les balises pour charger les feuilles de style propres
  #         à la section visitée.
  #         Ces feuilles de styles se trouve dans site@all_css.
  def local_links_stylesheet
    all_css.collect do |css_file|
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{css_file}\">"
    end.join("\n")
  end

end
