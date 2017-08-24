# encoding: UTF-8
class User

  # Instanciation de User
  # ---------------------
  # Si l'user est instancié avec des données, on les dispatche.
  # Voir le fichier `properties.rb` où elles sont décrites
  def initialize udata = nil
    udata && udata.each{|k,v|instance_variable_set("@#{k}",v)}
  end

end
