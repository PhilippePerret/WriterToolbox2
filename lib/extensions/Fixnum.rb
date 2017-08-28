class Fixnum

  JOUR = 24*3600

  def jour ; self * JOUR end
  alias :jours :jour

  def semaine ; self.jours * 7 end
  alias :semaines :semaine

  def mois ; self.jours * 30 end

  def annee ; self.jours * 365 end
  alias :annees :annee

end #/Fixnum
