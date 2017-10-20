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
  before(:all) do

    # Si on passe par ici, il faut absolument protéger les données biblio qui
    # vont être modifiées. On doit les sauver si nécessaire et demander leur
    # rechargement.
    backup_base_biblio # seulement si nécessaire
    protect_biblio

    pending "Il faut reprendre tous ces tests une fois qu'il y aura des fichiers/taches"

    # On produit quelques fichiers pour l'analyse et quelques
    # tâches pour avoir des choses à faire.
    # UTILISER UN AUTRE FILM QUE 4 (21 GRAMS) QUI COMPORTE DES FICHIERS
    @film_id = 4
    # @hfiles  = create_files_analyse(@film_id, 5)
    @htaches = create_taches_analyse(@film_id, 6)

  end

  context 'pour un administrateur' do
    scenario '=> Un administrateur trouve une page conforme' do

      identify phil
      visit "#{base_url}/analyser/dashboard/#{@film_id}"
      expect(page).to have_tag('h2', text: /Contribuer/)
      expect(page).to have_tag('h3', text: /21 Grams/)

      sleep 4

      expect(page).to have_tag('ul#files_analyses') do
        @hfiles.each do |hfile|
          expect(page).to have_tag('li', with: {class: 'file', id: "file-#{hfile[:id]}"}) do
            with_tag('span', text: /#{hfile[:titre]}/)
          end
        end
      end
      expect(page).to have_tag('div#files_buttons') do
        with_tag('a', text: '+')
      end
      success 'la page contient la liste des fichiers de l’analyse'

      expect(page).to have_tag('ul#contributors') do

      end
      success 'la page contient la liste des contributeurs de l’analyse'

      expect(page).to have_tag('ul#taches') do
        @htaches.each do |htache|
          expect(page).to have_tag('li', with: {class: 'tache', id: "tache-#{htache[:id]}"}) do
            with_tag('span', text: /#{htache[:action]}/)
            with_tag('a', text: 'finir')
          end
        end
      end
      expect(page).to have_tag('div#taches_buttons') do
        with_tag('a', text: '+')
      end
      success 'la page contient la liste des tâches à faire (planning)'

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

      # On produit quelques fichiers pour l'analyse et quelques
      # tâches pour avoir des choses à faire.
      @hfiles  = create_files_analyse(hanalyse[:id], 3)
      @htaches = create_taches_analyse(hanalyse[:id], 6)


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
    it '=> trouve un dashboard conforme' do
      # Note : se servir de l'analyse de @film_id
      pending
    end
  end


  context 'pour un analyste ne contribuant pas à l’analyse' do
    it '=> trouve un dashboard conforme' do
      # Note : se servir de l'analyse de @film_id
      pending
    end
  end

  context 'pour un non analyste' do
    it '=> trouve un dashboard conforme' do
      # Note : se servir de l'analyse de @film_id
      pending
    end
  end

end
