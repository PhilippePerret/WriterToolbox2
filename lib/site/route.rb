# encoding: UTF-8
=begin

  MINISTÈRE DE LA ROUTE

=end
class Site


  # Instance de la route
  def route
    @route ||= Route.new(self)
  end

  # Charge tout ce qui se trouve à la route voulue
  def load_route ; route.load end

  class Route

    attr_reader :site
    def initialize site
      @site ||= site
    end

    # ---------------------------------------------------------------------
    #   DÉFINITION DE L'URL
    # ---------------------------------------------------------------------

    def objet
      @objet ||= param(:__o) || 'home'
    end
    def method
      @method ||= param(:__m).nil_if_empty
    end
    def objet_id
      @objet_id ||= param(:__i).nil_if_empty
    end

    # ---------------------------------------------------------------------
    #   CHARGEMENT DE LA ROUTE DEMANDÉE
    # ---------------------------------------------------------------------
    def load
      !@loaded  || return
      File.exist?(solid_path) || return
      debug "Chargement de la route : #{short_route}"
      site.load_folder(short_route)
      @loaded = true
    end

    # ---------------------------------------------------------------------
    #   PATH
    # ---------------------------------------------------------------------

    # Par exemple 'user/profil' ou 'home'
    def short_route
      @short_route ||= begin
        sr = objet
        method && sr << "/#{method}"
        sr
      end
    end
    alias :to_str :short_route

    def solid_path
      @solid_path ||= "./__SITE__/#{short_route}"
    end
    alias :relative_path :solid_path

  end

end
