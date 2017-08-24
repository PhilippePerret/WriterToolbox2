# encoding: UTF-8
class ::Array

  # Prend la liste {Array}, sépare toutes les valeurs par des virgules sauf
  # les deux dernières séparées par un "et"
  def pretty_join
    all   = self.dup
    return "" if all.count == 0
    return all.first.to_s if all.count == 1
    last  = all.pop.to_s
    all.join(', ') + " et " + last
  end

  def nil_if_empty
    self.empty? ? nil : self
  end
    
end #/Array
