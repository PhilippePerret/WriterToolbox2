# encoding: utf-8
class Analyse
  class AFile


    # Enregistrement du texte du fichier

    def do_save
      
      # Ici, il faut faire certaines vérification pour voir si on peut
      # enregistrer ce texte, voir par exemple si le fichier a été 
      # modifié depuis le chargement.
      # TODO

      # Le contenu du fichier
      # est traité dans la méthode `contenu_version` ci-dessous.
      # On la prend ici pour ne pas avoir à générer d'erreur dans l'ouverture
      # du fichier.
      contenu = contenu_version

      # Le path du fichier final (peut-être différent si on doit garder
      # plusieurs versions du fichier initial).
      # Note : on pourrait garder systématiquement plusieurs versions lorsque
      # ce n'est pas le créateur du fichier.

      build_path_if_needed
      File.open(fpath_version,'wb'){ |f| f.write contenu }

    end

    def contenu_version
      c = param(:file)[:content].nil_if_empty
      c != nil || raise('Le contenu est vide, ce qui n’est pas autorisé.')

      # Quelques corrections obligées
      c = c.gsub(/\r/, '')

      # On ajoute en entête, si ça n'est pas déjà fait, les informations sur le
      # fichier, pour vérifications plus simples.
      
      return c
    end
    
    # Construction du dossier-path du fichier si nécessaire
    # (rappel : c'est le dossier où son conserver les versions du fichier)

    def build_path_if_needed
      `mkdir -p "#{fpath}"`
    end

  end #/AFile
end #/Analyse
