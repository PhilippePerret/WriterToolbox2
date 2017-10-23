# encoding: UTF-8
=begin

  Tous les helpers qui permettent de construire la page d'accueil

=end
class Site

  def titre_in_logo pour = nil # :home pour la page d'accueil
    @titre_in_logo ||= define_titre_in_logo(pour || '', :scenariopole) # sinon :boa ou :scenariopole
  end

  def define_titre_in_logo pour = nil, site
    case site
    when :scenariopole
      <<-HTML
      <h1 class="scenariopole #{pour}">
        <div class="scenariopole"><a href="" title="Retour à l’accueil">scenariopole</a></div>
        <div class="top_links"><a href="">accueil</a><a href="outils">outils</a><a href="user/profil">profil</a></div>
      </h1>
      HTML
    when :boa
      <<-HTML
      <h1 class="boa #{pour}">
        la
        <a href="" title="Retour à l’accueil">boite</a>
        à
        <a href="outils" title="Liste des outils">outils</a>
        de l’
        <a href="user/profil" title="Profils">auteur</a>
      </h1>
      HTML
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
