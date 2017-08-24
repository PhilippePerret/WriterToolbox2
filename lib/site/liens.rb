# encoding: UTF-8
class Site

  def lien
    @lien ||= Lien.new
  end

  # Les liens communs utiles dans toutes les parties du site
  class Lien

    def signup params = nil
      params ||= {}
      "<a href='user/signup' class=\"#{params[:class]}>#{params[:label] || 'S’inscrire'}</a>"
    end

    def signin params = nil
      params ||= Hash.new
      params[:titre] ||= 'S’identifier'
      "<a href=\"user/signin\" class=\"#{params[:class]}\">#{params[:titre]}</a>"
    end
  end
end
