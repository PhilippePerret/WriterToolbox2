# encoding: UTF-8
=begin


NOTES
-----

  * Utiliser la méthode String#mef_document pour obtenir ce traitement
    Note : La méthode est implémentée ci-dessous.

    Syntaxe :
        site.require_module 'kramdown'
        code = code.mef_document(<:latex|:html>)

  * Le traitement doit se faire avant le traitement Kramdown proprement
    dit car les retours chariots sont traités réellement dans un environnement
    de document.

=end

# Classe MEFDocument
# Permet de mettre en forme une portion de document dans un texte
class MEFDocument

  # Le code entier
  attr_accessor :code

  # Le code en train d'être traité
  attr_accessor :codet

  # La légende éventuelle
  attr_accessor :legend

  # {Array} Les classes CSS (styles) après la balise DOC/
  # Note : Elles ne contiennent pas "document"
  attr_accessor :classes

  def initialize code = nil, csss = []
    set_code(code) unless code.nil?
    csss = csss.split(/[ \.]/) if csss.instance_of?(String)
    @classes = csss.unshift('document')
  end

  # Sortie retournée après traitement
  def output
    "\n#{traite_code}\n"
  end

  # Traitement du code, ligne après ligne.
  def traite_code
    @codet = code
    analyse_code
    @codet = send(:traite_code_as_html)
  end

  def traite_code_as_html
    return (@codet.in_pre(class:classes.join(' ')) + self.legend) if brut?
    # Si c'est un document de classe 'brut', on ne passe pas par là
    res =
      if events?
        @codet.traite_as_events_html
      elsif scenario?
        @codet.traite_as_script_per_format(:html)
      elsif procedure?
        @codet.traite_as_procedure_per_format(:html)
      else
        lines.collect{ |l| l.traite_as_line_of_document_per_format }.join('')
      end

    @codet = unless brut?
      res.traite_as_document_content_html
    else
      res
    end

    # Le code entièrement traité
    self.in_section + self.legend
  end
  def traite_code_as_latex
    envi = case true
    when events?    then 'docEvents'
    when scenario?  then 'docScenario'
    when synopsis?  then 'docSynopsis'
    else 'asDocument'
    end

    res = if events?
      lines.collect do |line|
        case line[0..1]
        when /^- / then line[2..-1].strip.in_command_latex('evt')
        else line.in_command_latex('par')
        end
      end.join('')
    elsif scenario?
      @codet.traite_as_script_per_format(:latex)
    else
      lines.collect{ |l| l.traite_as_line_of_document_per_format }.join('')
    end

    @codet = unless brut?
      res.traite_as_document_content_latex
    else
      res
    end

    # On retourne le document et sa légende s'il y en
    # a une.
    @codet.in_command_latex(envi) + legend
  end

  def in_section
    @grand_titre = (@grand_titre.nil? ? '' : @grand_titre.in_h1)
    (@grand_titre + @codet).in_section(class:classes.join(' ')).gsub(/\n/,'')
  end
  def legend
    return "" if @legend_content.nil? || @legend_content == ""
    @legend_content = @legend_content.traite_as_markdown_per_format
    @legend_content.in_div(class: 'document_legend')
  end

  # Première analyse du code, pour voir s'il a un grand titre
  # et une légende
  def analyse_code
    first_line = lines.first
    last_line = lines.last
    if first_line.start_with?('# ')
      @grand_titre = first_line[2..-1].strip
      lines.shift
    end
    if last_line.start_with?('/')
      @legend_content = last_line[1..-1].strip
      lines.pop
    end
    # On reconstitue le texte
    @codet = lines.join("\n")
    @lines = lines
  end

  def lines
    @lines ||= begin
      brut? ? @codet.split("\n") : @codet.strip.split("\n")
    end
  end

  def procedure?
    @is_procedure ||= classes.include?('procedure')
  end
  def scenario?
    @is_scenario ||= classes.include?('scenario')
  end
  def events?
    @is_events ||= classes.include?('events')
  end
  def brut?
    @is_pre ||= classes.include?('brut')
  end

  # Définition du code entier, on en profite pour
  # rationnaliser les retours à la ligne
  def set_code code
    @code = code.gsub(/\r\n?/,"\n").chomp
  end

end

class ::String

  ANTISLASH = "ltxLTXSLHxtl"
  CROCHETO  = "ltxLTXCROxtl "
  CROCHETF  = " ltxLTXCRFxtl"


  # = main =
  #
  # Méthode principale appelée pour mettre en forme des documents
  # dans les textes.
  #
  def mef_document str
    output_format = :html
    return str unless str.match(/\nDOC\//)
    str = str.gsub(/\r/,'')
    if ("#{str}\n").match(/\nDOC\/(.*?)\n(.*?)\/DOC\n/m)
    end
    str =
      ("#{str}\n").gsub(/\nDOC\/(.*?)\n(.*?)\/DOC\n/m){
        classes_css = $1.freeze
        doc_content = $2.freeze
        MEFDocument.new(doc_content, classes_css).output(output_format)
      }
    return str
  end

  # Pour traiter le contenu avec une sortie HTML
  def traite_as_document_content_html
    str = self
    str = str.gsub(/\n/, "<br />")
    return str
  end

  # Traite le string comme le contenu d'une procédure
  def traite_as_procedure_per_format output_format
    self.split("\n").collect do |line|
      line != '' || begin
        next '<div>&nbsp;</div>'
      end
      sline = line.split(':')
      css  = sline.shift.strip
      line = sline.join(':').strip
      next nil if line.nil?
      case output_format
      when :html
        line.traite_as_markdown_per_format.in_div(class:css)
      when :latex
        line.traite_as_markdown_per_format.in_command_latex("procedure#{css.camelize}")
      end
    end.compact.join('')
  end

  # Traite le string comme le contenu d'un scénario
  def traite_as_script_per_format output_format
    self.split("\n").collect do |line|
      css, line = case line
      when /^I[:\/]/i then
        ['intitule', line[2..-1].strip]
      when /^A[:\/]/i
        ['action', line[2..-1].strip]
      when /^(N|P)[:\/]/i
        ['personnage', line[2..-1].strip]
      when /^J[:\/]/i
        ['note_jeu', line[2..-1].strip]
      when /^D[:\/]/i
        ['dialogue', line[2..-1].strip]
      when /^T[:\/]/i
        ['traduction', line[2..-1].strip]
      when /\/(.*?)$/
        # Ne pas traiter la dernière ligne, qui peut être
        # une légende
        [nil, line]
      else
        [nil, line.traite_as_line_of_document_per_format]
      end
      next nil if line.nil?
      case output_format
      when :html
        line.traite_as_markdown_per_format.in_div(class:css)
      when :latex
        line.traite_as_markdown_per_format.in_command_latex("scenario#{css.camelize}")
      end
    end.compact.join('')
  end

  # Traite le string comme une liste d'évènements d'évènemencier
  # Chaque ligne doit commencer par "- "
  def traite_as_events_html
    str = self.split("\n")
    str.collect do |line|
      if line.start_with?("- ")
        ("-".in_span(class:'t') + line[2..-1].traite_as_markdown_per_format).in_div(class:'e')
      else
        line.traite_as_line_of_document_per_format
      end
    end.join("")
  end

  # Traitement de toutes les lignes de texte, même celles traitées
  # en particulier (ligne d'évènemencier, de scénario, etc.)
  #
  # On retire les balises p qui ont été insérées par kramdown pour ne
  # garder que le texte corrigé. C'est la méthode appelante elle-même
  # qui doit insérer le code dans un container.
  #
  # Note : La méthode tient compte du format de sortie voulu,
  # LaTex ou HTML.
  #
  def traite_as_markdown_per_format
    # self.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>').
    # gsub(/\*(.+?)\*/, '<em>\1</em>')
    res = ::Kramdown::Document.new(self.strip, {hard_wrap: false}).send("to_#{@output_format || 'html'}".to_sym)
    case @output_format
    when :latex
      res.strip.sub(/^\\par\{(.*?)\}$/,'\1')
    else
      res.strip.sub(/^<p>(.*?)<\/p>$/,'\1')
    end
  rescue Exception => e
    debug e
    if OFFLINE
      error "Impossible de traiter markdown per format : #{e.message}"
    end
    self
  end

  # Traitement d'une ligne comme la ligne d'un document quand elle
  # n'a pas pu être traitée autrement
  def traite_as_line_of_document_per_format
    case @output_format
    when :latex
      case self
      when /^(\#+) /
        tout, dieses, titre = self.match(/^(\#+) (.*?)$/).to_a
        "#{titre.traite_as_markdown_per_format},#{dieses.length}".in_command_latex('titredoc')
      when /^(  |\t)/
        # Ligne débutant par une tabulation ou un double espace
        # => C'est un retrait, un texte qu'il faut mettre à la
        #    marge.
        # On regarde la longueur du retrait. Rappel : ce retrait
        # peut se faire soit avec deux espaces soit avec une
        # tabulation.
        retrait = self.match(/^((?:  |\t)+)/).to_a[1].gsub(/  /,"\t").length
        "#{self.strip.traite_as_markdown_per_format}, #{retrait}".in_command_latex("retrait")
      when ''
        "#{ANTISLASH}medskip"
      else
        "#{self.traite_as_markdown_per_format}"
      end

    else

      # Tout autre format que :latex, donc :html
      case self
      when /^(#+) /
        tout, dieses, titre = self.match(/^(#+) (.*?)$/).to_a
        ht = "h#{dieses.length}"
        "<#{ht}>#{titre.traite_as_markdown_per_format}</#{ht}>"
      when /^(  |\t)/
        # Ligne débutant par une tabulation ou un double espace
        # => C'est un retrait, un texte qu'il faut mettre à la
        #    marge.
        # On regarde la longueur du retrait. Rappel : ce retrait
        # peut se faire soit avec deux espaces soit avec une
        # tabulation.
        retrait = self.match(/^((?:  |\t)+)/).to_a[1].gsub(/  /,"\t").length
        self.strip.traite_as_markdown_per_format.in_div(class:"p rtt#{retrait}")
      when ""
        "&nbsp;".in_div(class:'p')
      else
        self.traite_as_markdown_per_format
        # On met dans un paragraphe, mais seulement si le paraagraphe
        # n'est pas un titre
        # debug "Je passe ici avec #{self.inspect}"
        if self.match(/^<h[0-6]/) || self.match(/^<(p|div)/)
          self
        else
          self.in_div(class:'p')
        end
      end

    end # / :latex ou :html
  end

end #/String
