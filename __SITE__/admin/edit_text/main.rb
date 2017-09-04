# encoding: utf-8
=begin
  Édition d'un texte quelconque

  Syntaxe : créer un lien avec :
    "admin/edit_text?path=#{CGI.escape('le/path/vers/texte.ext')}"

=end

class EditedText

  attr_reader :path
  
  def initialize path
    @path = path
  end

  def save
    __notice "Je sauve le texte courant dans #{path}"
    if false == File.exist?(folder)
      return __error("Le dossier `#{folder}` n'existe pas. Je ne préfère pas créer une dossier de cette façon. Crée-le, puis enregistre à nouveau le fichier.")
    end
    # Le dossier existe, on peut enregistrer le fichier
    if code.nil?
      if File.exist?(path)
        File.unlink(path)
        __notice "Le code est vide, j'ai détruit le fichier."
      else
        __notice "Le code est vide. Rien a enregistrer, je n'ai pas créé le fichier."
      end
    else
      # TODO : Ici, il faudrait certainement faire des modifs dans le texte.
      File.open(path,'wb'){|f| f.write code}
      __notice "Code enregistré dans le fichier."
    end
  end
  def code
    @code ||= param(:file_code).nil_if_empty
  end
  def state
    if File.exist?(path)
      "<div class=\"green\">Le fichier `#{path}` est prêt à être édité.</div>"
    else
      "<div class=\"red\">Le fichier `#{path}` n’existe pas.</div>"
    end
  end
  def folder
    @folder ||= File.dirname(path)
  end
end 

# La méthode variable du texte édité
def texte
  @texte ||= EditedText.new(param(:path))
end
