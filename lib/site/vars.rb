# encoding: UTF-8
class Site
  VARIABLES_TYPES = [String, Fixnum, Bignum, Float, Hash, Array, NilClass, TrueClass, FalseClass]

  def set_var var_name, var_value
    if site.db.count(:users_tables,'variables_0', {name: var_name}) > 0
      # => Update
      site.db.update(:users_tables,'variables_0',{value: var_value}, {name: var_name})
    else
      # => Insert
      site.db.insert(:users_tables,'variables_0',{name: var_name, value: var_string_value_of(var_value), type:var_type_of(var_value)})
    end
  end

  # Retourne la valeur de la variable de nom +var_name+ dans la
  # table :users_tables.variables_0
  # Note : la variable est retournée dans son bon type, même si elle
  # est enregistrée en string.
  def get_var var_name
    res = db.select(:users_tables,'variables_0', {name: var_name}).first
    res.nil? ? nil : var_real_value_of(res[:value], res[:type])
  end




  def var_type_of var_value
    VARIABLES_TYPES.index(var_value.class)
  end
  def var_string_value_of var_value
    case var_value
    when Hash, Array then var_value.to_json
    when TrueClass  then 'true'
    when FalseClass then 'false'
    when NilClass   then 'nil'
    else
      var_value
    end
  end
  def var_real_value_of str_value, type
    case type
    when 0 then str_value
    when 1 then str_value.to_i
    when 2 then str_value.to_i
    when 3 then str_value.to_f
    when 4,5 then JSON.parse(str_value)
    when 6 then nil
    when 7 then true
    when 8 then false
    end
  end


end #/Site
