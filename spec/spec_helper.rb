
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'capybara/rspec'

require 'selenium-webdriver'
Capybara.javascript_driver  = :selenium
Capybara.default_driver     = :selenium


# Pour les tests avec have_tag etc.
require 'rspec-html-matchers'


def require_folder folder, dont_check_if_exist = false
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

  def require_support_unanunscript
    require_folder './spec/support/unanunscript'
  end

  def require_support_quiz
    require_folder './spec/support/quiz'
  end

  def require_support_forum
    require_folder './spec/support/forum'
  end

  def require_support_analyse
    require_folder './spec/support/analyse'
  end
  alias :require_support_analyses :require_support_analyse

  def require_support_tickets
    require_folder './spec/support/tickets'
  end


  # Il faut appeler cette méthode en haut de toutes les feuilles de
  # test qui utilisent la base `boite-a-outils_biblio`.
  # Cela permet de faire une sauvegarde au début de la suite et de
  # recharger les données initiales à la fin de la suite.
  # Si plusieurs feuilles de test sont jouées, la protection se fait
  # seulement en début et en fin de test.
  #
  # NOTER QUE : si la méthode est appelée à l'intérieur du before(:all),
  # il faut  impérativement ajouter `backup_base_biblio` avec d'appeler
  # cette méthode, car le backup ne serait pas fait (il n'est fait qu'avant
  # le lancement des tests, donc avant le before(:all))
  def protect_biblio
    $protect_base_biblio = true
  end

  # En appelant cette méthode, on s'assure que la base :hot (contenant
  # notamment les users) reste intacte après le test
  # Ça commence par faire un backup en début de test si nécessaire,
  # puis ça remet toujours ce backup à la fin
  #
  # NOTER QUE : si la méthode est appelée à l'intérieur du before(:all),
  # il faut  impérativement ajouter `backup_base_hot` avec d'appeler
  # cette méthode, car le backup ne serait pas fait (il n'est fait qu'avant
  # le lancement des tests, donc avant le before(:all))
  def protect_hot
    $protect_base_hot = true
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

    # Protection de la base :hot
    if $protect_base_hot
      start = Time.now.to_f
      if backup_base_hot
        laps  = (Time.now.to_f - start).round(5)
        puts "Durée du backup de la base `boite-a-outils_hot` : #{laps}"
      end
    end

    # Protection de la base biblio
    if $protect_base_biblio
      start = Time.now.to_f
      if backup_base_biblio
        laps  = (Time.now.to_f - start).round(5)
        puts "Durée du backup de la base `boite-a-outils_biblio` : #{laps}"
      end
    end

    # … vide le dossier des screenshots
    empty_screenshot_folder

  end

  config.after :suite do

    begin
      destroy_files_to_destroy
    rescue Exception => e
      puts "\n### PROBLÈME EN DÉTRUISANT LES FICHIERS :"
      puts e.message
      puts e.backtrace.inspect
    end

    # Récupérer les données de la base hot protégée
    begin
      if $protect_base_hot
        start = Time.now.to_f
        retreive_base_hot
        laps  = (Time.now.to_f - start).round(5)
        puts "Durée du retrieve de la base `boite-a-outils_hot` : #{laps}"
      end
    rescue Exception => e
      puts "\n### PROBLÈME EN RÉCUPÉRANT LES DONNÉES HOT :"
      puts e.message
      puts e.backtrace.inspect
    end

    # Récupérer les données de la base biblio
    begin
      if $protect_base_biblio
        start = Time.now.to_f
        retreive_base_biblio
        laps  = (Time.now.to_f - start).round(5)
        puts "Durée du retrieve de la base `boite-a-outils_biblio` : #{laps}"
      end
    rescue Exception => e
      puts "\n### PROBLÈME EN RÉCUPÉRANT LES DONNÉES BIBLIO :"
      puts e.message
      puts e.backtrace.inspect
    end

    # # Décommenter la ligne suivante pour réinjecter les données de la
    # # collection Narration dans la base
    # begin
    #   retreive_data_narration
    # rescue Exception => e
    #   puts "\n### PROBLÈME EN RÉCUPÉRANT LES DONNÉES NARRATION :"
    #   puts e.message
    #   puts e.backtrace.inspect
    # end


  end

  # ---------------------------------------------------------------------
  #   Méthodes utiles
  # ---------------------------------------------------------------------

  # Permet d'ajouter des fichiers/dossiers à détruire en fin de test, s'ils
  # existent.
  # def add_file_to_destroy     alias
  # def add_file2destroy        alias
  def add_file_2_destroy path
    $files_to_destroy ||= Array.new
    $files_to_destroy << path
  end
  alias :add_file2destroy :add_file_2_destroy
  alias :add_file_2_remove :add_file_2_destroy
  alias :add_file_to_remove :add_file_2_destroy
  alias :add_file_to_destroy :add_file_2_destroy

  def destroy_files_to_destroy
    puts "-> destroy_files_to_destroy"
    $files_to_destroy || begin
      puts "Il n'y a pas de fichiers à détruire"
      return
    end
    puts "Il y a #{$files_to_destroy.count} fichiers/dossiers à détruire"
    $files_to_destroy.each do |file|
      File.exist?(file) || next
      if File.directory?(file)
        FileUtils.rm_rf(file)
        puts "= Dossier détruit : #{file}"
      else
        File.unlink(file)
        puts "= Fichier détruit : #{file}"
      end
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
