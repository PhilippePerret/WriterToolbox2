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

    def to_str
      if objet && method
        "#{objet}/#{method}"
      else
        'home'
      end
    end

    # ---------------------------------------------------------------------
    #   DÉFINITION DE L'URL
    # ---------------------------------------------------------------------

    def objet
      @objet ||= param(:__o)
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
      objet     || return
      File.exist?(solid_path) || return
      r = "#{objet}"
      method && r << "/#{method}"
      debug "Chargement de la route : #{r.inspect}"
      site.load_folder(r)
      @loaded = true
    end

    # ---------------------------------------------------------------------
    #   PATH
    # ---------------------------------------------------------------------
    def solid_path
      @solid_path ||= "./__SITE__/#{objet}/#{method}"
    end
    alias :relative_path :solid_path

  end

end
