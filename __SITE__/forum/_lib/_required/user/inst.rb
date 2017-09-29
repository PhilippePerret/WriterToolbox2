# encoding: utf-8
#
# User
# Propriétés et méthodes pour le forum
#
# Celles-ci seront toujours chargées dans le forum
#
class User

  # @return {Fixnum} le grade, de 0 à 9, de l'user courant
  def grade
    admin? && (return 9)
    options[1].to_i
  end


end #/User
