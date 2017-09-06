# encoding: utf-8
class Narration
  class Page

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
    end

    def titre       ; @titre        ||= data[:titre].gsub(/'/,'’')     end
    def livre_id    ; @livre_id     ||= data[:livre_id]     end
    def options     ; @options      ||= data[:options]      end
    def handler     ; @handler      ||= data[:handler]      end
    def description ; @description  ||= data[:description]  end

    # Propriétés volatiles
    def priority ; @priority  ||= options[3].to_i     end
    def nivdev   ; @nivdev    ||= options[1].to_i(11) end

    # Options
    def only_web?
      @is_only_web ||= options[2] == '1'
    end

    def base_n_table ; @base_n_table ||= [:cnarration,'narration'] end
  end #/Page

end #/Narration


def page
  @page ||= Narration::Page.new(site.route.objet_id)
end
