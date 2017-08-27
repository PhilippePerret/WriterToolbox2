# encoding: UTF-8
class Site

  def db
    @db ||= Database.new(self)
  end

  class Database
    attr_reader :site
    def initialize site
      @site = site
    end

    def use_database db_name
      client.query("use `#{db_bases_prefix}_#{db_name}`;")
    end
    alias :use_db :use_database

    # Méthode principale pour exécuter les requêtes
    #
    # Voir le manuel pour le détail de l'utilisation.
    #
    # @param {String|Array} requests
    #                       Requête ou liste de requêtes
    # @param {Array} values
    #                       Si défini, c'est une requête préparée.
    # @return {Array|Hash}
    #         La liste des résultats obtenus ou le résultat si une
    #         seule requête a été transmise.
    def execute requests, values = nil
      only_one_request = false == requests.is_a?(Array)
      only_one_request && begin
        if values.nil?
          requests = [requests]
        else
          requests = [[requests, values]]
        end
      end
      all_res = []
      requests.each do |request|
        if request.is_a?(Array)
          preparation, arr_of_arr_values = request
          # Préparation de la requête
          statement = client.prepare(preparation)
          arr_of_arr_values[0].is_a?(Array) || arr_of_arr_values = [arr_of_arr_values]
          all_res << [] # On va y mettre tous ces résultats
          arr_of_arr_values.each do |arr_values|
            res = statement.execute(*arr_values)
            res || next
            res.each { |row| all_res.last << row }
          end
        else
          all_res << [] # Un liste dans la liste, pour les résultats
          begin
            res = client.query(request, {symbolized_keys: true})
            res.each { |row| all_res.last << row } if res
          rescue Mysql2::Error => e
            raise Mysql2::Error.new("PROBLÈME AVEC LA REQUÊTE : `#{request}` : #{e.message}")
          rescue Exception => e
            raise Error.new("PROBLÈME AVEC LA REQUÊTE : `#{request}` : #{e.message}")
          end
        end
      end
      return only_one_request ? all_res[0] : all_res
    end
    alias :query :execute

    # Retourne le statement
    def prepare requete
      client.prepare(requete)
    end
    # Exécute le statement préparé avec les valeurs +values+ et
    # @return {Array} Le résultat
    def exec_statement statement, values
      res = statement.execute(*values)
      res ? res.map{|row|row} : nil
    end
    alias :execute_statement :exec_statement


    # Retourne le dernier identifiant employé pour la table
    # +db_table+ de la base de nom +db_name+ (non préfixé)
    # Noter que pour le moment, la table ne sert à rien, pour qu'il
    # semble que LAST_INSERT_ID fonctionne sans précision de table.
    def last_id_of db_name, db_table = nil
      use_database(db_name)
      client.query('SELECT LAST_INSERT_ID()').each do |row|
        return row.values.first
      end
    end

    # Raccourci pour insérer une valeur de façon simple
    # @param {String} db_name
    #                 Nom (suffixe) de la base de données. Par exemple ':hot'
    # @param {String} db_table
    #                 Table dans laquelle il faut insérer les données.
    # @param {Hash}   hdata
    #                 Les données à insérer.
    #
    # @return {Fixnum|Nil}
    #         Le LAST_INSERT_ID
    def insert db_name, db_table, hdata
      use_database( db_name )
      now = Time.now.to_i
      hdata[:created_at] || hdata.merge!(created_at: now)
      hdata[:updated_at] || hdata.merge!(updated_at: now)
      colonnes  = []
      values    = []
      interrs   = []
      hdata.each do |k,v|
        colonnes  << k.to_s
        values    << v
        interrs   << '?'
      end
      colonnes  = colonnes.join(',')
      interrs   = interrs.join(',')
      statement = client.prepare("INSERT INTO #{db_table} (#{colonnes}) VALUES (#{interrs})")
      res = statement.execute(*values)
      # res.map{|row|row} if res
      return last_id_of(db_name)
    end

    # Retourne des données
    def select db_name, db_table, where_clause = nil, colonnes = nil
      values = nil

      wclause =
        case where_clause
        when NilClass then nil
        when String   then where_clause
        when Hash
          values  = []
          wclause = []
          where_clause.each do |k, v|
            wclause << "#{k} = ?"
            values  << v
          end
          wclause.join(' AND ')
        else
          raise "La clause WHERE doit être définie par un Hash ou un String"
        end
      wclause && wclause = " WHERE #{wclause}"

      colonnes =
        case colonnes
        when String   then colonnes
        when Array    then colonnes.join(', ')
        when NilClass then '*'
        else
          raise "Les colonnes à retourner doivent être définies par un String ou un Array de String(s)."
        end

      request = "SELECT #{colonnes} FROM #{db_table}#{wclause};"
      use_database db_name
      if values
        statement = prepare(request)
        exec_statement(statement, values)
      else
        execute(request)
      end
    end

    # Actualise une donnée
    #
    def update db_name, db_table, hdata, where_clause
      use_database db_name
      hdata[:updated_at] || hdata.merge!(updated_at: Time.now.to_i)
      values    = []
      colsints  = []
      hdata.each do |k, v|
        colsints  << "#{k} = ?"
        values    << v
      end

      wclause, values = treat_where_clause(where_clause, values)

      colsints = colsints.join(', ')
      statement = client.prepare("UPDATE #{db_table} SET #{colsints}#{wclause}")
      res = statement.execute(*values)
      res.map{|row|row} if res
    end

    # @param {String|Hash} where_clause
    #                       Définition initiale de la clause WHERE
    # @return {Array} [where_clause, values]
    def treat_where_clause where_clause, values
      case where_clause
      when NilClass
        return ['', values]
      when String
        wclause = where_clause
      when Hash
        wclause = []
        where_clause.each do |k,v|
          wclause << "#{k} = ?"
          values  << v
        end
        wclause = wclause.join(' AND ')
      else
        raise "Il faut fournir soit un String soit un Hash comme clause WHERE…"
      end
      return [" WHERE #{wclause}", values]
    end

    def delete db_name, db_table, where_clause = nil
      wclause, values = treat_where_clause( where_clause, [] )
      request = "DELETE FROM #{db_table}#{wclause};"
      debug "Request : #{request}"
      use_database db_name
      if values.empty?
        client.query(request)
      else
        exec_statement( prepare(request), values )
      end
    end

    def count db_name, db_table, where_clause = nil
      wclause, values = treat_where_clause(where_clause, [])
      request = "SELECT COUNT(*) FROM #{db_table}#{wclause};"
      use_database db_name
      if values.empty?
        client.query(request)
      else
        exec_statement( prepare(request), values )
      end.first.values.first
    end

    def db_bases_prefix
      @db_bases_prefix ||= site.configuration.db_bases_prefix
    end

    def client
      @client ||= init_client
    end

    # Initialise le client MySql courant
    def init_client
      require 'mysql2'
      cl = Mysql2::Client.new(data_client)
      cl.query_options.merge!(:symbolize_keys => true)
      return cl
    end

    def data_client
      @data_client ||= begin
        require './__SITE__/_config/data/secret/mysql.rb'
        if site.offline?
          DATA_MYSQL[:offline]
        else
          DATA_MYSQL[:online]
        end
      end
    end

  end #/Database

end #/Site
