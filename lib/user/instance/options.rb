# encoding: UTF-8
class User

  attr_reader :options

  # Utiliser cette méthode pour ne pas avoir à tester chaque fois
  # si c'est un user identifié ou non.
  def options
    @options ||=
      begin
        if identified?
          get(:options)
        else
          '0'*32
        end
      end
  end


  # @return {Fixnum} le grade, de 0 à 9, de l'user courant
  # On en a toujours besoin, même pour les tests
  def grade
    admin? && (return 9)
    options[1].to_i
  end

end
