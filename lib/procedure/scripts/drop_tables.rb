# encoding: UTF-8
=begin

  Cet script détruit les tables `variables_xxxx` des users qui n'existent
  plus.
  
=end

site.db.use_database(:users_tables)

tables = site.db.execute('SHOW TABLES;').collect do |hrep|
  hrep.values.first
end

tables_de_user_unknown = Array.new

debug "Nombre total tables : #{tables.count}"
tables.each do |table|
  rien, uid = table.split('_')
  uid = uid.to_i
  uid > 0 || next # on passe l'id 0 qui est celui du site lui-même.
  u = User.get(uid)
  u != nil && next
  tables_de_user_unknown << table
end

debug "Nombre mauvaises tables : #{tables_de_user_unknown.count}"
debug "Tables avec users inexistants : #{tables_de_user_unknown.inspect}"

site.db.use_database(:users_tables)
tables_de_user_unknown.each do |badtable|
  site.db.execute("DROP TABLE #{badtable};")
end
