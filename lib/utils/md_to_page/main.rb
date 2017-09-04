# encoding: utf-8
#
require 'kramdown'

class MD2Page
  class << self

    attr_reader :src_path
    attr_reader :options

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

      # On replace les balises erb pour produire le code dynamique
      unescape_balises_erb
      
    end
    #/traite_code
    
    
    def escape_balises_erb
      @wcode.gsub!(/<%/, 'ERBtag')
      @wcode.gsub!(/%>/, 'gatBRE')
    end
    def unescape_balises_erb
      @wcode.gsub!(/ERBtag/,'<%')
      @wcode.gsub!(/gatBRE/,'%>')
    end



  end #/<< self
end #/MD2Page
