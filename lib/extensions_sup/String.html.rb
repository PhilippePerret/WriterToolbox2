# encoding: utf-8
=begin
  Helper pour les méthodes de transformation des pages.

  Ce module peut être chargé par :
  require './lib/extensions_sup/String.html'

=end

class String

  # @syntax:    "texte".in_div([<hash attributes>])
  #
  def in_div      a = nil ; self.buildtag('div',a)      end
  def in_pre      a = nil ; self.buildtag('pre',a)      end
  def in_a        a = nil ; self.buildtag('a',a)        end
  def in_li       a = nil ; self.buildtag('li',a)       end
  def in_ul       a = nil ; self.buildtag('ul',a)       end
  def in_span     a = nil ; self.buildtag('span',a)     end
  def in_section  a = nil ; self.buildtag('section',a)  end

#private

  def as_intag attrs = nil
    attrs ||= Hash.new
    "<#{(self + SPACE + attrs.collect do |k,v|
      v != nil || next
      "#{k}=\""+v+'"'
    end.join(' ')).strip}>"
  end
  def buildtag tag, attrs
    tag.as_intag(attrs) + self + "</#{tag}>"
  end
end #/String
