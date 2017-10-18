# encoding: UTF-8
=begin

  @usage (n'importe où sur le site)

      require './data/analyse/film_MYE/21Grams2003/divers/data-scenes/data_scenes.rb'
      data_scenes => {Array de Hash} des scènes

  Module qui lit les données du fichier data_scenes.msh qui sont les
  données des scènes au format Marshal.

  C'est un Array contenant les Hash des données de chaque scène. Donc
  l'indice 0 de l'Array contient la première scène.
  Le Hash de chaque scène contient :

    :numero               {Fixnum}
        Le numéro de la scène dans le film
    :numero_chronologie   {Fixnum}
        Le numéro de la scène dans la chronologie reconstituée du film.
    :time                 {Fixnum}
        Le temps de la scène
    :duree                {Fixnum}
        La durée de la scène
    :resume               {String}
        Le résumé de la scène
    :notes                {String}
        Les notes sur cette scène.

=end
# Méthode qui redonne les données enregistrées dans le fichier
# marshal des données de scènes.
def data_scenes
  @data_scenes ||= begin
    Marshal.load(File.open(path_marshall_file,'rb'){|f| f.read})
  end
end
# puts data_scenes.collect{|h| h.inspect}.join("\n")

def h2s horloge
  h, m, s = horloge.split(':')
  s.to_i + m.to_i * 60 + h.to_i * 3600
end
# Méthode qui récupère les données de scène dans le fichier
# data_scenes.txt et en fait un fichier Marshal
def build_marshall_data

  if File.exist?(path_marshall_file)
    puts "Pour être sûr que vous voulez bien actualiser le fichier Marshal des scènes, il faut détruire le fichier #{path_marshall_file} et relancer ce script."
    return
  end
  c = File.open(path_text_file,'rb'){|f| f.read.force_encoding('utf-8')}
  scenes = []
  c.split("\n").each_with_index do |line, iline|
    line = line.strip
    num, numc, horloge, resume, notes = line.split('|').collect{|e| e.strip }
    num = num.to_i
    numc = numc.to_i
    time = h2s(horloge)
    # puts "#{horloge} : #{time}"
    if iline > 0
      scenes[iline - 1][:duree] = time - scenes[iline - 1][:time]
    end
    break if resume == "" # La fin
    scenes << {
      resume: resume, notes: notes,
      numero: num, numero_chronologie: numc,
      time: time,
      duree: nil
    }
  end
  puts scenes.join("\n")
  File.open(path_marshall_file, 'wb'){|f| f.write Marshal.dump(scenes) }
  puts "\n\nFichier Marshal des scènes actualisé. Vous pouvez maintenant reconstruire les timelines."
end

def path_marshall_file
  @path_marshall_file ||= File.join(this_folder, 'data_scenes.msh')
end
def path_text_file
  @path_text_file ||= File.join(this_folder, 'data_scenes.txt')
end
def this_folder
  @this_folder ||= File.dirname(__FILE__)
end

# Simplement décommenter cette ligne pour récupérer les données du
# fichier texte après modification.
# build_marshall_data
