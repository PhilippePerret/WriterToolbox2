# encoding: utf-8
#
class Site

  # Retourne le code pour les liens vers les pages précédentes (if any) 
  # ou suivantes (if any) des articles de blog
  def liens_next_previous_pages where
    "<div class=\"liens_next_previous_pages #{where}\">"+
    lien_previous_article +
    "<span id='article_id'>Article ##{Blog.article_id}</span>" +
    lien_next_article +
    '</div>'
  end

  def lien_previous_article
    @lien_previous_article ||=
      begin
        if Blog.article_id > 1
          link = "<a href=\"blog/lire/#{Blog.article_id - 1}\">←</a>"
          "<span class=\"lien_prev_page\">#{link}</span>"
        else
          ''
        end
      end
  end
  def lien_next_article
    @lien_next_article ||=
      begin
        if Blog.article_id < Blog.current_article_id
          link = "<a href=\"blog/lire/#{Blog.article_id + 1}\">→</a>"
          "<span class=\"lien_next_page\">#{link}</span>"
        else
          ''
        end
      end
  end

  def lien_edit_if_admin
    user.admin? || (return '')
    "<span class=\"span_edit_link\"><a href=\"admin/blog/#{Blog.article_id}?op=edit\">éditer l’article</a></span>"
  end
end #/Site
