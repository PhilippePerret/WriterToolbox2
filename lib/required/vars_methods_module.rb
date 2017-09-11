# encoding: UTF-8
=begin

  Module contenant les méthodes utiles pour les variables (site et user)

  Si la classe appelant définit `table_vars_id`, c'est l'ID pris pour
  composer le nom de la table (utilise pour le site, qui n'a pas d'ID). Sinon,
  c'est l'ID de l'instance qui est pris, comme pour les utilisateurs

  Pour obtenir une variable :

    User#var[<nom var>]

  Pour définir une variable :

    User#var[<nom var>] = <valeur>

=end
require_relative 'props_and_db_methods'

module VarsMethodsModule

  def var
    @var ||= Vars.new(self)
  end
  def get_var name ; return var[name] end
  def set_var name, valeur ; var[name] = valeur end

  class Vars

    include PropsAndDbMethods

    VARIABLES_TYPES = [String, Fixnum, Bignum, Float, Hash, Array, NilClass, TrueClass, FalseClass]

    attr_reader :owner
    def initialize owner
      @owner = owner
    end

    def [] var_name
      get_var(var_name)
    end

    def []= var_name, var_value
      set_var(var_name, var_value)
    end


    def set_var var_name, var_value
      @counter_try ||= 1
      if count({name: var_name}) > 0
        update({value: var_string_value_of(var_value), type:var_type_of(var_value), __strict: true},{name: var_name})
      else
        insert({name: var_name, value: var_string_value_of(var_value), type:var_type_of(var_value), __strict: true})
      end
      @counter_try = 0
    rescue Mysql2::Error => e
      @counter_try = create_table_if_needed(e, @counter_try) && retry
    end

    # Retourne la valeur de la variable de nom +var_name+ dans la
    # table :users_tables.variables_<id>
    # Note : la variable est retournée dans son bon type, même si elle
    # est enregistrée en string.
    def get_var var_name
      @nombre_essais ||= 1
      res = select({name: var_name}).first
      @nombre_essais = 0
      return res.nil? ? nil : var_real_value_of(res[:value], res[:type])
    rescue Mysql2::Error => e
      @counter_try = create_table_if_needed(e, @counter_try) && retry
    end

    def var_type_of var_value
      VARIABLES_TYPES.index(var_value.class)
    end
    def var_string_value_of var_value
      case var_value
      when Array, Hash  then var_value.to_json
      when TrueClass  then 'true'
      when FalseClass then 'false'
      when NilClass   then 'nil'
      else
        var_value
      end
    end
    def var_real_value_of str_value, type
      case type
      when 0 then str_value.force_encoding('utf-8')
      when 1 then str_value.to_i
      when 2 then str_value.to_i
      when 3 then str_value.to_f
      when 4
        h = Hash.new # pour symboliser les clés du Hash
        JSON.parse(str_value).each do |k,v|
          h.merge!(k.to_sym => v)
        end
        h
      when 5 then JSON.parse(str_value)
      when 6 then nil
      when 7 then true
      when 8 then false
      end
    end

    def base_n_table ; @base_n_table ||= [dbname,dbtable] end

    def dbname ; :users_tables end
    def dbtable
      @dbtable ||= begin
        idinst =
          if owner.respond_to?(:table_vars_id)
            owner.table_vars_id
          else
            owner.id
          end
        "variables_#{idinst}"
      end
    end

    # Demande la création de la table si nécessaire
    def create_table_if_needed( err, counter )
      counter += 1
      counter < 5 || (return false)
      if err.message.match(/Table(.*)doesn't exist/)
        self.class.create_table_for(owner.id)
      end
      return counter
    end


    class << self
      def create_table_for id
        site.db.execute(code_creation_table(id))
      end
      # Code de création d'une nouvelle table
      def code_creation_table(id)
        "CREATE TABLE variables_#{id}"+
        " (id INT AUTO_INCREMENT, name VARCHAR(200), value BLOB, type INT(1), PRIMARY KEY (id));"
      end
    end
  end #/Vars
end
