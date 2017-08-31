# encoding: UTF-8

class Site

  # Retourne le code HTML de la section pour s'abonner au site
  def section_suscribe
    c = String.new
    c << "<div><strong>Soutenez le site</strong> pour qu'il continue de vous proposer un contenu de qualité (pour #{site.configuration.tarif} €/an)</div>"
    c << "<center><a href=\"user/suscribe\">S’ABONNER</a></center>"
    "<section id=\"suscribe\">#{c}</section>"
  end

  def incipit
    c = String.new
    phil_linked = '<a href="site/phil" class="patronyme">philippe perret</a>'
    charte_linked = '<a href="site/charte">la Charte</a>'
    c << '<img src="./img/phil-medaillon.png" id="medaillon_phil" />'
    c << "<div>Conçu par #{phil_linked}, ce site est entièrement dévolu à l'élaboration des histoires (cf. #{charte_linked}).</div>"
    
    "<section id=\"incipit\">#{c}</section>"
  end
end
