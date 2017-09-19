=begin

  Test de l'affichage correct des tâches d'un auteur
  suivant le programme à un jour J

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


  scenario "les tâches sont réparties correctement, au jour J, dans les différents onglets" do
    # Note : 'all', ci-dessous, signifie "jusqu'au 10e jour"
    data_all_pdays = site.db.select(:unan,'absolute_pdays',"ID <= 10")

    # Liste qui va contenir tous les travaux absolus pour le jour-programme défini,
    # ici le dixième.
    # Chaque élément est un hash des données des travaux auquel est ajouté la
    # propriété :pday permettant de savoir quel jour correspond au travail,
    # entendu qu'un même travail peut être exécuté dans plusieur pdays différents
    all_abs_works = Array.new

    # La liste qui va permettre de relever plus tard tous les enregistrements
    # des works relatifs créés jusqu'au jour courant.
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
    require './__SITE__/unanunscript/_lib/_not_required/module/taches/constants.rb'
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

    # ============ DÉBUT ===========
    identify data_auteur
    click_link('Votre programme UN AN UN SCRIPT')

    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('div', with: {id: 'onglets_sections'}) do
      with_tag('a', with:{id: 'unan_taches', class: 'onglet'}, text: /Tâches/)
    end

    # On doit cliquer sur l'onglet tâches pour forcer la création des tâches
    # relatives à l'auteur.
    page.find('div#onglets_sections a#unan_taches').click
    expect(page).to have_tag('h2', text: 'Bureau de votre programme UN AN UN SCRIPT')

    # Maintenant qu'on a atteint le bureau et qu'on a activé un onglet de tâche,
    # tous les works relatifs ont dû
    # être créés, donc on peut relever chaque work-relatif pour chaque
    # work absolu en fonction du pday. On en a besoin pour connaitre l'ID
    # qui va permettre de démarrer le travail, etc.
    # Mais comme c'est une relève assez longue, on utilise une requête préparée
    table_works_name = "unan_works_#{data_auteur[:id]}"
    request = "SELECT * FROM #{table_works_name} WHERE program_id = #{data_auteur[:program_id]} AND abs_work_id = ? AND abs_pday = ?"

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

    # On commence par vérifier la conformité du bureau

    #
    nombre_taches = data_all_taches[:task].count
    nombre_taches = " <span class=\"overtaken\">#{nombre_taches}</span>"
    expect(page).to have_tag('a', with: {id: 'unan_taches', class: "onglet overtaken"}, text: "Tâches#{nombre_taches}")
    success 'l’onglet « tâches » possède le bon titre (avec le nombre de tâches et la couleur)'

    expect(page).to have_tag('div', with: {id: 'panneau'}) do
      with_tag('ul', with: {id: "work_list-task"}) do

        data_all_taches[:task].each do |habswork|
          # Rappel : dans +habswork+, on a aussi une propriété :pday qui permet de
          # connaitre le jour-programme de l'abswork en question
          # `hash_user_works` contient en clé "<abs work id>-<pday>" et en valeur
          # le hash du work relatif, et principalement :id qui doit servir ici à
          # trouver la fiche du travail.
          hwork = hash_user_works["#{habswork[:id]}-#{habswork[:pday]}"]

          with_tag('li', with: {id: "work-#{hwork[:id]}", class:'work'}) do
            with_tag('div', with:{class:'nbpoints'}, text: "#{habswork[:points]} points")
            with_tag('div', with:{class:'titre'}, text: habswork[:titre])
            with_tag('div', with:{class:'buttons'}) do
              with_tag('a', with:{href: "unanunscript/bureau/taches?op=start_work&wid=#{hwork[:id]}"}, text: 'Démarrer ce travail')
            end
            with_tag('div', with:{class: 'travail'})
          end
        end
      end #/UL
    end #/DIV#panneau
    success 'le panneau « tâches » contient toutes les tâches'

    failure 'l’onglet « pages » possède le bon titre (avec le nombre de pages et la couleur)'

    failure 'le panneau « pages » contient bien toutes les pages'

    failure 'l’onglet « Quiz » possède le bon titre (nombre de quiz et couleur)'

    failure 'le panneau « quiz » contient les bonnes tâches'

    failure 'l’onglet « Forum » possède le bon titre (nombre de tâches forum et couleur)'

    failure 'le panneau « Forum » ne contient aucune tâche'

    failure 'l’auteur possède un bureau conforme'

    # ICI, IL VA POUVOIR DÉMARRER DES TÂCHES

    failure 'l’auteur peut démarrer une pure tâche'

    failure 'cela change le titre de l’onglet « Tâches »'
    failure 'cela change le contenu du panneau tâches'

    failure 'l’auteur peut marquer vue une page de cours'
    failure 'cela change le titre de l’onglet « Cours »'
    failure 'cela change le contenu du panneau « Cours »'

    failure 'l’auteur peut démarrer un quiz'
    failure 'cela change le titre de l’onglet « Quiz »'
    failure 'cela affiche le quiz en question dans le panneau « Quiz »'

  end
end
