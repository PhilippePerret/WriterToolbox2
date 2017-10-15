# encoding: utf-8
class User

  def analyste?
    @is_analyste.nil? && @is_analyste = identified? && (data[:options][16].to_i > 2)
    @is_analyste
  end

  # Retourne true si l'user a fait une demande de participation
  def postulant?
    @is_postulant.nil? && @is_postulant = identified? && (data[:options][16].to_i == 1)
    @is_postulant
  end
end #/User
