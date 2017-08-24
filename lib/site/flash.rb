# encoding: UTF-8
class Site

  def flash
    @flash ||= Flash.instance
  end


  class Flash

    include Singleton

    def output
      !all_messages.empty? || ( return '' )
      c = '<div id="flash">'
      c << messages.join('')
      c << '</div>'
      return c
    end

    # Retourne tous les messages qui peuvent être affichés, ceux du chargement
    # courant ainsi que celui enregistré en session dans la propriété 'flash'
    def all_messages
      if site.session['flash']
        sess_mess, typmess = JSON.parse(site.session['flash'])
        self.send(typmess=='error' ? :error : :notice, sess_mess)
        site.session['flash'] = nil
      end
      return messages
    end

    # Les messages qui ont pu être définis dans le chargement courant
    # de la page (donc, hors message retenus en session)
    def messages
      @messages ||= []
    end

    def notice message, options = nil
      messages << "<div class=\"notice\">#{message}</div>"
    end

    def error message, options = nil
      if message.is_a?(String)
        # <= Un simple message
        # => On l'enregistre tel quel
      elsif message.respond_to?(:message)
        # <= Une erreur
        # => On écrit le message et on envoie le backtrace en debug
        debug message
        message = message.message
      elsif message.is_a?(Array)
        # <= Une liste de messages d'erreurs
        # => On les envoie chacun à cette méthode
        message.each { |mes| error mes }
        return
      end
      messages << "<div class=\"error\">#{message}</div>"
      return false
    end

  end #/Flash
end
