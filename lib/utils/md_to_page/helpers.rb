# encoding: utf-8
=begin
# Helper pour les méthodes de transformation des pages.
=end

class String

  def as_intag attrs = nil
    attrs ||= Hash.new
    "<#{(self + ' ' + attrs.collect{|k,v|"#{k}=\""+v+'"'}.join(' ')).strip}>"
  end


  # @syntax:    "texte".in_div([<hash attributes>])
  #
  def in_div attrs = nil
    'div'.as_intag(attrs) + self + '</div>'
  end

  def in_section attrs = nil
    'section'.as_intag(attrs) + self + '</section>'
  end


end #/String
