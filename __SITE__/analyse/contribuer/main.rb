# encoding: utf-8
class Analyse
  class << self

  end #/<<self Analyse
end #/Analyse
class User

  # Retourne true si l'user a fait une demande de participation
  def postulant?
    @is_postulant.nil? && @is_postulant = identified? && (data[:options][16].to_i == 1)
    @is_postulant
  end

end
