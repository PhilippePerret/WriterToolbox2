# encoding: utf-8
class PEditor
  class << self

    def editor
      deserb(File.join(thisfolder,'main.erb'))
    end

    def thisfolder
      @thisfolder ||= File.dirname(__FILE__)
    end
  end #/<< self
end #/PEditor
