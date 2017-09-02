# encoding: utf-8
class Narration
  class << self

    def menu_livres
      c = String.new
      c << '<ul id="livres">'
      LIVRES.each do |bid, bdata|
        c << "<li><a href=\"narration/livre/#{bid}\">#{bdata[:hname]}</a></li>"
      end
      c << '</ul>'
      return c
    end

    def lien_admin_if_admin
      user.admin? || (return '')
      '<span class="span_edit_link"><a href="admin/narration">administrer</a></span>'
    end
  end #/<< self
end #/Narration
