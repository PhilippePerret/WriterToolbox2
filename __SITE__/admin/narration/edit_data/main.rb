# encoding: utf-8
class Narration
  class Page

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
    end

    def titre    ; @titre    ||= data[:titre]     end
    def livre_id ; @livre_id ||= data[:livre_id]  end
    def options  ; @options  ||= data[:options]   end

    def base_n_table ; @base_n_table ||= [:cnarration,'narration'] end
  end #/Page

end #/Narration


def page
  @page ||= Narration::Page.new(site.route.objet_id)
end
