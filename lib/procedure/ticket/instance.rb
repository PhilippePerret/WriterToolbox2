# encoding: UTF-8
class Ticket

  attr_reader :id

  def initialize id
    @id = id
  end

  # Méthode principale exécutant un ticket
  def exec
    debug "-> exec #{self.id} : #{data[:code]}"
    eval(data[:code])
  rescue Exception => e
    debug e
    raise e
  else
    # Si l'exécution s'est bien passé, on peut détruire le ticket
    remove
  end

  def exists?
    data != nil
  end

  def remove
    site.db.delete(:hot, 'tickets', {id: self.id})
  end
  
  def data
    @data ||= begin
      d = site.db.select(:hot, 'tickets', {id: self.id}).first
      debug "Data ticket : #{d.inspect}"
      d
    end
  end

end#/Ticket
