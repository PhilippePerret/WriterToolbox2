=begin

  Affiche les mails dans le dossier des mails
  Utile pour les tests

=end
FILTRE = {
  to: nil,          # seulement les mails envoyés à cette adresse
  from: nil,        # seulement les mails de cet expéditeur
  sent_after: nil,  # seulement envoyé après ce temps (strict)
  sent_before: nil  # seulement envoyé avant ce temps (strict)
}

OPTIONS = {
  no_message:     true,  # Mettre à true pour ne pas afficher le message
  only_message:   false   # Mettre à true pour n'afficher QUE le message
}

# /ne rien toucher sous cette ligne
# ---------------------------------------------------------------------

DOSSIER_MAILS = File.join('.','xtmp','mails')
all_mails = Dir["#{DOSSIER_MAILS}/*.msh"]
if File.exists?(DOSSIER_MAILS)
  if all_mails.count > 0
    nombre_mails_found = 0
    all_mails.each do |mpath|
      puts "\n----------- MESSAGE -------------"
      mdata = Marshal.load(File.read(mpath))
      # S'il faut appliquer un filtre
      if FILTRE
        FILTRE[:from] && mdata[:from] != FILTRE[:from]  && next
        FILTRE[:to]   && mdata[:to]   != FILTRE[:to]    && next
        FILTRE[:sent_after]   && mdata[:sended_at] < FILTRE[:sent_after]
        FILTRE[:sent_before]  && mdata[:sended_at] > FILTRE[:sent_before]
      end
      # Sinon, on affiche le message
      mdata.each do |k,v|
        OPTIONS[:no_message]    && k == :message && next
        OPTIONS[:only_message]  && k != :message && next
        puts "#{k} => #{v}"
      end
      puts "----------- /MESSAGE ----------\n"
      nombre_mails_found += 1
    end


    if nombre_mails_found == 0
      puts "Aucun mail n'a été trouvé correspondant à la recherche."
    end
  else
    puts "Aucun mail dans le dossier"
  end
else
  puts "Aucun dossier mails, donc pas de mails à afficher"
end
