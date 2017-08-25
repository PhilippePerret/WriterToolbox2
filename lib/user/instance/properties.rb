# encoding: UTF-8
class User

  attr_reader :id, :mail
  # attr_reader :options # dans options.rb

  def pseudo
    @pseudo ||= "Ernest"
  end
  def patronyme
    @patronyme ||= "Ernest Dupont"
  end

  # Modification des données dans la base de données
  def set hdata
    site.db.update(:hot, 'users', hdata, {id: self.id})
    dispatch hdata # on les modifie aussi dans l'instance courante
  end

  def dispatch hash_data
    hash_data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

end
