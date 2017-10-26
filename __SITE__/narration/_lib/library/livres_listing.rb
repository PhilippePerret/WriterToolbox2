# encoding: utf-8
class Narration
  class << self

    def menu_livres options = nil
      c = String.new
      c << '<ul id="livres">'
      LIVRES.each do |bid, bdata|
        c << "<li><a href=\"narration/livre/#{bid}\">#{bdata[:hname]}</a></li>"
      end
      c << '</ul>'
      return c
    end

  end #/<< self
end #/Narration
