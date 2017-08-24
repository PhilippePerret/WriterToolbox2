# encoding: UTF-8
=begin

  Module de débug
  ---------------

  Noter que ce module est chargé en tout premier, quel que soit l'url
  online/offline et l'utilisateur. La seule différence sera l'affichage
  ou non du debug.

=end
class Debug
class << self

  def debug ca
    @_lines ||= []
    if ca.respond_to?(:message)
      # => C'est une erreur
      ca = ca.backtrace.unshift(ca.message).join("\n")
    end
    if ca.is_a?(Array)
      ca.each { |line| write line }
      @_lines += ca
    else
      write(ca)
      @_lines << ca
    end
  end

  def write line
    fref.write("[#{Time.now.strftime('%Y-%m-%d %H:%M')}] --- #{line}\n")
  end

  def output
    # debug "-> Debug::output"
    if @_lines
      @_lines.join("\n")
    else
      ''
    end
  end

  def fref
    @fref ||= begin
      fr = File.open('./xtmp/debug.log', 'a')
      fr.write("\n\n=== DEBUG DU #{Time.now.strftime('%d %m %Y - %H:%M')} ===\n")
      fr
    end
  end

end # << self
end # Debug
