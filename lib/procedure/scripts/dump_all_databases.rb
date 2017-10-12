# encoding: UTF-8
=begin
  L'idée de ce script est de faire un dump de toutes les bases de données de
  la boite à outils
=end
__notice('Pour le moment, passer par un test pour sauvegarder tout.')
#
#
# # return {Hash} Les données de connextion à MySQl en local
# def db_data_offline
#   @db_data_offline ||= begin
#     require './__SITE__/_config/data/secret/mysql.rb'
#     DATA_MYSQL[:offline]
#   end
# end
#
#
# dest_file_name = "all_dbs-#{Time.now.strftime('%Y_%m_%d-%H_%M')}.sql"
# backup_folder  = `echo ~/xbackups/auto`.strip
# dest_file_path = File.join(backup_folder, dest_file_name)
# debug "dest_file_path : #{dest_file_path}"
#
# # Construire le dossier backup au cas où
# `mkdir -p "#{backup_folder}"`
#
# dbs = Array.new
# site.db.execute('SHOW DATABASES;').each do |row|
#   row[:Database].start_with?('boite-a-outils') || next
#   dbs << row[:Database]
# end
#
# debug "Bases : #{dbs.inspect}"
#
# # command = "cd ~/xbackups/auto;mysqldump -u root -p#{db_data_offline[:password]} --databases #{dbs.join(' ')} > #{dest_file_name}"
# command = "cd ~/xbackups/auto;mysqldump -u root --databases #{dbs.join(' ')} > #{dest_file_name}"
# # command = "mysqldump -u root -p#{db_data_offline[:password]} --databases #{dbs.join(' ')} > #{dest_file_path}"
# # `#{command}`
# # debug "COMMAND SQL : #{command}"
#
#
# debug "\n\nCOMMANDE SQL À COPIER-COLLER DANS LE TERMINAL :\n#{command}"
# __notice "Pour des mesures de sécurité, l'opération ne fonctionne pas toute seule, donc copie-colle le code du débug (COMMAND SLQ À COPIER-COLLER) dans une fenêtre de Terminal."
# # L'explication vient peut-être du fait que c'est le "web" qui lance cette
# # opération, et que si elle était possible, ça serait possible partout chez
# # les utilisateurs.
# # Alors que pour les tests, on passe par le local.
