class Site

  class Configuration

    # Note : toutes ces données sont expliquées dans __SITE__/_config/main.rb

    def method_missing method, *args, &block
      if method.to_s.end_with?('=')
        method = method[0..-2]
        self.class.instance_eval do
          define_method "#{method}" do
            return args.first
          end
        end
      end
    end


    def initialize s
      @site = s
    end
  end


  def load_configuration
    require './__SITE__/_config/main.rb'
  end
  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new(self)
  end

end
