# encoding: UTF-8

class TicketError < StandardError; end

class Ticket
class << self

  def exec tickets_id
    tickets_id.is_a?(String) && tickets_id = [tickets_id]
    tickets_id.is_a?(Array) || raise(ArgumentError.new('Ticket.exec attend un String ou une liste de String.'))
    tickets_id.each do |ticket_id|
      ticket = new(ticket_id)
      ticket.exists? || raise(TicketError.new("Le ticket '#{ticket_id}' a déjà été exécuté, désolé."))
      ticket.exec
    end
  rescue TicketError => e
    __error(e.message)
  end

end #/ << self
end #/ Ticket
