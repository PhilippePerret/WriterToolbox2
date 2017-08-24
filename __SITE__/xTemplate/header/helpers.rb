# encoding: UTF-8
=begin

  Tous les helpers qui permettent de construire la page d'accueil

=end
class Site


    def titre_in_logo pour = nil # :home pour la page d'accueil
      pour ||= ''
      @titre_in_logo ||= begin
        "<h1 class=\"#{pour}\">" +
        "La " +
        "<a href=\"\" title=\"Retour à l’accueil\">Boite</a>" + # accueil
        " à " +
        "<a href=\"outils\" title=\"Liste des outils\">outils</a>" +
        " de l’" +
        "<a href=\"user/profil\" title=\"Votre profil\">auteur</a>" +
        '</h1>'
      end
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
