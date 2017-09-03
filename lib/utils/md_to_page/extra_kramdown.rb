# encoding: UTF-8
=begin

Extension String pour le traitement des documents Markdown

    >> "CITATION" AUTEUR - SOURCE

=end
class MD2Page

  # Traitements supplémentaires pour les document Markdown
  #
  # Fonctionnement :
  # La méthode découpe en paragraphe et parse chacun d'eux
  # en testant son amorce qui définit toujours une possibilité
  # de traitement.
  def extra_kramdown
    @wcode.split("\n").collect do |line_init|
      line = line_init.strip
      case line
      when /^>>/          then kramdown_citations(line)
      when /^\[(.*?)\]$/  then kramdown_encart(line)
      else line_init
      end
    end.join("\n")
  end

  TEMPLATES_CITATIONS = {
    sans_source: "<div class='quote'><span class='content'>%{citation}</span><span class='ref'><span class='auteur'>%{auteur}</span></span></div>",
    avec_source: "<div class='quote'><span class='content'>%{citation}</span><span class='ref'><span class='auteur'>%{auteur}</span> - <span class='source'>%{source}</span></span></div>"
  }
  def kramdown_citations line
    matched = line.match(/>> ?"(.+?)" ?(.*?)(?: - (.*))?$/).to_a
    citation  = matched[1]
    auteur    = matched[2]
    source    = matched[3]
    key = source.nil? ? :sans_source : :avec_source
    template = TEMPLATES_CITATIONS[key]
    template % {citation: citation, auteur: auteur, source: source}
  end

  # Traitement des exergues
  REPLACEMENTS_PER_FORMAT = {
    br: "<br />"
  }
  def kramdown_encart line
    str = (line[1..-2] || '').strip # pour enlever les croches
    replacement = REPLACEMENTS_PER_FORMAT[:br]
    str.gsub!(/\\n/, replacement)
    "<div class=\"encart\">#{str}</div>"
  end

end
