# encoding: UTF-8
class Site

  def lien
    @lien ||= Lien.new
  end

  # Les liens communs utiles dans toutes les parties du site
  class Lien

    # Retourne un lien pour éditer le fichier +path+, mais seulement si
    # c'est un administrateur.
    # @param {Hash} options
    #               options[:titre] Le titre (sinon, "éditer")
    def edit_text path, options = nil
      user.admin? || (return '')
      options ||= Hash.new
      options.key?(:titre) || options.merge!(titre: "éditer")
      "<adminonly><a href=\"admin/edit_text?path=#{CGI.escape(path)}\">#{options[:titre]}</a><adminonly>"
    end

    def signup params = nil
      params = def_params(params, {titre: 'S’inscrire'})
      "<a href='user/signup' class=\"#{params[:class]}\">#{params[:titre]}</a>"
    end

    def signin params = nil
      params = def_params(params, {titre: 'S’identifier'})
      "<a href=\"user/signin\" class=\"#{params[:class]}\">#{params[:titre]}</a>"
    end

    def profil params = nil
      params = def_params(params,{titre: 'profil'})
      "<a href=\"user/profil\" class=\"#{params[:class]}\">#{params[:titre]}</a>"
    end

    def outils params = nil
      params = def_params(params,{titre: 'outils'})
      "<a href=\"outils\" class=\"#{params[:class]}\">#{params[:titre]}</a>"
    end

    def narration params = nil
      params = def_params(params, {titre: 'collection Narration'})
      "<a href=\"narration\" class=\"#{params[:class]}\">#{params[:titre]}</a>"
    end

    def def_params params, adjoint
      adjoint != nil || raise('Il faut au moins fournir le titre par défaut du lien.')
      params ||= Hash.new
      # Le titre peut avoir été fourni en seul argument
      params.is_a?(String) && params = {titre: params}
      adjoint.each do |k, v|
        params.key?(k) || params.merge!(k => v)
      end
      return params
    end
  end
end
