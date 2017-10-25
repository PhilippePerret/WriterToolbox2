
require_lib_site
require_support_db_for_test
require_support_integration
require_support_quiz

require_folder './__SITE__/quiz/_lib/_required'


feature 'Un user identifié' do
  before(:all) do
    @dauteur  = create_new_user
    @auteur   = User.get(@dauteur[:id])
  end
  let(:dauteur) { @dauteur }
  let(:auteur) { @auteur }
  context 'qui n’a pas encore de table quiz' do
    before(:all) do
      site.db.use_database(:users_tables)
      site.db.execute("DROP TABLE IF EXISTS quiz_#{@dauteur[:id]}")
    end
    scenario 'peut afficher le quiz normalement, sans réponse' do
      identify dauteur
      goto_quiz 21

      # sleep 4*60
      # ========= VÉRIFICATION PRÉLIMINAIRE ===========
      expect(page).to have_tag('form', with:{id: "quiz_form-21", class: 'quiz_form'}) do
        with_tag('input', with: {type: 'hidden', name: 'operation', value:'evaluate_quiz'})
        with_tag('input', with: {type: 'hidden', name: 'quiz[owner]', value: "#{dauteur[:id]}"})
        with_tag('div', with:{class: 'quiz'}) do
          with_tag('h3', with: {class: 'titre'}, text: 'Test quiz')
          with_tag('div', with: {class: 'description'})
          with_tag('div', with: {class: 'question'}, match: 3)
          (10..12).each do |quid|
            with_tag('div', with: {class: 'question', id:"qz-21-q-#{quid}"})
          end
        end
        with_tag('input', with:{type: 'submit', value: 'Soumettre ce quiz'})
      end
    end
    scenario 'doit remplir entièrement le quiz avant de pouvoir le soumettre' do
      identify dauteur
      goto_quiz 21

      # ==========> TEST(S) <==============
      within('form#quiz_form-21') do
        click_button 'Soumettre ce quiz'
      end
      expect(page).to have_tag('div.error', text: /Il faut répondre aux questions, avant de soumettre ce quiz/)
      within('form#quiz_form-21') do
        page.find('div#qz-21-q-10 input#qz-21-q-10-r-1').click
        click_button 'Soumettre ce quiz'
      end
      expect(page).to have_tag('div.error', text: /Il faut répondre à toutes les questions/)
    end
    scenario 'peut remplir le quiz et le soumettre, ce qui enregistre ses réponses' do
      identify dauteur
      goto_quiz 21

      # ================> TEST <============
      within('form#quiz_form-21') do
        coche 'div#qz-21-q-10 input#qz-21-q-10-r-1'
        coche 'div#qz-21-q-11 input#qz-21-q-11-r-0'
        coche 'div#qz-21-q-12 input#qz-21-q-12-r-2'
        coche 'div#qz-21-q-12 input#qz-21-q-12-r-3'
        shot 'avant-submit-quiz-with-all-reponses'
        click_button 'Soumettre ce quiz'
        # sleep 5*60
      end
      expect(page).to have_tag('form', with: {class: 'quiz_form'}) do
        with_tag('div', with: {class: 'quiz_header'}) do
          with_tag('div', with: {class: 'encart_note_finale medquiz'}) do
            with_tag('span', with: {class: 'date'})
            with_tag('span', with: {class: 'note_finale'}, text: '11,1 / 20')
            with_tag('span', with: {class: 'points'}, text: 'Points : 25 / 45')
          end
        end
      end
      success 'Affiche un cadre de résultat conforme'

      whereclause = "quiz_id = 21 ORDER BY created_at DESC LIMIT 1"
      res = site.db.select(:users_tables,"quiz_#{auteur.id}",whereclause).first
      expect(res).not_to eq nil
      res = res[:resultats]
      expect(res).not_to eq nil
      res = JSON.parse(res,symbolize_names: true)
      reps = Hash.new
      res[:reponses].each do |quid, qudata| reps.merge!(quid.to_s.to_i => qudata) end
      res[:reponses] = reps
      res[:total_points] = 25
      res[:total_points_max] = 45
      expect(reps).to have_key 10
      expect(reps).to have_key 11
      expect(reps).to have_key 12
      expect(reps[10][:choix]).to eq [1]
      expect(reps[10][:points]).to eq 0
      expect(reps[10][:points_max]).to eq 10
      expect(reps[11][:choix]).to eq [0]
      expect(reps[11][:points]).to eq 20
      expect(reps[11][:points_max]).to eq 20
      expect(reps[12][:choix]).to eq [2, 3]
      expect(reps[12][:points]).to eq 5
      expect(reps[12][:points_max]).to eq 15
      success 'Enregistre des résultats valides dans la table'
    end
  end


  context 'qui a une table quiz' do
    before(:all) do
      begin
        site.db.count(:users_tables,"quiz_#{@auteur.id}")
      rescue Mysql2::Error => e
        # IL FAUT FAIRE LA TABLE
        require './__SITE__/quiz/_lib/_not_required/module/evaluate/quiz.rb'
        q = Quiz.new(21, @auteur)
        q.create_table_owner
        site.db.count(:users_tables,"quiz_#{@auteur.id}") # => ERROR si pas créée
      end
    end
    context 'qui a répondu au questionnaire' do
      before(:all) do
        whereclause = "quiz_id = 21"
        if site.db.count(:users_tables,"quiz_#{@auteur.id}",whereclause) == 0
          data2save = {
            quiz_id: 21, user_id: @auteur.id,
            resultats: '{"date":"27 09 2017 - 09:40","reponses":{"10":{"choix":[1],"points":0,"points_max":10,"bons_choix":[2],"best_choix":2,"best_points":10},"11":{"choix":[0],"points":20,"points_max":20,"bons_choix":[0],"best_choix":0,"best_points":20},"12":{"choix":[2,3],"points":5,"points_max":15,"bons_choix":[1,3],"best_choix":1,"best_points":10}},"nombre_questions":3,"total_points":25,"total_points_max":45,"note_finale":111}',
            note: 111, options: '00000000'
          }
          site.db.insert(:users_tables,"quiz_#{@auteur.id}", data2save)
        end
      end
      scenario 'trouve le questionnaire avec sa note et ses réponses' do
        identify dauteur
        goto_quiz 21

        expect(page).to have_tag('form', with: {class: 'quiz_form'}) do
          shot 'revisite-quiz-answered'
          with_tag('div', with: {class: 'quiz_header'}) do
            with_tag('div', with: {class: 'encart_note_finale medquiz'}) do
              with_tag('span', with: {class: 'date'})
              with_tag('span', with: {class: 'note_finale'}, text: '11,1 / 20')
              with_tag('span', with: {class: 'points'}, text: 'Points : 25 / 45')
            end
          end
        end
        success 'Affiche un cadre de résultat conforme'

        expect(page).to have_tag('form.quiz_form') do
          with_tag('div', with: {id: 'qz-21-q-10', class: 'question bad'}) do
            with_tag('li', with: {id: 'li-qz-21-q-10-r-1', class: 'badchoix'})
            with_tag('li', with: {id: 'li-qz-21-q-10-r-2', class: 'bonchoixmissing'})
            without_tag('li', with: {id: 'li-qz-21-q-10-r-0', class: 'bonchoix'})
              #  Note : on ne peut malheureusement pas tester qu'il n'y a pas
              #  de classe définie.
          end
          with_tag('div', with: {id: 'qz-21-q-11', class: 'question bon'}) do
            with_tag('li', with: {id: 'li-qz-21-q-11-r-0', class: 'bonchoix'})
            without_tag('li', with: {id: 'li-qz-21-q-11-r-1', class: 'bonchoix'})
            without_tag('li', with: {id: 'li-qz-21-q-11-r-2', class: 'bonchoix'})
          end
          with_tag('div', with: {id: 'qz-21-q-12', class: 'question bad'}) do
            without_tag('li', with: {id: 'li-qz-21-q-12-r-0', class: 'bonchoix'})
            with_tag('li', with: {id: 'li-qz-21-q-12-r-1', class: 'bonchoixmissing'})
            with_tag('li', with: {id: 'li-qz-21-q-12-r-2', class: 'badchoix'})
            with_tag('li', with: {id: 'li-qz-21-q-12-r-3', class: 'bonchoix'})
          end
        end
        success 'A sélectionné les réponses données avec les bonnes réponses'

      end

      context 'avec un questionnaire à usage unique' do
        before(:all) do
          quiz_set_usage_unique(21)
        end
        scenario 'ne peut plus soumettre le quiz' do
          identify dauteur
          goto_quiz 21
          expect(page).to have_tag('form.quiz_form') do
            without_tag('input', with: {type: 'submit'})
          end
          expect(page).not_to have_button 'Soumettre ce quiz'
          expect(page).not_to have_button 'Recommencer ce quiz'
          success 'le formulaire ne possède plus de bouton pour soumettre le quiz ou le recommencer'

          visit "#{base_url}/quiz/21?operation=evaluate_quiz"
          expect(page).to have_tag('div.error', text: /C'est un quiz à usage unique et vous l’avez déjà soumis/)
          success 'l’user ne peut pas forcer l’enregistrement du questionnaire'
        end
      end
      context 'avec un questionnaire à usage multiple' do
        before(:all) do
          quiz_set_usage_multiple(21)
        end
        after(:all) do
          quiz_set_usage_unique(21)
        end
        scenario 'peut soumettre à nouveau le quiz' do
          identify dauteur
          goto_quiz 21
          expect(page).to have_tag('form.quiz_form') do
            with_tag('div.quiz_header')
            without_tag('input', with: {type: 'submit', value: 'Soumettre ce quiz'})
            # On s'assure que les réponses sont réglées, en vitesse
            with_tag('div', with: {id: 'qz-21-q-10', class: 'question bad'})
            with_tag('div', with: {id: 'qz-21-q-11', class: 'question bon'})
          end
          expect(page).not_to have_button 'Soumettre ce quiz'
          expect(page).to have_button 'Recommencer ce quiz'
          success 'la page ne possède pas de bouton pour soumettre, mais un bouton pour recommencer'

          # On fait deux fois. La première, le premier quiz est
          # trop proche du second, donc il ne s'enregistre pas. La seconde
          # fois, on a modifié la date du premier, donc le second peut
          # s'enregistrer.

          2.times do |itime|
            # ============> TEST <==========
            click_bouton_by_id('redo_quiz', 2)

            # ============ VÉRIFICATION ==============
            expect(page).to have_tag('form#quiz_form-21') do
              without_tag('span.note_finale')
              without_tag('div', with: {id: 'qz-21-q-10', class: 'question bad'})
              without_tag('div', with: {id: 'qz-21-q-11', class: 'question bon'})
            end
            expect(page).not_to have_button 'Recommencer ce quiz'
            expect(page).to have_button 'Soumettre ce quiz'
            success "le quiz se réaffiche, sans résultats, et avec le bouton pour soumettre à nouveau"

            within('form#quiz_form-21') do
              coche 'div#qz-21-q-10 input#qz-21-q-10-r-2'
              coche 'div#qz-21-q-11 input#qz-21-q-11-r-0'
              coche 'div#qz-21-q-12 input#qz-21-q-12-r-1'
              coche 'div#qz-21-q-12 input#qz-21-q-12-r-3'
              click_button 'Soumettre ce quiz'
              sleep 0.5
              shot 'after-resubmit-quiz'
            end
            success "l'user peut remplir et soumettre à nouveau le questionnaire"

            # On modifie la date du premier quiz et on ressoumet le nouveau
            if itime == 0
              expect(page).to have_tag('div.error', /Vous devez attendre avant de soumettre ce quiz à nouveau/)
              success 'Une alerte de quiz trop proche est donnée'
              rid = site.db.select(:users_tables,"quiz_#{auteur.id}",{quiz_id: 21},[:id]).first[:id]
              now = Time.now.to_i
              newdata = {
                created_at: now - 3600,
                updated_at: now - 3600
              }
              site.db.update(:users_tables,"quiz_#{auteur.id}",newdata,{id: rid})
            end
          end
          #/ Fin des deux fois

          # On attend que la page soit à nouveau réaffichée
          expect(page).to have_tag('form#quiz_form-21')
          expect(page).not_to have_tag('div.error')

          allresultats = site.db.select(:users_tables,"quiz_#{auteur.id}",{quiz_id: 21})
          nombre = allresultats.count
          expect(nombre).to eq 2
          success 'Deux questionnaires sont maintenant enregistrés'

          expect(page).to have_tag('form#quiz_form-21') do
            with_tag('div.quiz_header') do
              with_tag('span', with: {class: 'note_finale'}, text: '20 / 20')
              with_tag('span', with: {class: 'points'}, text: 'Points : 45 / 45')
            end
            with_tag('div', with: {id: 'qz-21-q-10', class: 'question bon'})
            with_tag('div', with: {id: 'qz-21-q-11', class: 'question bon'})
            with_tag('div', with: {id: 'qz-21-q-12', class: 'question bon'})
          end
          success 'La version du questionnaire parfait s’affiche correctement'

          click_link 'se déconnecter'
          identify dauteur
          goto_quiz 21

          expect(page).to have_tag('form#quiz_form-21') do
            with_tag('div.quiz_header') do
              with_tag('span', with: {class: 'note_finale'}, text: '20 / 20')
              with_tag('span', with: {class: 'points'}, text: 'Points : 45 / 45')
            end
          end
          success 'Quand il revient plus tard, c’est la dernière version qui est affichée'

          expect(page).to have_tag('form#quiz_form-21') do
            shot 'retour-quiz-with-deux-resultats'
            with_tag('select', with: {name: 'quiz[resultats_id]', class: 'all_owner_resultats'}) do
              allresultats.each do |hresultats|
                date_str = Time.at(hresultats[:created_at]).strftime('%d %m %Y - %H:%M')
                with_tag('option', text: "Réponses du #{date_str}")
              end
            end
            with_tag('button', text: 'Revoir')
          end
          success 'La page contient un menu pour choisir un ancien formulaire'

          # ==========> TEST <=============
          selectionne(selector: 'select.all_owner_resultats', selectedIndex: 0)
          click_vraiment_bouton('btn_revoir')
          expect(page).to have_tag('form#quiz_form-21') do
            shot 'after-choix-resultats-un'
            with_tag('div.quiz_header') do
              with_tag('span', with: {class: 'note_finale'}, text: '11,1 / 20')
              with_tag('span', with: {class: 'points'}, text: 'Points : 25 / 45')
            end
          end
          success 'Il peut choisir la version à revoir (nom avec date et note)'
        end
      end
    end
  end
end
