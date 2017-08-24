# encoding: UTF-8
=begin

  Méthodes pour les tests concernant le site.

  configuration_site

    On peut obtenir toutes les configurations du site courant grâce à
    cette instance artificielle.
    Par exemple, `configuration_site.url_online` retournera l'adresse
    online du site.
    Noter qu'il est inutile d'ajouter les configurations qu'on ajoute
    progressivement puisqu'elles sont automatiquement gérées par la
    missing_method.

=end

class SiteConfigurationForTest
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
  def configure
    yield self
  end
end
def configuration_site
  @testconfiguration ||= begin
    def site ; SiteConfigurationForTest.new() end
    # Ci-dessus, on utilise 'site' parce que c'est ce qui est utilisé dans
    # le fichier _config/main.rb
    load './__SITE__/_config/main.rb'
    tconf = site
    # On recrée la méthode originale
    def site ; @site ||= Site.instance end
    tconf
  end
end
