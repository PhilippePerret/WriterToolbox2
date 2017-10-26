# encoding: UTF-8

class Site
  include Singleton

  # Cf. Manuel > Vue > Titre.md
  def titre_page titre = nil, o = nil 
    if titre
      o ||= Hash.new
      o[:id]    && o[:id]    = " id=\"#{o[:id]}\""
      o[:class] && o[:class] = " class=\"#{o[:class]}\""
      # Pour le TITRE de la page HTML
      @titre_page = titre.gsub(/<.*?>/,'') + ( o[:subtitle] ? " - #{o[:subtitle]}" : '' )
      # Texte renvoyé pour la page qui appelle
      "<h2#{o[:id]}#{o[:class]}>#{titre}#{under_buttons_of_titre_page(o[:under_buttons])}</h2>"
    else
      # Pour la balise TITLE
      # Note : l'espace est NORMALE
      " #{@titre_page}" || ''
    end
  end

  def under_buttons_of_titre_page(arr_buttons)
    arr_buttons != nil || (return '')
    arr_buttons.is_a?(String) || arr_buttons = arr_buttons.join('')
    "<div class=\"under-buttons\">#{arr_buttons}</div>"
  end

  # Sortie de la page complète (envoi au navigateur)
  def output

    # S'il faut surveiller les fichiers SASS, on actualise
    # le fichier all.css si nécessaire.
    configuration.watch_sass && offline? && sass_all

    # On charge ce qui se trouve sur la route, c'est-à-dire les
    # fichier par défaut.
    load_route

    preload

    # On mémorise cette dernière page comme :last_page
    self.session['last_page'] = self.full_route
    # debug "session[last_page] mis à #{site.session['last_page']}"

    cgi.out{
      cgi.html{
        cgi.head{head} +
        cgi.body{
          body +
          all_javascripts_tags
        }
      }
    }
    # -- Rien ne peut passer ici --
  end

  # Pour que tout soit chargé avant de l'inscrire
  def preload
    begin
      body
    rescue Exception => e
      debug e.message.gsub(/</,'&lt;')
      debug e.backtrace.join("\n")
      @body = '<pre>' + Debug.output + '</pre>'
    end
    lmargin
    rmargin
    footer
    header
    head
  end

  def head_titre
    @head_titre ||=
      (site.configuration.title || site.configuration.titre) + titre_page
  end

  # ---------------------------------------------------------------------
  #     PARTIES DE LA PAGE
  # ---------------------------------------------------------------------
  def body          ; @body     ||= load_main(route.to_str)         end
  def head          ; @head     ||= load_template('head')           end
  def header(v=nil) ; @header   ||= load_template('header',v)       end
  def footer(v=nil) ; @footer   ||= load_template('footer',v)       end
  def lmargin(v=nil); @lmargin  ||= load_template('lmargin',v)      end
  def rmargin(v=nil); @rmargin  ||= load_template('rmargin',v)      end

  alias :left_margin  :lmargin
  alias :right_margin :rmargin

  # Méthode d'helper affichant les messages flash et début sous le
  # pied de page en général.
  def sections_messages
    flash.output +
    section_debug
  end

  def section_debug
    @secdebug ||= begin
      offline? ? load_template('section_debug') : ''
      # NOTE Pour le moment, en online, les messages de debug ne
      # sont pas affichés. Il faudrait absolument les écrire dans un
      # fichier.
    end
  end


  # ---------------------------------------------------------------------
  #     ÉLÉMENTS FONCTIONNELS
  # ---------------------------------------------------------------------
  def cgi ; @cgi ||= CGI.new('html4') end
  def bind; binding() end

end
