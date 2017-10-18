# encoding: UTF-8

def remove_tickets
  site.db.use_database(:hot)
  site.db.execute('TRUNCATE TABLE tickets')
end

# Retourne le nombre de tickets
def tickets_count
  site.db.count(:hot,'tickets')
end

# Retourne le tout dernier ticket
def last_ticket
  site.db.select(:hot,'tickets',"1 = 1 ORDER BY created_at DESC LIMIT 1").first
end
