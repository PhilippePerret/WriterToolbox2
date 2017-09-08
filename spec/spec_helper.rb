
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'selenium-webdriver'
require 'capybara/rspec'
Capybara.javascript_driver  = :selenium
Capybara.default_driver     = :selenium


# Pour les tests avec have_tag etc.
require 'rspec-html-matchers'


def require_folder folder
  Dir["#{folder}/**/*.rb"].each{ |m| require m }
end


# = On requiert les éléments de l'application utiles =
# Les extensions de classe
require_folder './lib/extensions'

# On requiert le minimum de chose du support
require_folder './spec/support/_required'


RSpec.configure do |config|


  # ---------------------------------------------------------------------
  #   Pour requérir les supports en fonction des tests
  # ---------------------------------------------------------------------

  # Pour charger toutes les librairies chargées par défaut dans le site
  def require_lib_site
    require './lib/_required'
  end

  def require_lib_uaus
    require_folder './__SITE__/unanunscript/_lib/_required' # => class Unan
  end

  def require_support_integration
    require_folder './spec/support/integration'
  end

  def require_support_db_for_test
    require_folder './spec/support/db'
  end

  def require_support_mails_for_test
    require_folder './spec/support/mails'
  end
  alias :require_support_mail_for_test :require_support_mails_for_test

  def require_support_paiements
    require_folder './spec/support/paiements'
  end

  def require_support_narration
    require_folder './spec/support/narration'
  end

  def require_support_scenodico
    require_folder './spec/support/scenodico'
  end

  # Pour les tests have_tag etc.
  config.include RSpecHtmlMatchers

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups


  config.before :suite do

    # *** Au lancement des scripts de test on… ***

    # … vide le dossier des screenshots
    empty_screenshot_folder

  end

  config.after :suite do
    destroy_files_to_destroy

    # retreive_data_narration
  end

  # ---------------------------------------------------------------------
  #   Méthodes utiles
  # ---------------------------------------------------------------------

  # Permet d'ajouter des fichiers à détruire en fin de test, s'ils
  # existent.
  def add_file_2_destroy path
    @files_to_destroy ||= Array.new
    @files_to_destroy << path
  end
  alias :add_file_2_remove :add_file_2_destroy
  alias :add_file_to_remove :add_file_2_destroy
  alias :add_file_to_destroy :add_file_2_destroy

  def destroy_files_to_destroy
    @files_to_destroy || return
    @files_to_destroy.each do |file|
      File.exist?(file) || next
      File.unlink(file)
      puts "= Fichier détruit : #{file}"
    end
  end

  # ---------------------------------------------------------------------
  #   Screenshots
  # ---------------------------------------------------------------------
  def shot name
    name = "#{Time.now.to_i}-#{name}"
    page.save_screenshot("./spec/screenshots/#{name}.png")
  end
  def empty_screenshot_folder
    p = './spec/screenshots'
    FileUtils::rm_rf p if File.exists? p
    Dir.mkdir( p, 0777 )
  end

end
