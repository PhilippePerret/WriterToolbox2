# encoding: utf-8
#
class MD2Page
  class << self


    # Traite le code @wcode qui contient des DOC/
    def traite_document_in_code str
      ("#{str}\n").gsub(/\nDOC\/(.*?)\n(.*?)\/DOC\n/m){
        classes_css = $1.freeze
        doc_content = $2.freeze
        MEFDocument.new(doc_content, classes_css).output
      }
    end

  end #/<< self
end #/MD2Page
