# encoding: utf-8
=begin
# Helper pour les méthodes de transformation des pages.
=end

class String

  # @syntax:    "texte".in_div([<hash attributes>])
  #
  def in_div attrs = nil
    self.buildtag('div',attrs)
  end
  def in_span attrs = nil
    self.buildtag('span',attrs)
  end
  def in_a attrs = nil
    self.buildtag('a',attrs)
  end
  def in_section attrs = nil
    self.buildtag('section',attrs)
  end


#private

  def as_intag attrs = nil
    attrs ||= Hash.new
    "<#{(self + SPACE + attrs.collect{|k,v|"#{k}=\""+v+'"'}.join(' ')).strip}>"
  end
  def buildtag tag, attrs
    tag.as_intag(attrs) + self + "</#{tag}>"
  end
end #/String
