=begin

  Ce test permet de tester l'attribution des points pour un quiz

  Ce nombre de points dépend :
  - du résultat du quiz
  - du retard du travail

  Ce test permet de tester tous ces cas

=end

require_support_integration
require_support_unanunscript
require_support_quiz

feature "Quiz du programme UN AN UN SCRIPT" do

  context 'avec un travail SANS retard' do
    before(:each) do
      # Avant toute chose, on fait un auteur au dixième jour de
      # son programme
      @dauteur = unanunscript_create_auteur(current_pday: 5)
      @auteur = User.get(@dauteur[:id], force = true)
    end
    let(:dauteur) { @dauteur }
    let(:auteur) { @auteur }

    scenario 'rapporte tous les points pour un quiz dans les temps et correct' do

      identify dauteur
      goto_bureau_unan 'quiz'

      # Table des travaux relatifs de l'user
      table_works = "unan_works_#{auteur.id}"

      points_program_init = auteur.program.data[:points]

      habswork25 = site.db.select(:unan,'absolute_works',{id: 25},[:id,:points]).first
      points_abswork_25 = habswork25[:points]
      hwork11 = site.db.select(:users_tables,table_works,{id: 11},[:id, :points]).first
      points_work_11 = hwork11[:points]

      expect(page).to have_tag('div#panneau-quiz')
      within('li#work-11 div.buttons') do
        click_link 'Démarrer ce travail'
      end

      expect(page).to have_tag('div#panneau-quiz')
      within('ul#work_list-current li#work-11 div.section_travail') do
        click_link_by_id('lk_work-11')
      end

      # Il se peut que ça n'ait pas marché, on essaie à nouveau
      unless page.find('form#quiz_form-8')
        within('div#panneau-quiz li#work-11') do
          lien_lib = page.find('a#lk_work-11').text
          scrollTo('li#work-11')
          click_link(lien_lib)
        end
      end

      expect(page).to have_tag('form#quiz_form-8')
      within('form#quiz_form-8') do
        coche 'li#li-qz-8-q-63-r-0 input#qz-8-q-63-r-0'
        coche 'li#li-qz-8-q-68-r-2 input#qz-8-q-68-r-2'
        coche 'li#li-qz-8-q-65-r-2 input#qz-8-q-65-r-2'
        coche 'li#li-qz-8-q-64-r-1 input#qz-8-q-64-r-1'
        coche 'li#li-qz-8-q-73-r-1 input#qz-8-q-73-r-1'
        coche 'li#li-qz-8-q-66-r-1 input#qz-8-q-66-r-1'
        coche 'li#li-qz-8-q-69-r-1 input#qz-8-q-69-r-1'
        coche 'li#li-qz-8-q-72-r-3 input#qz-8-q-72-r-3'
        coche 'li#li-qz-8-q-71-r-0 input#qz-8-q-71-r-0'
        coche 'li#li-qz-8-q-70-r-3 input#qz-8-q-70-r-3'
        coche 'li#li-qz-8-q-67-r-2 input#qz-8-q-67-r-2'
        click_button 'Soumettre ce quiz'
      end

      expect(page).to have_tag('form.quiz_form') do
        with_tag('div.quiz_header') do
          with_tag('span.note_finale', text: '20 / 20')
        end
      end

      # =============> VÉRIFICATION <==============
      # On prend l'enregistrement des réponses pour obtenir le nombre de points
      # max et celui obtenu au quiz
      hreps = site.db.select(:users_tables, "quiz_#{auteur.id}", {quiz_id: 8}).first
      resultats = JSON.parse(hreps[:resultats])
      nombre_points_max   = resultats['total_points_max']
      nombre_points_user  = resultats['total_points']
      expect(nombre_points_max).to be > 0
      expect(nombre_points_user).to be > 0

      hwork = site.db.select(:users_tables,table_works,{id: 11}).first
      expect(hwork[:status]).to eq 9
      success 'le travail est marqué fini'
      expect(nombre_points_user).to eq nombre_points_max
      success "l’auteur a obtenu pour le quiz le nombre de points max (#{nombre_points_user})"
      expect(hwork[:points]).not_to eq 0
      expect(hwork[:points]).to eq nombre_points_user
      success "le travail possède le bon nombre de points (le maximum : #{nombre_points_max})"
      auteur.instance_variable_set('@program', nil)
      expect(auteur.program.data[:points]).to eq points_program_init + nombre_points_max
      success 'l’auteur a augmenté du bon nombre de points'
    end



    scenario 'rapporte la moitié des points pour un quiz dans les temps et à moitié correct' do

      identify dauteur
      goto_bureau_unan 'quiz'

      # Table des travaux relatifs de l'user
      table_works = "unan_works_#{auteur.id}"

      points_program_init = auteur.program.data[:points]

      habswork25 = site.db.select(:unan,'absolute_works',{id: 25},[:id,:points]).first
      points_abswork_25 = habswork25[:points]
      hwork11 = site.db.select(:users_tables,table_works,{id: 11},[:id, :points]).first
      points_work_11 = hwork11[:points]

      expect(page).to have_tag('div#panneau-quiz')
      within('li#work-11 div.buttons') do
        click_link 'Démarrer ce travail'
      end

      expect(page).to have_tag('div#panneau-quiz')
      within('ul#work_list-current li#work-11 div.section_travail') do
        click_link_by_id('lk_work-11')
      end

      # Il se peut que ça n'ait pas marché, on essaie à nouveau
      unless page.find('form#quiz_form-8')
        within('div#panneau-quiz li#work-11') do
          lien_lib = page.find('a#lk_work-11').text
          scrollTo('li#work-11')
          click_link(lien_lib)
        end
      end

      expect(page).to have_tag('form#quiz_form-8')
      within('form#quiz_form-8') do                     # -    total    Total
                                                        #      user     Quiz
        coche 'li#li-qz-8-q-63-r-1 input#qz-8-q-63-r-1' # 10    0       10
        coche 'li#li-qz-8-q-68-r-2 input#qz-8-q-68-r-2' # 0     10      20
        coche 'li#li-qz-8-q-65-r-2 input#qz-8-q-65-r-2' # 0     20      30
        coche 'li#li-qz-8-q-64-r-1 input#qz-8-q-64-r-1' # 0     30      40
        coche 'li#li-qz-8-q-73-r-0 input#qz-8-q-73-r-0' # 10    30      50
        coche 'li#li-qz-8-q-66-r-0 input#qz-8-q-66-r-0' # 10    30      60
        coche 'li#li-qz-8-q-69-r-1 input#qz-8-q-69-r-1' # 0     50      80
        coche 'li#li-qz-8-q-72-r-0 input#qz-8-q-72-r-0' # 10    50      90
        coche 'li#li-qz-8-q-71-r-1 input#qz-8-q-71-r-1' # 10    50     100
        coche 'li#li-qz-8-q-70-r-3 input#qz-8-q-70-r-3' # 0     60     110
        coche 'li#li-qz-8-q-67-r-0 input#qz-8-q-67-r-0' # 10    60     120
        click_button 'Soumettre ce quiz'
      end

      expect(page).to have_tag('form.quiz_form') do
        with_tag('div.quiz_header') do
          with_tag('span.note_finale', text: '10 / 20')
        end
      end

      # =============> VÉRIFICATION <==============
      # On prend l'enregistrement des réponses pour obtenir le nombre de points
      # max et celui obtenu au quiz
      hreps = site.db.select(:users_tables, "quiz_#{auteur.id}", {quiz_id: 8}).first
      resultats = JSON.parse(hreps[:resultats])
      nombre_points_max   = resultats['total_points_max']
      nombre_points_user  = resultats['total_points']
      expect(nombre_points_max).to be > 0
      expect(nombre_points_user).to be > 0

      hwork = site.db.select(:users_tables,table_works,{id: 11}).first
      expect(hwork[:status]).to eq 9
      success 'le travail est marqué fini'
      expect(nombre_points_user).to eq nombre_points_max / 2
      success "l’auteur a obtenu pour le quiz la moitié du nombre de points (#{nombre_points_user})"
      expect(hwork[:points]).not_to eq 0
      expect(hwork[:points]).to eq nombre_points_user
      success "le travail possède le bon nombre de points (la moitié : #{nombre_points_user}/#{nombre_points_max})"
      auteur.instance_variable_set('@program', nil)
      expect(auteur.program.data[:points]).to eq points_program_init + nombre_points_user
      success "l’auteur a augmenté du bon nombre de points (il est à #{auteur.program.data[:points]})"
    end
  end

  context 'avec un travail AVEC retard' do
    before(:each) do
      # Avant toute chose, on fait un auteur au dixième jour de
      # son programme
      @dauteur = unanunscript_create_auteur(current_pday: 10)
      @auteur = User.get(@dauteur[:id], force = true)
    end
    let(:dauteur) { @dauteur }
    let(:auteur) { @auteur }

    scenario 'rapporte tous les points amputés des jours de retard pour un quiz dans les temps et correct' do

      identify dauteur
      goto_bureau_unan 'quiz'

      # Table des travaux relatifs de l'user
      table_works = "unan_works_#{auteur.id}"

      points_program_init = auteur.program.data[:points]

      habswork25 = site.db.select(:unan,'absolute_works',{id: 25},[:id,:points]).first
      points_abswork_25 = habswork25[:points]
      hwork11 = site.db.select(:users_tables,table_works,{id: 11},[:id, :points]).first
      points_work_11 = hwork11[:points]

      expect(page).to have_tag('div#panneau-quiz')
      within('li#work-11 div.buttons') do
        click_link 'Démarrer ce travail'
      end

      expect(page).to have_tag('div#panneau-quiz')
      within('ul#work_list-current li#work-11 div.section_travail') do
        click_link_by_id('lk_work-11')
      end

      # Il se peut que ça n'ait pas marché, on essaie à nouveau
      unless page.find('form#quiz_form-8')
        within('div#panneau-quiz li#work-11') do
          lien_lib = page.find('a#lk_work-11').text
          scrollTo('li#work-11')
          click_link(lien_lib)
        end
      end

      expect(page).to have_tag('form#quiz_form-8')
      within('form#quiz_form-8') do
        coche 'li#li-qz-8-q-63-r-0 input#qz-8-q-63-r-0'
        coche 'li#li-qz-8-q-68-r-2 input#qz-8-q-68-r-2'
        coche 'li#li-qz-8-q-65-r-2 input#qz-8-q-65-r-2'
        coche 'li#li-qz-8-q-64-r-1 input#qz-8-q-64-r-1'
        coche 'li#li-qz-8-q-73-r-1 input#qz-8-q-73-r-1'
        coche 'li#li-qz-8-q-66-r-1 input#qz-8-q-66-r-1'
        coche 'li#li-qz-8-q-69-r-1 input#qz-8-q-69-r-1'
        coche 'li#li-qz-8-q-72-r-3 input#qz-8-q-72-r-3'
        coche 'li#li-qz-8-q-71-r-0 input#qz-8-q-71-r-0'
        coche 'li#li-qz-8-q-70-r-3 input#qz-8-q-70-r-3'
        coche 'li#li-qz-8-q-67-r-2 input#qz-8-q-67-r-2'
        click_button 'Soumettre ce quiz'
      end

      expect(page).to have_tag('form.quiz_form') do
        with_tag('div.quiz_header') do
          with_tag('span.note_finale', text: '20 / 20')
        end
      end

      # =============> VÉRIFICATION <==============
      # On prend l'enregistrement des réponses pour obtenir le nombre de points
      # max et celui obtenu au quiz
      hreps = site.db.select(:users_tables, "quiz_#{auteur.id}", {quiz_id: 8}).first
      resultats = JSON.parse(hreps[:resultats])
      nombre_points_max   = resultats['total_points_max']
      nombre_points_user  = resultats['total_points']
      retrait_depassement = 40 # pour 4 jours de retard
      expect(nombre_points_max).to be > 0
      expect(nombre_points_user).to be > 0

      hwork = site.db.select(:users_tables,table_works,{id: 11}).first
      expect(hwork[:status]).to eq 9
      success 'le travail est marqué fini'
      expect(nombre_points_user).to eq nombre_points_max
      success "l’auteur a obtenu pour le quiz le nombre de points max (#{nombre_points_user})"
      expect(hwork[:points]).not_to eq 0
      expect(hwork[:points]).to eq (nombre_points_user - retrait_depassement)
      success "le travail possède un nombre de points moindre (#{nombre_points_max} - #{retrait_depassement} = #{hwork[:points]})"
      auteur.instance_variable_set('@program', nil)
      expect(auteur.program.data[:points]).to eq points_program_init + nombre_points_max - retrait_depassement
      success 'l’auteur a augmenté du bon nombre de points (points du quiz - retrait de dépassement)'
    end



    scenario 'rapporte la moitié des points pour un quiz dans les temps et à moitié correct' do

      identify dauteur
      goto_bureau_unan 'quiz'

      # Table des travaux relatifs de l'user
      table_works = "unan_works_#{auteur.id}"

      points_program_init = auteur.program.data[:points]

      habswork25 = site.db.select(:unan,'absolute_works',{id: 25},[:id,:points]).first
      points_abswork_25 = habswork25[:points]
      hwork11 = site.db.select(:users_tables,table_works,{id: 11},[:id, :points]).first
      points_work_11 = hwork11[:points]

      expect(page).to have_tag('div#panneau-quiz')
      within('li#work-11 div.buttons') do
        click_link 'Démarrer ce travail'
      end

      expect(page).to have_tag('div#panneau-quiz')
      within('ul#work_list-current li#work-11 div.section_travail') do
        click_link_by_id('lk_work-11')
      end

      # Il se peut que ça n'ait pas marché, on essaie à nouveau
      unless page.find('form#quiz_form-8')
        within('div#panneau-quiz li#work-11') do
          lien_lib = page.find('a#lk_work-11').text
          scrollTo('li#work-11')
          click_link(lien_lib)
        end
      end

      expect(page).to have_tag('form#quiz_form-8')
      within('form#quiz_form-8') do                     # -    total    Total
                                                        #      user     Quiz
        coche 'li#li-qz-8-q-63-r-1 input#qz-8-q-63-r-1' # 10    0       10
        coche 'li#li-qz-8-q-68-r-2 input#qz-8-q-68-r-2' # 0     10      20
        coche 'li#li-qz-8-q-65-r-2 input#qz-8-q-65-r-2' # 0     20      30
        coche 'li#li-qz-8-q-64-r-1 input#qz-8-q-64-r-1' # 0     30      40
        coche 'li#li-qz-8-q-73-r-0 input#qz-8-q-73-r-0' # 10    30      50
        coche 'li#li-qz-8-q-66-r-0 input#qz-8-q-66-r-0' # 10    30      60
        coche 'li#li-qz-8-q-69-r-1 input#qz-8-q-69-r-1' # 0     50      80
        coche 'li#li-qz-8-q-72-r-0 input#qz-8-q-72-r-0' # 10    50      90
        coche 'li#li-qz-8-q-71-r-1 input#qz-8-q-71-r-1' # 10    50     100
        coche 'li#li-qz-8-q-70-r-3 input#qz-8-q-70-r-3' # 0     60     110
        coche 'li#li-qz-8-q-67-r-0 input#qz-8-q-67-r-0' # 10    60     120
        click_button 'Soumettre ce quiz'
      end

      expect(page).to have_tag('form.quiz_form') do
        with_tag('div.quiz_header') do
          with_tag('span.note_finale', text: '10 / 20')
        end
      end

      # =============> VÉRIFICATION <==============
      # On prend l'enregistrement des réponses pour obtenir le nombre de points
      # max et celui obtenu au quiz
      hreps = site.db.select(:users_tables, "quiz_#{auteur.id}", {quiz_id: 8}).first
      resultats = JSON.parse(hreps[:resultats])
      nombre_points_max   = resultats['total_points_max']
      nombre_points_user  = resultats['total_points']
      retrait_depassement = 40 # pour 4 jours de retard
      expect(nombre_points_max).to be > 0
      expect(nombre_points_user).to be > 0

      hwork = site.db.select(:users_tables,table_works,{id: 11}).first
      expect(hwork[:status]).to eq 9
      success 'le travail est marqué fini'
      expect(nombre_points_user).to eq (nombre_points_max / 2)
      success "l’auteur a obtenu pour le quiz la moitié du nombre de points - le retrait de retard (#{hwork[:points]})"
      expect(hwork[:points]).not_to eq 0
      expect(hwork[:points]).to eq nombre_points_user - retrait_depassement
      success "le travail possède le bon nombre de points (la moitié - dépassement : #{nombre_points_user}/#{nombre_points_max}  - #{retrait_depassement})"
      auteur.instance_variable_set('@program', nil)
      expect(auteur.program.data[:points]).to eq points_program_init + nombre_points_user - retrait_depassement
      success "l’auteur a augmenté du bon nombre de points (il est à #{auteur.program.data[:points]})"
    end
  end

end
