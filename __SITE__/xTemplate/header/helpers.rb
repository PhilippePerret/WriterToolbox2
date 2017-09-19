# encoding: UTF-8
=begin

  Tous les helpers qui permettent de construire la page d'accueil

=end
class Site

  def titre_in_logo pour = nil # :home pour la page d'accueil
    pour ||= ''
    @titre_in_logo ||= begin
      "<h1 class=\"#{pour}\">" +
      "la " +
      "<a href=\"\" title=\"Retour à l’accueil\">boite</a>" + # accueil
      " à " +
      "<a href=\"outils\" title=\"Liste des outils\">outils</a>" +
      " de l’" +
      "<a href=\"user/profil\" title=\"Votre profil\">auteur</a>" +
      '</h1>'
    end
  end

  def incipit
    c = String.new
    phil_linked = '<a href="site/phil" class="patronyme">philippe perret</a>'
    charte_linked = '<a href="site/charte">la Charte</a>'
    c << '<img src="./img/phil-medaillon.png" id="medaillon_phil" />'
    c << "<div>Site conçu et animé par #{phil_linked} dévolu corps et âmes à l'élaboration des histoires sous toutes leurs formes.</div>"

    "<section id=\"incipit\" class=\"light\">#{c}</section>"
  end

  def logo
    partial("#{thisfolder}/partial/logo")
  end

  def lien_signout params = nil
    params ||= Hash.new
    params[:titre] ||= "Se déconnecter"
    "<a href=\"user/signout\" class=\"link_signout\">#{params[:titre]}</a>"
  end


  def thisfolder
    @thisfolder ||= File.dirname(__FILE__)
  end

end #/Site
