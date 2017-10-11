# encoding: utf-8
#
# Le module chargé seul pour fournir l'extrait de l'accueil
#
class Blog
  class << self

    # Retourne le code HTML pour l'extrait présenté sur la page
    # d'accueil.
    def home_extract
      c = String.new
      c << "<span id=\"extrait_article\">#{extrait} </span>"
      c << '<span>[lire la suite]</span>'
      c = "<a href=\"blog/lire/#{CURRENT_ARTICLE_ID}\">#{c}</a>"
      "<fieldset id=\"last_article\"><legend>Dernier article</legend>#{c}</fieldset>"
    end


    # Retourne les 300 premiers caractères environ de l'extrait, avec son titre
    # mis en gras
    # Note : ce sont les styles qui feront que les div et les p seront affichés en ligne
    def extrait
      @extrait ||=
        begin
          extract =
            if File.exist?(article_md_path)
              kramdown File.read(article_md_path)
            elsif File.exist?(article_erb_path)
              deserb article_erb_path
            else
              raise "Impossible de trouver l'article courant…"
            end
          extract = extract[0..270]
          rindex  = extract.rindex(' ')
          extract[0..rindex]
        end
    end
    def article_md_path
      @article_md_path ||= File.join(article_folder, "#{article_affixe}.md")
    end

    def article_erb_path
      @article_erb_path ||= File.join(article_folder, "#{article_affixe}.erb")
    end
    def article_affixe
      @article_affixe ||= "#{last_article_id.to_s.rjust(4,'0')}"
    end
    def last_article_id
      @last_article_id ||=
        begin
          require "#{blog_folder}/current_article" #=> CURRENT_ARTICLE_ID
          CURRENT_ARTICLE_ID
        end
    end
    def article_folder
      @article_folder ||= File.join(blog_folder, 'articles')
    end
    def blog_folder
      @blog_folder ||= File.dirname(File.dirname(File.dirname(__FILE__)))
    end
  end #/<< self
end #/Blog
