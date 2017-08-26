# encoding: UTF-8

=begin rdoc

  Ce module contient les méthodes comme `set` qui permettent d'enregistrer
  des données dans la base de données (update).
  Pour les utiliser, il faut que la classe définisse :
    base_n_table
  … qui retourne [db_name, db_table_name]

=end
module PropsAndDbMethods

  def insert hdata
    site.db.insert(db_name, db_table, hdata)
    dispatch hdata
  end
  
  def set hdata
    site.db.update(db_name, db_table, hdata, {id: self.id})
    dispatch hdata
  end

  def get keys
    only_one_key = keys.is_a?(String) || keys.is_a?(Symbol)
    only_one_key && keys = [keys]
    knowns        = Hash.new
    unknown_keys  = Array.new
    keys.each do |key|
      if val = instance_variable_get("@#{key}")
        knowns.merge!(key => val)
      else
        unknown_keys << key
      end
    end
    unknown_keys.empty? || begin
      knowns.merge!(site.db.select(db_name, db_table, {id: self.id}, unknown_keys).first)
    end
    dispatch knowns
    only_one_key ? knowns.values.first : knowns
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
