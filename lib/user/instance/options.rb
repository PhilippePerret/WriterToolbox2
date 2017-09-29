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
end
