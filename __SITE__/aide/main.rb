# encoding: utf-8
class Aide
  class << self

    # Méthode principale pour sortir le code du fichier
    # d'aide
    #
    # @param {String} path
    #                 Path du fichier d'aide à afficher ou dossier dans
    #                 lequel trouver un fichier `main.md` à afficher
    def output path
      fullpath = File.join('.','__SITE__','aide','_data_',path)
      File.directory?(fullpath) && fullpath << "/main.md"
      File.exist?(fullpath) || (return bulle("Malheureusement, le fichier d'aide demandé est introuvable…",'warning'))
      # Sinon, si le fichier existe, on le formate et on l'affiche
      formate(File.read fullpath)
    end

    # Le titre à donner à la page (et la balise HEAD/TITLE)
    # Pour le moment, c'est juste "Aide", mais ensuite, on récupèrera le titre
    # du fichier à afficher, en prenant le contenu de la première balise H
    def titre_page
      "Aide"
    end


  end #/self
end #/Aide
