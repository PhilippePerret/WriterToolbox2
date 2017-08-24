class Site

  def titre_in_logo pour = nil # :home pour la page d'accueil
    pour ||= ''
    @titre_in_logo ||= begin
      "<h1 class=\"#{pour}\"><a href=\"\">#{head_titre}</a></h1>"
    end
  end

end
