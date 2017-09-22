=begin

  Test de l'affichage correct des tâches d'un auteur
  suivant le programme à un jour J

  Ici, on prend un auteur au dixième jour, mais sans aucune tâche démarrée.
  On teste d'abord que le bureau soit conforme (dans les onglets des tâches),
  puis on démarrer des tâches, etc. pour constater les modifications.

=end

require_support_integration
require_support_unanunscript

feature "Affichage des tâches de l'auteur" do
  before(:all) do
    @data_auteur = unanunscript_create_auteur(current_pday: 10)
    @auteur = User.get(@data_auteur[:id], force = true)
  end

  let(:data_auteur) { @data_auteur }
  let(:auteur) { @auteur }


  scenario "le bureau est conforme et permet à l'auteur de travailler" do

    # Nom de la table de l'auteur contenant tous ses travaux relatifs
    table_works = "unan_works_#{auteur.id}"


    # Note : 'all', dans 'data_all_pdays' ci-dessous, signifie "jusqu'au 10e jour"
    data_all_pdays = site.db.select(:unan,'absolute_pdays',"ID <= 10")

    # Liste qui va contenir tous les travaux absolus pour le jour-programme défini,
    # ici le dixième.
    # Chaque élément est un hash des données des travaux auquel est ajouté la
    # propriété :pday permettant de savoir quel jour correspond au travail,
    # entendu qu'un même travail peut être exécuté dans plusieur pdays différents
    all_abs_works = Array.new

    # La liste qui va permettre de relever plus tard tous les enregistrements
    # des works relatifs créés jusqu'au jour courant.
    # Noter que maintenant (version 2.0 du Boa) :
    #   - les travaux relatifs sont créés dès l'arrivée sur le bureau (dans le
    #     processus normal ils le seront même dès le début de la journée, par
    #     le cronjob)
    #   - les travaux relatifs n'atendent pas d'être démarrés pour être créés.
    #     Dès qu'un nouveau jour-programme est arrivé, on crée pour l'auteur
    #     les travaux relatifs, avec 0 en status.
    #     (le status sera passé à 2 ou 4 suivant les dépassements, comme il y
    #     en aura ici, puisqu'on part directement du dixième jour).
    #
    values_user_works_request = Array.new

    data_all_pdays.each do |hpday|
      pday_absworks =
      site.db.select(:unan,'absolute_works',"ID IN (#{hpday[:works].as_id_list.join(',')})")
        .each do |habswork|
          all_abs_works << habswork.merge(pday: hpday[:id])
          values_user_works_request << [habswork[:id], hpday[:id]]
        end
    end

    # On va dispatcher les travaux pour avoir :
    # - les pures tâches
    # - les pages de cours
    # - les quiz
    # - le forum
    require './__SITE__/unanunscript/bureau/constants.rb'
    data_all_taches = {
      task: Array.new, page: Array.new, quiz: Array.new, forum: Array.new,
      count: 0
    }
    all_abs_works.each do |habswork|
      typew = habswork[:type_w]
      data_type = Unan::Abswork::TYPES[habswork[:type_w]]
      data_all_taches[data_type[:type]] << habswork
      data_all_taches[:count] += 1
    end

    # À ce moment-là du test, la table "unan_works_<id auteur>" n'existe pas
    # encore.
    begin
      nb = site.db.count(:users_tables,table_works)
      expect(nb).to eq nil
    rescue Mysql2::Error => e
      expect(e).to be_a(Mysql2::Error)
    rescue Exception => e
      puts e
      expect(true).to eq nil # on ne doit pas passer par ici
    end

    # ============ DÉBUT ===========
    identify data_auteur
    click_link('Votre programme UN AN UN SCRIPT')

    # =========== PREMIÈRES VÉRIFICATIONS ===============

    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')


    # Maintenant qu'on a atteint le bureau tous les works relatifs ont dû
    # être créés, donc on peut relever chaque work-relatif pour chaque
    # work absolu en fonction du pday. On en a besoin pour connaitre l'ID
    # qui va permettre de démarrer le travail, etc.
    # Mais comme c'est une relève assez longue, on utilise une requête préparée
    request = "SELECT * FROM #{table_works} WHERE program_id = #{data_auteur[:program_id]} AND abs_work_id = ? AND abs_pday = ?"

    site.db.use_database(:users_tables)
    all_user_works = site.db.execute(request, values_user_works_request)
    # On va en tirer un Hash avec en clé <abswork-id>-<pday>
    hash_user_works = Hash.new
    all_user_works.each do |hwork|
      k = "#{hwork[:abs_work_id]}-#{hwork[:abs_pday]}"
      hash_user_works.merge!(k => hwork)
    end

    expect(all_user_works.count).to eq data_all_taches[:count]
    success 'Il y a autant de travaux relatifs que de travaux absolus'


    # =============== VÉRIFICATION DES TRAVAUX RELATIFS ================
    #
    # Les travaux relatifs viennent d'être créés pour l'auteur courant
    # et doivent posséder toutes les informations nécessaires, notamment dans
    # les options où beaucoup de choses sont consignées, comme la durée en jour
    # de la tâche ou son type.
    now = Time.now.to_i

    data_all_taches.each do |tache_type, dtaches|
      # tache_type = :task, :page, :quiz, :forum ET :count
      tache_type != :count || next
      # dtaches est une liste de tous les Hash des travaux absolus, auxquels ont
      # été ajoutés les pday.
      dtaches.each do |habswork|

        # la clé pour retrouver le travail relatif correspondant
        krelwork = "#{habswork[:id]}-#{habswork[:pday]}"
        hwork = hash_user_works[krelwork]

        # ========== VÉRIFICATION DU WORK RELATIF ===========
        duree_jours = habswork[:duree]
        real_duree  = duree_jours.jours # note : le rythme est 5
        jour_depart = (10 - habswork[:pday]).to_i
        real_depart = now - jour_depart.jours
        # La date de fin attendue
        expected_end = real_depart + real_duree
        # Le dépassement (positif => dépassement, négatif => normal)
        en_depassement = expected_end < now
        depassement = now - expected_end
        jours_depassement = (depassement.to_f / 1.jour).ceil
        en_grand_depassement = depassement > real_duree

        status =
          case true
          when en_grand_depassement then 4
          when en_depassement       then 2
          else 0
          end

        # = DÉBUG =
        # puts "status de hwork##{hwork[:id]} (abs-work##{habswork[:id]}) : #{status}"
        # puts(
        #   case true
        #   when en_grand_depassement then "en grand dépassement de #{jours_depassement} jours"
        #   when en_depassement       then "en dépassement normal de #{jours_depassement} jours"
        #   else "sans dépassement"
        #   end
        #   )
        # = /DÉBUG =

        expect(hwork[:status]).to eq status

        opts = hwork[:options]
        # On doit trouver le type du travail dans les options
        expect(opts[0..1]).to eq habswork[:type_w].to_s
        # On doit trouver la durée dans les options
        expect(opts[2..4]).to eq duree_jours.to_s.rjust(3,'0')
        # On doit trouver le type dans les options
        expect(opts[5]).to eq Unan::Abswork::ITYPES[tache_type].to_s
        # On doit trouver le nombre de jours de dépassement
        nombre_jours_depassement =
          case true
          when en_depassement then jours_depassement
          else 0
          end.to_s.rjust(3,'0')
        # Les jours de dépassement seront marqués seulement lorsque le travail
        # sera arrêté
        expect(opts[6..8]).not_to eq nombre_jours_depassement
        expect(opts[6..8].rjust(3,'0')).to eq '000'

      end
      success "tous les travaux de type #{tache_type.inspect} sont corrects"
    end



    # ================== LES ONGLETS =====================

    expect(page).to have_tag('div', with: {id: 'onglets_sections'}) do

      # On doit pouvoir trouver le nom exact de chaque onglet, avec l'indication
      # du nombre de tâches
      nom_onglet_taches = "Tâches (#{data_all_taches[:task].count})"
      with_tag('a', with:{id: 'unan_taches', class: 'onglet'}, text: nom_onglet_taches) do
        with_tag('span', with: {class: 'nombre red'})
      end
      nom_onglet_pages = "Cours (#{data_all_taches[:page].count})"
      with_tag('a', with:{id: 'unan_pages', class: 'onglet'}, text: nom_onglet_pages) do
        with_tag('span', with: {class: 'nombre red'})
      end
      nom_onglet_quiz  = "Quiz (#{data_all_taches[:quiz].count})"
      with_tag('a', with:{id: 'unan_quiz', class: 'onglet'}, text: nom_onglet_quiz) do
        with_tag('span', with: {class: 'nombre red'})
      end
      # Aucune tâche pour le forum, mais ATTENTION, peut-être qu'il pourra y
      # en avoir à l'avenir.
      with_tag('a', with:{id: 'unan_forum', class: 'onglet'}, text: "Forum")
    end
    success 'les onglets sont correctement réglés, avec indication du nombre'





    # ============= ONGLET DES TÂCHES PURES ==============



    # On doit cliquer sur l'onglet tâches pour forcer la création des tâches
    # relatives à l'auteur.
    page.find('div#onglets_sections a#unan_taches').click
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')

    # On vérifie la conformité de l'onglet des tâches pures

    expect(page).to have_tag('section', with:{id: 'contents'}) do
      with_tag('div', with:{id: 'section'}) do
        with_tag('div', with: {id: 'onglets_sections'})
        with_tag('div', with:{class: 'panneau', id: 'panneau-taches'})
      end
    end
    success 'le panneau des tâches pures est affiché'

    success 'le panneau tâches contient…'
    expect(page).to have_tag('div', with: {id: 'panneau-taches', class:'panneau'}) do
      # Le panneau contient les trois listes de taches, done, ready et current
      with_tag('ul', with: {id: 'work_list-done'}) do
        without_tag('li')
      end
      success '…une liste des tâches faites sans aucune tâche'
      with_tag('ul', with: {id: 'work_list-current'}) do
        without_tag('li')
      end
      success '… une liste des tâches courantes sans aucune tâche'

      with_tag('ul', with: {id: "work_list-ready"}) do

        data_all_taches[:task].each do |habswork|
          # Rappel : dans +habswork+, on a aussi une propriété :pday qui permet de
          # connaitre le jour-programme de l'abswork en question
          # `hash_user_works` contient en clé "<abs work id>-<pday>" et en valeur
          # le hash du work relatif, et principalement :id qui doit servir ici à
          # trouver la fiche du travail.
          hwork = hash_user_works["#{habswork[:id]}-#{habswork[:pday]}"]
          with_tag('li', with: {id: "work-#{hwork[:id]}", class:'work'}) do
            with_tag('div', with:{class:'nbpoints'}, text: "#{habswork[:points]} points")
            titre_checked = habswork[:titre].force_encoding('utf-8')
            titre_checked = titre_checked.gsub(/<(.*?)>/,'')
            titre_checked = Regexp.escape(titre_checked)
            with_tag('div', with:{class:'titre'}, text: /#{titre_checked}/)
            with_tag('div', with:{class:'buttons'}) do
              case hwork[:status]
              when 2, 4
                with_tag('a', with:{class: 'red', href: "unanunscript/bureau/taches?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
              else
                with_tag('a', with:{href: "unanunscript/bureau/taches?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
              end
            end
            without_tag('div', with:{class: 'travail'})
            without_tag('div', with:{class: 'details'})
            without_tag('div', with:{class: 'resultat_attendu'})
            without_tag('div', with:{class: 'exemples'})
            without_tag('div', with:{class: 'suggestions_lectures'})
            without_tag('div', with:{class: 'autres_infos'})
          end
        end
      end #/UL taches-ready
      success '… une liste des tâches prêtes à être démarrées avec les bonnes informations'
    end #/DIV#panneau




    # ============== ON SE REND SUR LE PANNEAU DES PAGES DE COURS ============



    page.find('div#onglets_sections a#unan_pages').click
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('section', with:{id: 'contents'}) do
      with_tag('div', with:{id: 'section'}) do
        with_tag('div', with: {id: 'onglets_sections'})
        with_tag('div', with:{class: 'panneau', id: 'panneau-pages'})
      end
    end
    success 'le panneau des pages de cours à lire est affiché'

    success 'ce panneau « Cours » contient…'
    expect(page).to have_tag('div', with: {class: 'panneau', id: 'panneau-pages'}) do
      # Le panneau contient les trois listes de taches, done, ready et current
      with_tag('ul', with: {id: 'work_list-done'}) do
        without_tag('li')
      end
      success '…une liste des pages lues sans aucune page'
      with_tag('ul', with: {id: 'work_list-current'}) do
        without_tag('li')
      end
      success '… une liste des pages courantes sans aucune page'

      with_tag('ul', with: {id: "work_list-ready"}) do

        data_all_taches[:page].each do |habswork|
          # Rappel : dans +habswork+, on a aussi une propriété :pday qui permet de
          # connaitre le jour-programme de l'abswork en question
          # `hash_user_works` contient en clé "<abs work id>-<pday>" et en valeur
          # le hash du work relatif, et principalement :id qui doit servir ici à
          # trouver la fiche du travail.
          hwork = hash_user_works["#{habswork[:id]}-#{habswork[:pday]}"]
          with_tag('li', with: {id: "work-#{hwork[:id]}", class:'work'}) do
            with_tag('div', with:{class:'nbpoints'}, text: "#{habswork[:points]} points")
            titre_checked = habswork[:titre].force_encoding('utf-8')
            titre_checked = titre_checked.gsub(/<(.*?)>/,'')
            titre_checked = Regexp.escape(titre_checked)
            with_tag('div', with:{class:'titre'}, text: /#{titre_checked}/)
            with_tag('div', with:{class:'buttons'}) do
              case hwork[:status]
              when 2, 4
                with_tag('a', with:{class: 'red', href: "unanunscript/bureau/pages?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
              else
                with_tag('a', with:{href: "unanunscript/bureau/pages?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
              end
            end
            without_tag('div', with:{class: 'travail'})
            without_tag('div', with:{class: 'details'})
            without_tag('div', with:{class: 'resultat_attendu'})
            without_tag('div', with:{class: 'exemples'})
            without_tag('div', with:{class: 'suggestions_lectures'})
            without_tag('div', with:{class: 'autres_infos'})
          end
        end
      end #/UL taches-ready
      success '… une liste des pages de cours prêtes à être démarrées avec les bonnes informations'
    end




    # ============== ON SE REND SUR L'ONGLET DES QUIZ ===========================



    page.find('div#onglets_sections a#unan_quiz').click
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('section', with:{id: 'contents'}) do
      with_tag('div', with:{id: 'section'}) do
        with_tag('div', with: {id: 'onglets_sections'})
        with_tag('div', with:{class: 'panneau', id: 'panneau-quiz'})
      end
    end
    success 'le panneau des quiz est affiché'

    success 'ce panneau « Quiz » contient…'
    expect(page).to have_tag('div', with: {class: 'panneau', id: 'panneau-quiz'}) do
      # Le panneau contient les trois listes de taches, done, ready et current
      with_tag('ul', with: {id: 'work_list-done'}) do
        without_tag('li')
      end
      success '…une liste des quiz faits sans aucun quiz'
      with_tag('ul', with: {id: 'work_list-current'}) do
        without_tag('li')
      end
      success '… une liste des quiz courants sans aucun quiz'

      with_tag('ul', with: {id: "work_list-ready"}) do

        data_all_taches[:quiz].each do |habswork|
          # Rappel : dans +habswork+, on a aussi une propriété :pday qui permet de
          # connaitre le jour-programme de l'abswork en question
          # `hash_user_works` contient en clé "<abs work id>-<pday>" et en valeur
          # le hash du work relatif, et principalement :id qui doit servir ici à
          # trouver la fiche du travail.
          hwork = hash_user_works["#{habswork[:id]}-#{habswork[:pday]}"]
          with_tag('li', with: {id: "work-#{hwork[:id]}", class:'work'}) do
            with_tag('div', with:{class:'nbpoints'}, text: "suivant résultat")
            titre_checked = habswork[:titre].force_encoding('utf-8')
            titre_checked = titre_checked.gsub(/<(.*?)>/,'')
            titre_checked = Regexp.escape(titre_checked)
            with_tag('div', with:{class:'titre'}, text: /#{titre_checked}/)
            with_tag('div', with:{class:'buttons'}) do
              case hwork[:status]
              when 2, 4
                with_tag('a', with:{class: 'red', href: "unanunscript/bureau/quiz?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
              else
                with_tag('a', with:{href: "unanunscript/bureau/quiz?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
              end
            end
            without_tag('div', with:{class: 'travail'})
            without_tag('div', with:{class: 'details'})
            without_tag('div', with:{class: 'resultat_attendu'})
            without_tag('div', with:{class: 'exemples'})
            without_tag('div', with:{class: 'suggestions_lectures'})
            without_tag('div', with:{class: 'autres_infos'})
          end
        end
      end #/UL taches-ready
      success '… une liste des quiz prêts à être démarrés avec les bonnes informations'
    end


    # ============== ON SE REND SUR L'ONGLET FORUM ===========================



    page.find('div#onglets_sections a#unan_forum').click
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('section', with:{id: 'contents'}) do
      with_tag('div', with:{id: 'section'}) do
        with_tag('div', with: {id: 'onglets_sections'})
        with_tag('div', with:{class: 'panneau', id: 'panneau-forum'})
      end
    end
    success 'le panneau du forum est affiché'

    success 'ce panneau « Forum » contient…'
    expect(page).to have_tag('div', with: {class: 'panneau', id: 'panneau-forum'}) do
      # Le panneau contient les trois listes de taches, done, ready et current
      with_tag('ul', with: {id: 'work_list-done'}) do
        without_tag('li')
      end
      success '…une liste des tâches faites sans aucune tâche'
      with_tag('ul', with: {id: 'work_list-current'}) do
        without_tag('li')
      end
      success '… une liste des tâches courantes sans aucune tâche'
      with_tag('ul', with: {id: 'work_list-ready'}) do
        without_tag('li')
      end
      success '… une liste des tâches à démarrer sans aucune tâche'
    end

  end

  scenario 'l’auteur peut démarrer une tâche pure' do

    table_name = "unan_works_#{data_auteur[:id]}"

    identify data_auteur
    visit "#{base_url}/unanunscript/bureau"
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')



    # ---------------------------------------------------------------------
    #
    #  On revient sur l'onglet des tâches pures pour démarrer une première
    #  tâche.
    #
    # ---------------------------------------------------------------------

    page.find('div#onglets_sections a#unan_taches').click
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('div', with:{class: 'panneau', id:'panneau-taches'})

    # On prend la liste des tâches à démarrer et on clique la première tache en
    # dépassement
    work_id = nil
    lien_premier_travail = nil
    within('div.panneau ul#work_list-ready') do
      lien_premier_travail = find('li.work a.red', match: :first)
      work_id = lien_premier_travail['href'].split('=')[-1].to_i
          # Rappel : le lien s'achève par &wik=<id du work relatif>
    end

    # On prend les données actuelles du travail en question
    hwork_init = site.db.select(:users_tables,table_name,{id: work_id}).first
    puts "hwork AVANT (hwork_init) : #{hwork_init.inspect}"
    habswork = site.db.select(:unan,'absolute_works',{id: hwork_init[:abs_work_id]}).first
    puts "habswork : #{habswork.inspect}"

    # ---------------------------------------------------------------------
    #   L'auteur clique pour démarrer le travail
    # ---------------------------------------------------------------------
    lien_premier_travail.click


    # On revient dans le bureau
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('div.notice', text: /Travail démarré avec succès/)
    success 'l’auteur peut démarrer une pure tâche'

    # On prend les données qui ont dû être modifiées
    hwork = site.db.select(:users_tables,table_name,{id: work_id}).first
    puts "hwork après : #{hwork.inspect}"

    expect(hwork[:status]).to eq hwork_init[:status] + 1
    success 'le travail est marqué démarré en conservant sa marque de dépassement'

    jours_depassement = ((Time.now.to_i - hwork[:expected_at]).to_f/1.jour).floor
    dateh_fin = Time.at(hwork[:expected_at]).strftime('%d %m')

    success 'l’auteur trouve un bloc de travail conforme qui contient…'
    expect(page).to have_tag('li', with: {id: "work-#{work_id}"}) do
      with_tag('div.nbpoints', text: "#{habswork[:points]} points")
      success 'l’indication du nombre de points'
      with_tag('div.titre', text: habswork[:titre])
      success 'le titre du travail'
      with_tag('div.dates') do
        with_tag('div.depassement', text: /Vous êtes en dépassement de #{jours_depassement} jours/)
        with_tag('div', text: /Ce travail aurait dû être accompli le #{dateh_fin}/)
      end
      success 'le dépassement en exergue, avec le nombre de jours de retard et la date de fin attendue'
      with_tag('div.buttons') do
        with_tag('a', with: {href: "unanunscript/bureau/taches?op=done_work&wid=#{work_id}"}, text: 'Marquer ce travail fini')
      end
      success 'le bouton pour marquer le travail fini'
      with_tag('div.travail')
      success 'la section présentant le travail'
      with_tag('div.section_details')
      success 'la section des détails de la tâche'
      with_tag('div.section_exemples')
      success 'la section des exemples à trouver'
      with_tag('div.section_suggestions_lectures')
      success 'la section des suggestions de lectures'
      with_tag('div.section_autres_infos')
      success 'la section des autres infos'
    end


    # --------------------------------------------------------------------
    # L'auteur marque le travail fini
    # ---------------------------------------------------------------------

    within("li#work-#{work_id}") do
      click_link 'Marquer ce travail fini'
    end
    expect(page).to have_tag('div.notice', text: /Vous avez gagné #{habswork[:points]} points/)

    hwork_done = site.db.select(:users_tables,table_name,{id: work_id}).first
    puts "hwork_done : #{hwork_done.inspect}"

    expect(hwork_done[:status]).to eq 9
    success 'le statut est passé à 9'

    expect(hwork_done[:points]).to eq habswork[:points]
    success 'les points du travail relatif ont été définis'

    expect(auteur.program.points).to eq habswork[:points]
    success 'le nombre de points du programme de l’auteur a augmenté'

    failure 'le retard en jours a été enregistré dans les options'
    failure 'le travail est listé dans les travaux récemment faits'
    failure 'avec un lien pour le réafficher'

    # ---------------------------------------------------------------------
    #   L'auteur clique sur le bouton pour réafficher le travail
    # ---------------------------------------------------------------------

    failure 'l’auteur peut consulter à nouveau son travail fait'

  end

  # scenario 'l’auteur peut gérer les pages de cours' do
  #
  #   failure 'l’auteur peut marquer vue une page de cours'
  #   failure 'cela change le titre de l’onglet « Cours »'
  #   failure 'cela change le contenu du panneau « Cours »'
  #
  #   failure 'l’auteur peut démarrer un quiz'
  #   failure 'cela change le titre de l’onglet « Quiz »'
  #   failure 'cela affiche le quiz en question dans le panneau « Quiz »'
  #
  # end
end
