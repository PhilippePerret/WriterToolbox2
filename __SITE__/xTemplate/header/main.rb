class Site

  def titre_in_logo
    @titre_in_logo ||= begin
      "<h1><a href=\"\">#{head_titre}</a></h1>"
    end
  end

end
