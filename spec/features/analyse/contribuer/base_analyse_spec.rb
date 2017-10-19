=begin

  Test de la base d'une analyse, c'est-à-dire la fenêtre principale de
  contribution de l'analyse.

  Elle doit présentée :
    - la liste de tous les fichiers de l'analyse avec leur statut
    - la liste de tous les contribueurs de l'analyse avec leur rôle
    - la liste des choses à faire sur l'analyse (planning)

=end
require_lib_site
require_support_integration
require_support_db_for_test
require_support_analyse

# On va intervenir sur les tables, donc il faut protéger les données
protect_biblio

feature 'Tableau de bord de l’analyse d’un film', check: false do
  context 'pour un administrateur' do
    scenario '=> Un administrateur trouve une page conforme' do

      identify phil
      visit "#{base_url}/analyser/dashboard/4"
      expect(page).to have_tag('h2', text: /Contribuer/)
      expect(page).to have_tag('h3', text: /21 Grams/)

      sleep 4

      expect(page).to have_tag('ul#files_analyses') do

      end
      expect(page).to have_tag('div#files_buttons') do
        with_tag('a', text: '+')
      end
      success 'la page contient la liste des fichiers de l’analyse'

      expect(page).to have_tag('ul#contributors') do

      end
      success 'la page contient la liste des contributeurs de l’analyse'

      expect(page).to have_tag('ul#taches') do

      end
      expect(page).to have_tag('div#taches_buttons') do
        with_tag('a', text: '+')
      end
      success 'la page contient la liste des tâche à faire (planning)'

    end
  end
  context 'pour le créateur de l’analyse' do

    scenario '=> Le créateur de l’analyse trouve une page conforme' do
      #
      # Pour ce test, on met Benoit comme créateur d'un film qui ne
      # devrait par recevoir d'analyse, ni aujourd'hui ni plus tard, en tout
      # cas par rapport aux données OFFLINE.
      hbenoit = db_get_user_by_id(2)
      hanalyse = create_analyse_for(hbenoit, {current: true})

      # puts "Données de Benoit"
      # puts hbenoit.inspect
      # puts "Données de l'analyse"
      # puts hanalyse.inspect

      # On rejoint l'analyse
      identify hbenoit
      visit "#{base_url}/analyser/dashboard/#{hanalyse[:id]}"

      sleep 4

      expect(page).to have_tag('h2', text: /Contribuer/)
      expect(page).to have_tag('h3', text: /Ali/)
      expect(page).to have_content "Vous êtes le créateur de cette analyse"

      expect(page).to have_tag('ul#files_analyses') do

      end
      expect(page).to have_tag('div#files_buttons') do
        with_tag('a', text: '+')
      end
      success 'la page contient la liste des fichiers de l’analyse'


      expect(page).to have_tag('ul#contributors') do

      end
      success 'la page contient la liste des contributeurs de l’analyse'


      expect(page).to have_tag('ul#taches') do

      end
      expect(page).to have_tag('div#taches_buttons') do
        with_tag('a', text: '+')
      end
      success 'la page contient la liste des tâches à faire (planning)'

    end
  end

  context 'pour un analyste contribuant à l’analyse' do

  end


  context 'pour un analyste ne contribuant pas à l’analyse' do
    pending
  end

  context 'pour un non analyste' do
    pending
  end

end
