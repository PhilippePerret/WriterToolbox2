class Fixnum

  JOUR = 24*3600

  # Permet d'ajouter un "s" au mot lorsque +self+ est
  # supérieur à un. Par exemple, soit +h+ un nombre d'heures,
  # on peut écrire : "#{h} heure#{h.s}"
  def s; self > 1 ? 's' : '' end
  def x; self > 1 ? 'x' : '' end

  # Comparaison de bit à bit
  # 9.bitin(1) => true
  # 9.bitin(8) => true
  # 9.bitin(4) => false
  def bitin val
    val > 0 || (return false)
    self & val > 0
  end
  # 'notbcont' pour 'not bit contains'
  def bitout val
    val > 0 || (return false)
    self & val == 0
  end

  def minute ; self * 60 end
  alias :minutes :minute

  def heure ; self * 3600 end
  alias :heures :heure

  def jour ; self * JOUR end
  alias :jours :jour

  def semaine ; self.jours * 7 end
  alias :semaines :semaine

  def mois ; self.jours * 30 end

  def annee ; self.jours * 365 end
  alias :annees :annee

  def as_human_date format = '%d %m %Y - %H:%M'
    Time.at(self).strftime(format)
  end

  def ago
    laps = Time.now.to_i - self
    case
    when laps == 0 then return 'maintenant'
    when laps > 0  then p = 'il y a'
    when laps < 0
      p = 'dans'
      laps = - laps
    end

    a , r  = div_modulo(laps, 1.annee)
    m , r  = div_modulo(r, 1.mois)
    j , r  = div_modulo(r, 1.jour)
    h , r  = div_modulo(r, 1.heure)
    mn, sc = div_modulo(r, 1.minute)

    str = Array.new
    a  > 0 && str << "#{a} an#{a.s}"
    m  > 0 && str << "#{m} mois"
    laps < 1.annee && j  > 0 && str << "#{j} jour#{j.s}"
    laps < 1.mois  && h  > 0 && str << "#{h} heure#{h.s}"
    laps < 1.jour  && mn > 0 && str << "#{mn} minute#{mn.s}"
    laps < 3600    && sc > 0 && str << "#{sc} seconde#{sc.s}"

    l = str.pop
    str = str.count > 0 ? (str.join(', ')+' et ') : ''
    str += l
    return "#{p} #{str}"
  end
  # Pour "divise et module". Retourne le résultat de la division
  # entière de +valeur+ par +diviseur+ et le reste de l'opération.
  # cf. l'utilisation dans la méthode `ago`
  def div_modulo valeur, diviseur
    val = valeur / diviseur
    res = valeur - val*diviseur
    [val, res]
  end


end #/Fixnum
