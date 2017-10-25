=begin

  Test de la définition d'un co-rédacteur.

  On teste pour s'assurer qu'un créateur de fichier peut définir un
  autre contributeur comme co-rédacteur du fichier.

  Ce contributeur doit être analyste.

  S'il ne contribuait pas à l'analyse, il devient également contributeur.

=end

require_lib_site
require_support_integration
require_support_mail_for_test
require_support_db_for_test
require_support_analyse


feature 'Définition d’un rédacteur' do

  before(:each) do
    @start_time = Time.new.to_i
  end
  let(:start_time) { @start_time }

  def retour_sur_page
    expect(page).to have_tag('h2', text: /contribuer aux analyses/i)
    expect(page).to have_tag('h3', text: /un héros très discret/i)
  end

  before(:all) do

    # On protège les données HOT (donc les users, tickets, etc.)
    backup_base_hot
    protect_hot

    # Si on passe par ici, il faut absolument protéger les données biblio qui
    # vont être modifiées. On doit les sauver si nécessaire et demander leur
    # rechargement.
    backup_base_biblio # seulement si nécessaire
    protect_biblio

    remove_mails

    @film_id = 180 # Un héros très discret


    # PRÉPARE LA BASE D'UNE ANALYSE
    # =============================
    prepare_base_analyse({film_id: @film_id})



    @titre_analyse  = "Un héros très discret" # TITRE DE L'ANALYSE CHOISIE


    # === PREMIER FICHIER ====

    @ftest_titre    = "Fichier d'analyse test en Markdown" # TITRE pour le fichier test

    # On fabrique ce fichier dans la base, mais on le détruit physiquement
    #
    @ftest_id = site.db.insert(:biblio,'files_analyses',{
      film_id:  @film_id,
      titre:    @ftest_titre,
      specs:    '0100'+'0000'
    })

    # Path du fichier
    # On le détruit s'il existe
    @ftest_path = File.join('.','__SITE__','analyser','_data_','files',"#{@film_id}","#{@ftest_id}")
    File.exist?(@ftest_path) && FileUtils.rm_rf(@ftest_path)
    add_file2destroy(@ftest_path)

    # On s'assure que le créateur de l'analyse n'est pas concerné
    # par ce fichier
    nb = site.db.count(:biblio,'user_per_file_analyse',{
      file_id:  @ftest_id, user_id:  @hANACreator[:id],
    })
    expect(nb).to eq 0

    # On met le co-rédacteur défini par la base comme rédacteur
    # comme créateur du fichier
    site.db.insert(
      :biblio, 'user_per_file_analyse',{
        file_id: @ftest_id, user_id: @hANARedacteur[:id], role: 1
    })

    # On met Marion comme correctrice de ce fichier
    site.db.insert(
      :biblio, 'user_per_file_analyse',{
        file_id: @ftest_id, user_id: marion.id, role: 4
      }
    )

  end
  # FIN before:all

  # Le LI contenant le fichier dans le dashboard
  let(:li_file) { @li_file ||= "li#file-#{@ftest_id}" }

  scenario '=> Le créateur de l’analyse peut définir un co-rédacteur' do

    identify @hANACreator

    visit("#{base_url}/analyser/dashboard/#{@film_id}")
    retour_sur_page
    expect(page).to have_tag('li', with: {class: "file", id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}

    # Là, on doit trouver un truc pour ajouter un user
    retour_sur_page
    sleep 4 # 10 * 60

  end

  scenario 'Le créateur du fichier peut définir un co-rédacteur' do

    # Note : ici, c'est un rédacteur de l'analyse (donc pas le créateur de
    # l'analyse mais le créateur du fichier) qui vient faire l'opération.
    identify @hANARedacteur

    visit("#{base_url}/analyser/dashboard/#{@film_id}")
    retour_sur_page
    expect(page).to have_tag('li', with: {class: "file", id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}

    # Là, on doit trouver un truc pour ajouter un user
    retour_sur_page
    expect(page).to have_tag('div.file_buttons') do
      with_tag('a', with: {href: "analyser/file/#{@ftest_id}?op=contributors"}, text: 'contributeurs')
    end
    within('div.file_buttons.top') { click_link 'contributeurs' }
    retour_sur_page
    expect(page).to have_tag('ul#contributors') do
      with_tag('li', with: {class: 'contributor', id: "contributor-#{@hANARedacteur[:id]}"}) do
        with_tag('span', with: {class: 'role'}, text: 'créatrice du fichier')
        with_tag('span', with: {class: 'pseudo'}, text: /#{@hANARedacteur[:pseudo]}/) do
          with_tag('a', with: {href: "user/profil/#{@hANARedacteur[:id]}"}, text: @hANARedacteur[:pseudo])
        end
      end
      with_tag('li', with: {class: 'contributor', id: "contributor-#{marion.id}"}) do
        with_tag('span', with: {class: 'pseudo'}, text: /Marion/) do
          with_tag('a', with: {href: "user/profil/#{marion.id}"}, text: 'Marion')
        end
        with_tag('span', with: {class: 'role'}, text: 'correctrice du fichier')
      end
      without_tag('li', with:{class:'contributor', id: "contributor-#{@hANACreator[:id]}"})
    end
    success 'le créateur trouve une liste conforme'
    expect(page).to have_tag('form', with: {id: 'new_contributor_form'}) do
      with_tag('select', with:{ name: 'new_contributor[id]', id: 'new_contributor_id'})
      with_tag('input', with:{type: 'submit', value: 'Ajouter'})
    end
    success 'avec un formulaire pour choisir de nouveaux contributeurs'

    # ===============> TEST <================

    within('form#new_contributor_form') do
      click_button 'Ajouter'
    end
    success 'le créateur choisit Boboche comme nouveau rédacteur seul'
    retour_sur_page

    # ================= VÉRIFICATIONS ================
    boboche = User.get(@hANACreator[:id])

    expect(page).to have_tag('ul#contributors') do
      with_tag('li', with:{class:'contributor', id: "contributor-#{@hANACreator[:id]}"}) do
        with_tag('span.pseudo', text: /#{@hANACreator[:pseudo]}/)
        with_tag('span.role', text: 'rédacteur du fichier')
      end
    end
    success 'Boboche est maintenant affiché dans la liste des contributeurs'

    expect(boboche).to have_mail({
      sent_after: start_time,
      subject:    "Ajout comme contributeur à un fichier",
      message:    [ @hANARedacteur[:pseudo], "analyser/dashboard/#{@film_id}", "analyser/file/#{@ftest_id}"]
      })
    success 'Patrick reçoit un message l’informant de l’ajout'

  end

  scenario 'Le créateur d’un fichier peut supprimer un contributeur qui n’a pas encore écrit' do

    # Note : ici, c'est un rédacteur de l'analyse (donc pas le créateur de
    # l'analyse mais le créateur du fichier) qui vient faire l'opération.
    identify @hANARedacteur

    visit("#{base_url}/analyser/dashboard/#{@film_id}")
    retour_sur_page
    expect(page).to have_tag('li', with: {class: "file", id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}

    # Là, on doit trouver un truc pour ajouter un user
    retour_sur_page
    expect(page).to have_tag('div.file_buttons') do
      with_tag('a', with: {href: "analyser/file/#{@ftest_id}?op=contributors"}, text: 'contributeurs')
    end
    within('div.file_buttons.top') { click_link 'contributeurs' }
    retour_sur_page
    expect(page).to have_tag('ul#contributors') do
      with_tag('li', with: {class: 'contributor', id: "contributor-#{marion.id}"})
    end
    success 'le créateur se rend sur la liste des contributeurs et trouve la ligne de Marion'

    # ===============> TEST <================
    within("li#contributor-#{marion.id}"){click_link 'supprimer'}

    retour_sur_page
    expect(page).to have_tag('div.notice', text: /Marion ne contribue plus à ce fichier/)
    success 'un message annonce le bon déroulement de l’opération'

    # Marion n'est plus du tout correctrice du fichier
    hcont = site.db.select(:biblio,'user_per_file_analyse',{file_id: @ftest_id, user_id: marion.id}).first
    expect(hcont).to eq nil
    success 'Marion a été retirée de la table `user_per_file_analyse` (pour ce fichier)'

    expect(marion).to have_mail({
      sent_after: start_time,
      subject: "Changement de votre rôle de contributrice",
      message: ["vous n'êtes plus contributrice active", @ftest_titre, @titre_analyse]
      })
    success 'Marion a été avertie par mail du changement'

  end

  scenario 'Le créateur du fichier ne peut que suspendre un contributeur qui a déjà écrit' do

    # La contributrice à supprimer
    husup   = create_new_user(analyste: true, admin: false, pseudo: 'Albertine', sexe: 'F')
    usup_id = husup[:id]
    usup    = User.get(usup_id)

    # On le met comme contributeur de l'analyse et du fichier
    site.db.insert(
      :biblio, 'user_per_analyse',
      {user_id: usup.id, film_id: @film_id, role: 8|4}
    )
    site.db.insert(
      :biblio, 'user_per_file_analyse',
      {file_id: @ftest_id, user_id: usup.id, role: 2|4}
    )
    # Il faut créer un fichier (une version) pour le contributeur à
    # supprimer
    # Noter que le dossier @ftest_path sera détruit à la fin des tests,
    # donc inutile ici de l'ajouter à add_file2destroy
    fname = "#{Time.now.to_i}-#{usup_id}.md"
    fpath = File.join(@ftest_path, fname)
    `mkdir -p "#{File.expand_path(@ftest_path)}"`
    File.open(fpath,'wb'){|f| f.write "Provisoirement par une contributrice à supprimer."}

    # Note : ici, c'est un rédacteur de l'analyse (donc pas le créateur de
    # l'analyse mais le créateur du fichier) qui vient faire l'opération.
    identify @hANARedacteur

    visit("#{base_url}/analyser/dashboard/#{@film_id}")
    retour_sur_page
    expect(page).to have_tag('li', with: {class: "file", id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}

    # Là, on doit trouver un truc pour ajouter un user
    retour_sur_page
    expect(page).to have_tag('div.file_buttons') do
      with_tag('a', with: {href: "analyser/file/#{@ftest_id}?op=contributors"}, text: 'contributeurs')
    end
    within('div.file_buttons.top') { click_link 'contributeurs' }
    retour_sur_page

    expect(page).to have_tag('ul#contributors') do
      with_tag('li', with: {class: 'contributor', id: "contributor-#{usup_id}"})
    end
    success 'le créateur se rend sur la liste des contributeurs et trouve la ligne de la contributrice'

    # ===============> TEST <================
    within("li#contributor-#{usup_id}"){click_link 'supprimer'}

    retour_sur_page
    expect(page).to have_tag('div.notice', text: /#{usup.pseudo} ne contribue plus à ce fichier/)
    success 'un message annonce le bon déroulement de l’opération'

    hcont = site.db.select(:biblio,'user_per_file_analyse',{file_id: @ftest_id, user_id: usup_id}).first
    expect(hcont).not_to eq nil
    expect(hcont[:role] | 32).to be > 0
    success 'cette contributrice est gardée dans la table `user_per_file_analyse` (pour ce fichier) mais marquée inactive (role & 32)'

    expect(usup).to have_mail({
      sent_after: start_time,
      subject: "Changement de votre rôle de contributrice",
      message: ["vous n'êtes plus contributrice active", @ftest_titre, @titre_analyse]
      })
    success 'Albertine a été avertie par mail du changement'


  end
end
