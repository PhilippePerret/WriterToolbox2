# encoding: UTF-8

=begin rdoc
  
  Ce module contient les méthodes comme `set` qui permettent d'enregistrer
  des données dans la base de données (update).
  Pour les utiliser, il faut que la classe définisse :
    base_n_table
  … qui retourne [db_name, db_table_name]

=end
module PropsAndDbMethods

  def set hdata
    site.db.update(db_name, db_table, hdata, {id: self.id})
    dispatch hdata
  end

  def dispatch hdata
    hdata.each { |k, v| instance_variable_set("@#{k}", v) }
  end

  def db_name
    @db_name ||= base_n_table[0] || raise("Il faut absolument définir base_n_table pour utiliser les méthodes de DB")
  end

  def db_table
    @db_table ||= base_n_table[1]
  end


end #/PropsAndDbMethods
