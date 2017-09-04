# encoding: utf-8
#
require 'kramdown'

class MD2Page
  class << self
    def transpile src_path, options = nil
      self.new.transpile(src_path, options)
    end
  end #/<< self

  attr_reader :src_path
  attr_reader :options

  def initialize
    # table dans laquel on va conserver les codes à ne replacer qu'à
    # la fin du traitement, pour ne pas les corriger.
    @table_final_code_replacements = Hash.new
  end

  # @param {String|Nil} src_path
  #         Path du fichier source.
  #         Si nil, le code doit être défini dans options[:code]
  #
  # @param {Hash} options
  #
  #   options[:code]          Le code à traiter, s'il n'a pas été défini
  #                           par src_path.
  #   options[:owner]         Possesseur du fichier (à voir)
  #   options[:img_folder]    Dossier des images
  #   options[:pre_code]      Le code à mettre avant
  #   options[:no_leading_p]  Si true, on retire les "<p>...</p>"
  #
  def transpile src_path, options = nil
    @src_path = src_path
    @options  = options || Hash.new

    # Si un fichier de destination est spécifié, on écrit le code final
    # dedans, sinon on le renvoie.
    if @options[:dest]
      File.open(dest_path,'wb') { |f| f.write(final_code) }
    else
      return final_code
    end
  end
  #/transpile

  # Ajouter un code à remplacer à la toute fin, pour ne pas le
  # corriger
  #
  def add_final_replacement code
    @icode_replacement ||= 0
    repid = "XXXCODEFINALREPLACEMENT#{@icode_replacement+=1}XXX"
    @table_final_code_replacements.merge!(repid => code)
    return repid
  end

  # Code initial préparé
  def init_code
    c = String.new
    c += options[:pre_code] || ''
    if src_path
      c += File.read(src_path).force_encoding('utf-8')
    else # sinon, le code doit être défini dans options[:code]
      c += options[:code]
    end
    c = c.gsub(/\r\n?/,"\n").chomp
    return c
  end


  # Code final transpilé
  def final_code
    @code_initial = init_code.freeze
    traite_code
    @wcode
  end


  # Traitement du code
  # ==================
  #
  # Méthode qui produit le code final, pour retour ou enregistrement
  # dans le fichier de destination.
  # 
  def traite_code
    @wcode = "#{@code_initial}"


    # On traite les balises ERB pour les escaper
    #
    # TODO mettre plutôt une méthode `escape_balises_erb`
    escape_balises_erb


    # On traite les DOC éventuels
    #
    @wcode.match(/\\nDOC\//) && traite_document_in_code


    # Traitement des balises propres
    #
    traite_balises_speciales

    # kramdownisation
    #
    koptions = {header_offset:0}
    @wcode = Kramdown::Document.new(@wcode,koptions).to_html

    # Suppression éventuelle des <p>...</p>
    #
    options[:no_leading_p] && @wcode.sub!(/^<p>(.*)<\/p>$/m,'\1')

    # On replace les codes à ne pas traiter qui ont peut-être
    # été mis de côté
    traite_final_replacements

  end
  #/traite_code


  def escape_balises_erb
    @wcode.gsub!(/(<%(.*?)%>)/m){
      add_final_replacement($1)
    }
  end

  # On replace les codes qui ont été mis de côté pour ne pas être
  # traités
  def traite_final_replacements 
    @table_final_code_replacements.each do |repid, code|
      @wcode.gsub!(/#{repid}/, code)
    end
  end


end #/MD2Page
