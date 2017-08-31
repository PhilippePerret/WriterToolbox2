# encoding: UTF-8
=begin

  Toutes les méthodes utiles à l'affichage du coup de projecteur sur
  la page d'accueil.

=end
class Spotlight
  class << self

    # Retourne le code pour la section coup de projecteur de l'accueil,
    # ou '' s'il n'y en a pas.
    def section
      c = String.new
      data = Hash.new
      [:text_before, :route, :objet, :text_after].each do |prop|
        proplong = "spotlight_#{prop}"
        data.merge!(prop => site.get_var(proplong))
        data[prop] || next
        case prop
        when :route then next
        when :objet then c << "<div id=\"#{proplong}\"><a href=\"#{data[:route]}\">#{data[:objet]}</a></div>"
        else
          c << "<div id=\"#{proplong}\">#{data[prop]}</div>"
        end
      end
      c != '' || ( return '' )
      "<section id=\"home_spotlight\">#{c}</section>"
    end
  end #/ << self
end #/Spotlight
