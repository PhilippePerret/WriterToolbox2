# encoding: utf-8

class Blog
  class << self

    def article_erb_path
      @article_erb_path ||= File.join(folder,'articles',"#{article_affixe}.erb")
    end
    def article_md_path
      @article_md_path ||= File.join(folder,'articles',"#{article_affixe}.md")
    end
    def article_affixe
      @article_affixe ||= article_id.to_s.rjust(4,'0')
    end
    def article_id
      @article_id ||= site.route.objet_id || current_article_id
    end
    def current_article_id
      @current_article_id ||=
        begin
          require "#{folder}/current_article"
          CURRENT_ARTICLE_ID
        end
    end
    def folder
      @folder ||= File.join('.','__SITE__','blog')
    end
  end #/<< self
end #/Blog
