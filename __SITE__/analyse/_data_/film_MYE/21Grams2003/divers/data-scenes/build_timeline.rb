# encoding: UTF-8
=begin

  Runner simplement ce module pour actualiser la
  timeline des scènes du fichier 21 Grams

  Noter qu'il faut peut-être lancer le module
  `data_scenes.rb` avant pour produire une version
  actualisée des données si le fichier `data_scenes.txt`
  a été modifié.

  CMD + I dans Atom
  CMD + R dans TextMate

=end

ROOT_MAC_PHIL = '/Users/philippeperret/Sites/WriterToolbox'

Dir.chdir(ROOT_MAC_PHIL) do
  folder_analyse = './data/analyse/film_MYE/21Grams2003'
  path_timeline_film = File.join(folder_analyse, 'timeline_scenes.htm')

  # On récupère le module de construction de la timeline des scènes
  Dir['./objet/analyse/lib/module/timeline_scenes/**/*.rb'].each{|m| require m}

  # On récupère le module qui va répondre à la méthode-propriété
  # `data_scenes` qui contient toutes les données des cènes
  require File.join(folder_analyse, 'divers', 'data-scenes', 'data_scenes.rb')

  # Construction de la timeline des scènes
  FilmAnalyse.build_timeline_scenes(
    data_scenes:  data_scenes,
    path:         path_timeline_film
    # On pourrait remplacer `path` par :
    # folder:     folder_analyse
  )
end
