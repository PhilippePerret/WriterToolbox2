# encoding: utf-8
class Aide
  class << self

    # Méthode principale pour sortir le code du fichier
    # d'aide
    #
    # @param {String} path
    #                 Path du fichier d'aide à afficher ou dossier dans
    #                 lequel trouver un fichier `main.md` à afficher ou
    #                 un fichier `tdm.md`
    def output path
      fullpath = File.join('.','__SITE__','aide','_data_',path)
      fullpath_md = "#{fullpath}.md"
      if File.exist? fullpath_md
        fullpath = fullpath_md
      elsif File.directory?(fullpath) && File.exist?(File.join(fullpath,'main.md'))
        fullpath = File.join(fullpath,'main.md')
      elsif File.directory?(fullpath) && File.exist?(File.join(fullpath,'tdm.md'))
        fullpath = File.join(fullpath,'tdm.md')
      else
        debug "path introuvable : #{fullpath}"
        return bulle("Malheureusement, le fichier d'aide demandé est introuvable…",'warning')
      end 
      # Si le fichier existe, on le formate et on l'affiche
      formate(File.read(fullpath), deserb: true)
    end

    # Le titre à donner à la page (et la balise HEAD/TITLE)
    # Pour le moment, c'est juste "Aide", mais ensuite, on récupèrera le titre
    # du fichier à afficher, en prenant le contenu de la première balise H
    def titre_page
      "Aide"
    end


  end #/self
end #/Aide
