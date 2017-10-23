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
        with_tag('span', with: {class: 'role'}, text: 'correctrice')
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
    sleep 5

    boboche = User.get(@hANACreator[:id])

    expect(page).to have_tag('ul#contributors') do
      with_tag('li', with:{class:'contributor', id: "contributor-#{@hANACreator[:id]}"}) do
        with_tag('span.pseudo', text: /#{@hANACreator[:pseudo]}/)
        with_tag('span.role', text: 'Rédacteur')
      end
    end
    success 'Boboche est maintenant affiché dans la liste des contributeurs'

    expect(boboche).to have_mail({
      sent_after: start_time,
      subject:    "Ajout comme contributeur à un fichier",
      message:    [ @hANARedacteur[:pseudo], "analyser/dashbord/#{@film_id}", "analyser/file/#{@ftest_id}"]
      })
    success 'Patrick reçoit un message l’informant de l’ajout'

  end

  scenario 'Le créateur d’un fichier peut supprimer un co-rédacteur qui n’a pas encore écrit' do

    # Le co-rédacteur n'est plus co-rédacteur
    # Le co-rédacteur reste contributeur de l'analyse

    pending

  end

  scenario 'Le créateur du fichier ne peut que suspendre un co-rédacteur qui a déjà écrit' do
    # C'est-à-dire qu'il reste rédacteur, mais sans pouvoir écrire à nouveau
    # Note : on retire 2 à son bit et on ajoute ?
    pending
  end
end
