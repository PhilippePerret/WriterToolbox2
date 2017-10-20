# encoding: utf-8
class Analyse
  class AFile
    class << self

    end #/<< self


  end #/FIle
end #/Analyse

def afile
  @afile ||= 
    site.route.objet_id.is_a?(Fixnum) ? Analyse::AFile.new(site.route.objet_id) : nil
end
