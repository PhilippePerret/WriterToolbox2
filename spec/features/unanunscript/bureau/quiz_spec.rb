=begin

  On prend un auteur au dixième jour pour lui faire faire ses
  quiz (2) et voir si tout se passe bien.

  Dans le nouveau fonctionnement actuel, le quiz est exécuté comme
  n'importe quel quiz, dans la partie éponyme du site. On envoie juste
  le paramètre `wid` qui permet, du côté du quiz, de marquer le travail
  fini.

  Noter qu'ici on ne compte pas les points qui sont attribués pour le
  quiz, ce sera l'objet du test points_quiz_spec.rb

=end

require_support_integration
require_support_unanunscript

feature "Quiz du programme UN AN UN SCRIPT" do

  before(:all) do
    # Avant toute chose, on fait un auteur au dixième jour de
    # son programme
    @dauteur = unanunscript_create_auteur(current_pday: 10)
    @auteur = User.get(@dauteur[:id], force = true)
  end
  let(:dauteur) { @dauteur }
  let(:auteur) { @auteur }

  scenario "=> un auteur peut exécuter un quiz avec succès" do

    # L'auteur rejoint son bureau et trouve des onglets corrects
    identify dauteur
    goto_bureau_unan

    expect(page).to have_tag('div#onglets_sections') do
      with_tag('a', with: {class: 'onglet', id: 'unan_quiz'}, text: 'Quiz (2)')
    end
    click_link 'Quiz (2)'
    success 'l’auteur peut cliquer sur l’onglet des quiz'

    expect(page).to have_tag('div', with: {id: 'panneau-quiz'}) do
      with_tag('ul', with: {id: 'work_list-ready'}) do
        with_tag('li', with: {class: 'work'}, match: 2)
      end
    end
    success 'Le panneau des Quiz est affiché avec ses deux travaux'

    within('ul#work_list-ready li#work-5 div.buttons') do
      click_link 'Démarrer ce travail'
    end
    success 'l’auteur peut démarrer le travail en cliquant sur le bouton'

    expect(page).to have_tag('div', with: {id: 'panneau-quiz'}) do
      with_tag('ul', with: {id: 'work_list-current'}) do
        with_tag('li', with: {class: 'work', id: "work-5"}) do
          with_tag('div', with: {class: 'section_travail'}) do
            with_tag('a', with: {id: 'lk_work-5', href: 'quiz/2?wid=5'}, text: /Procéder au quiz/)
          end
        end
      end
    end
    success 'l’auteur trouve un lien pour procéder au quiz'

    within('div#panneau-quiz li#work-5') do
      # page.find('a#lk_work-5').click
      lien_lib = page.find('a#lk_work-5').text
      scrollTo('li#work-5')
      click_link(lien_lib)
    end
    success 'l’auteur peut cliquer sur le bouton pour remplir le quiz#2'

    expect(page).to have_tag('h2', text: 'Les quiz')

    # On récupère le données du quiz#2
    hquiz = site.db.select(:quiz,'quiz',{id: 2}).first
    quids = hquiz[:questions_ids].as_id_list
    hquestions = Hash.new
    where = "id IN (#{quids.join(', ')})"
    site.db.select(:quiz,'questions',where).each do |hquestion|
      hquestion.merge!(lines_reponses: hquestion[:reponses].split("\n"))
      hquestion.merge!(nombre_reponses: hquestion[:lines_reponses].count)
      hquestions.merge!(hquestion[:id] => hquestion)
    end
    expect(page).to have_tag('form', with: {id: 'quiz_form-2', class: 'quiz_form'}) do
      hquestions.each do |quid, qudata|
        with_tag('div', with: {id: "qz-2-q-#{quid}"}) do
          with_tag('ul', with: {class: 'reponses'}) do
            with_tag('li', count: qudata[:nombre_reponses])
          end
        end
      end
    end
    success 'le quiz est correct'

    begin
      site.db.count(:users_tables,"quiz_#{auteur.id}")
      expect(true).to eq false # La table ne devrait pas exister
    rescue Mysql2::Error => e
    end
    success 'l’auteur n’a pas encore de table de quiz'

    hwork = site.db.select(:users_tables,"unan_works_#{auteur.id}",{id: 5}).first
    expect(hwork[:status]).not_to eq 9
    success 'le travail #5 n’est pas marqué achevé'


    within('form#quiz_form-2') do
      hquestions.each do |quid, qudata|
        coche "div#qz-2-q-#{quid} input#qz-2-q-#{quid}-r-0"
      end
      click_button 'Soumettre ce quiz'
    end
    success 'l’auteur peut remplir le quiz et le soumettre'

    nombre = site.db.count(:users_tables,"quiz_#{auteur.id}",{quiz_id: 2})
    expect(nombre).to eq 1
    success 'les réponses du quiz sont enregistrées dans la table de l’auteur'

    # L'auteur peut revenir dans son bureau
    goto_bureau_unan 'quiz'

    hwork = site.db.select(:users_tables,"unan_works_#{auteur.id}",{id: 5}).first
    expect(hwork[:status]).to eq 9
    success 'le travail #5 du quiz#2 est marqué achevé'

    expect(page).to have_tag('div', with: {id: 'panneau-quiz'}) do
      without_tag('ul', with: {id: 'work_list-current'})
      with_tag('ul', with: {id: 'work_list-done'}) do
        with_tag('li', with: {class: 'work', id: "work-5"})
      end
    end
    success 'le travail #5 se trouve dans la section des travaux achevés'

  end
end
