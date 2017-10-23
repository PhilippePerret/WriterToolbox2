=begin

  Test de l'édition proprement dite d'un fichier

  Cette version ne teste que l'édition par des users abilités à le
  faire. C'est le test `edit_privileges_spec.rb` qui s'occupe de tout
  type de visiteurs.

=end

require_lib_site
require_support_integration
require_support_mail_for_test
require_support_db_for_test
require_support_analyse

feature 'Edition d’un fichier d’analyse de travail' do


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

    site.db.insert(:biblio,'user_per_file_analyse',{
      file_id:  @ftest_id,
      user_id:  @hANACreator[:id],
      role:     1 # le créateur
    })

    # On met Marion en correctrice du fichier (mais elle est
    # aussi administratrice)
    site.db.insert(:biblio,'user_per_file_analyse',{
      file_id:  @ftest_id,
      user_id:  marion.id,
      role:     4 # correctrice
    })

    # On met le co-rédacteur défini par la base comme rédacteur de ce fichier
    # du fichier
    site.db.insert(
      :biblio, 'user_per_file_analyse',{
        file_id: @ftest_id,
        user_id: @hANARedacteur[:id],
        role: 2
    })

    # On met le correcteur défini par la base comme correcteur
    # du fichier
    site.db.insert(
      :biblio, 'user_per_file_analyse',{
        file_id: @ftest_id,
        user_id: @hANASimpleCorrector[:id],
        role: 4
    })

  end #/before(:all)

  before(:each) do
    @start_time = Time.new.to_i
  end
  let(:start_time) { @start_time }

  def retour_sur_page
    expect(page).to have_tag('h2', text: /contribuer aux analyses/i)
    expect(page).to have_tag('h3', text: /un héros très discret/i)
  end

  # Le LI contenant le fichier dans le dashboard
  let(:li_file) { @li_file ||= "li#file-#{@ftest_id}" }

  context 'Le créateur de l’analyse' do
    scenario '=> peut modifier le fichier à sa guise' do

      # puts "@ftest_path : #{@ftest_path.inspect}"
      expect(File.exist?(@ftest_path)).to eq false

      identify @hANACreator
      visit "#{base_url}/analyser/dashboard/#{@film_id}"

      retour_sur_page
      # sleep 30
      expect(page).to have_tag('ul#files_analyses') do
        with_tag('li',with: {class:'file', id: "file-#{@ftest_id}"})
      end
      within(li_file){click_link 'edit'}
      success 'trouve un lien pour éditer le fichier'

      retour_sur_page
      expect(page).to have_tag('form#edit_file_form')
      success 'peut mettre le fichier en édition'


      contenu_fichier = <<-MD
#### Un titre pour voir

Le paragraphe.

Le deuxième paragraphe.

Le lien vers [Icare](http://www.atelier-icare.net).

Le quatrième paragraphe.
      MD
      contenu_fichier = contenu_fichier.strip

      within('form#edit_file_form') do
        fill_in('file_content', with: contenu_fichier)
      end
      # Sortir du champ d'édition
      page.execute_script('document.querySelector("textarea#file_content").blur();')
      expect(page).to have_tag('h3.warning')
      success 'le titre se met en rouge lorsque l’on modifie le texte'

      within('form#edit_file_form') do
        click_button 'Enregistrer'
      end
      success 'peut entrer un texte et demander l’enregistrement'

      retour_sur_page
      expect(page).not_to have_tag('h3.warning')
      success 'l’enregistrement est confirmé par le fait que le titre est repassé au noir'

      # Noter que c'est le dossier
      expect(File.exist?(@ftest_path)).to eq true
      # On prend le premier fichier
      fversion = Dir["#{@ftest_path}/*.*"].first
      nversion = File.basename(fversion)
      aversion = File.basename(fversion, File.extname(fversion))
      time, uid = aversion.split('-')
      # puts "Path du fichier : #{fversion}"
      # puts "Contenu du file : #{File.read(fversion)}"
      expect(File.read(fversion)).to eq contenu_fichier
      expect(uid).to eq @hANACreator[:id].to_s
      expect(time.to_i).to be > start_time
      success 'le fichier a été créé physiquement, avec le bon nom et le bon contenu'

      # Les contributeurs ne sont pas avertis
      contributors(@film_id).each do |hcont|
        expect(User.get(hcont[:id])).not_to have_mail({
          sent_after: start_time
        })
      end
      success "Aucun contributeur n'a pas été averti du changement"

    end
  end

  context 'Un administratrateur' do
    scenario '=> peut modifier un fichier à sa guise' do

      pending

    end
  end


  scenario '=> deux rédacteurs travaillant en même temps sont avertis' do
    # Le rédacteur vient modifier le fichier
    # TODO

    # Quand le rédacteur veut enregistrer le fichier, on l'avertit que le
    # fichier est en cours d'édition.
    # TODO

    # Quand le créateur de l'analyse enregistre le fichier, on l'avertit
    # que le fichier est en cours d'édition.
    # TODO

    # On se sert de `diff` pour voir la différence
    # TODO

    # C'est le créateur qui choisit ce qu'il faut garder
    # TODO
  end

  scenario '=> l’administrateur peut voir la différence entre deux fichiers' do

    # Le créateur de l'analyse vient modifier le fichier
    expect(File.exist?(@ftest_path)).to eq false

    identify @hANACreator
    visit "#{base_url}/analyser/dashboard/#{@film_id}"

    contenu_fichier = "#### Un titre pour roiv\n\nLe paragraphe.\n\nLe deuxième paragraphe.\n\nLe lien vers [Icare](http://www.atelier-icare).\n\nLe quatrième paragraphe."

    retour_sur_page
    expect(page).to have_tag('li',with: {class:'file', id: "file-#{@ftest_id}"})
    within(li_file) { click_link 'edit' }

    retour_sur_page
    within('form#edit_file_form') do
      fill_in('file_content', with: contenu_fichier)
      click_button 'Enregistrer'
    end
    success 'peut entrer un texte et demander l’enregistrement'

    retour_sur_page
    expect(page).not_to have_tag('h3.warning')
    success 'l’enregistrement est confirmé par le fait que le titre est repassé au noir'

    fichiers = Dir["#{@ftest_path}/*.*"]
    expect(fichiers.count).to eq 1

    within('h3'){click_link /un héros très discret/i}
    retour_sur_page
    expect(page).to have_tag('ul#files_analyses')
    success 'En cliquant sur le titre, il peut revenir au tableau de bord'


    click_link 'se déconnecter'


    # ---------------------------------------------------------------------
    #
    #     LE CORRECTEUR VIENT MODIFIER LE FICHIER
    #
    # ---------------------------------------------------------------------

    identify @hANASimpleCorrector

    visit "#{base_url}/analyser/dashboard/#{@film_id}"
    retour_sur_page
    expect(page).to have_tag('li',with: {class:'file', id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}
    expect(page).to have_tag('form#edit_file_form') do
      with_tag('textarea', with: {id: 'file_content'}, text: /Un titre pour roiv/)
      with_tag('textarea', with: {id: 'file_content'}, text: /Le quatrième paragraphe/)
    end
    success 'le correcteur (Michou) peut lire le texte enregistré par le créateur de l’analyse'

    # Correction de :
    # titre "pour voir"
    # + adresse icare
    contenu_corrected = "#### Un titre pour voir\n\nLe paragraphe.\n\nLe deuxième paragraphe.\n\nLe lien vers [Icare](http://www.atelier-icare.net).\n\nLe quatrième paragraphe."

    within('form#edit_file_form') do
      fill_in('file_content', with: contenu_corrected)
      click_button 'Enregistrer'
    end
    success 'le correcteur corrige le texte et l’enregistre'

    fichiers = Dir["#{@ftest_path}/*.*"]
    expect(fichiers.count).to eq 2

    click_link 'se déconnecter'

    # ---------------------------------------------------------------------
    #
    #     LE CO-RÉDACTEUR VIENT CORRIGER LE FICHIER
    #
    # ---------------------------------------------------------------------

    identify @hANARedacteur

    visit "#{base_url}/analyser/dashboard/#{@film_id}"
    retour_sur_page
    success 'le co-rédacteur vient travailler sur le fichier'

    expect(page).to have_tag('li',with: {class:'file', id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}

    retour_sur_page
    expect(page).to have_tag('form#edit_file_form')
    # Correction de :
    # titre "pour voir"
    # + adresse icare
    contenu_corrected = "#### Un titre pour voir\n\nLe paragraphe est modifié par le créateur.\n\nLe deuxième paragraphe.\n\nLe lien vers [Icare](http://www.atelier-icare.net).\n\nLe quatrième paragraphe pour dire que l'adresse a été corrigée."

    within('form#edit_file_form') do
      fill_in('file_content', with: contenu_corrected)
      click_button 'Enregistrer'
    end
    success 'le co-rédacteur corrige le texte et l’enregistre'

    fichiers = Dir["#{@ftest_path}/*.*"]
    expect(fichiers.count).to eq 3

    click_link 'se déconnecter'
    success 'le co-rédacteur se déconnecte'


    # ---------------------------------------------------------------------
    #
    #     LE CORRECTEUR VIENT REGARDER LES DIFFÉRENCES
    #
    # ---------------------------------------------------------------------

    identify @hANASimpleCorrector

    visit "#{base_url}/analyser/dashboard/#{@film_id}"
    retour_sur_page
    expect(page).to have_tag('li',with: {class:'file', id: "file-#{@ftest_id}"})
    within(li_file){click_link 'edit'}

    expect(page).to have_tag('div', with:{class: 'file_buttons top'}) do
      with_tag('a', with:{href: "analyser/file/#{@ftest_id}?op=compare"}, text: 'compare')
    end
    within('div.file_buttons.top'){ click_link 'compare' }

    retour_sur_page

    # Il va choisir deux fichiers pour les comparer
    fnames = Dir["#{@ftest_path}/*.*"].sort.collect { |f| File.basename(f) }
    version1 = fnames[1]
    version2 = fnames[2]
    within('form#versions_compare_form') do
      choose("v1-#{version1}")
      choose("v2-#{version2}")
      # sleep 30
      click_button 'Comparer'
    end
    success 'le correcteur voit la liste des trois fichiers créés et peut en choisir 2'

    retour_sur_page
    expect(page).to have_tag('div', with: {class: 'comparaison'}) do
      with_tag('div.versions') do
        with_tag('div.green', text: /#{version1}/) do
          with_tag('a', with: {class: 'edit', href: "analyser/file/#{@ftest_id}?op=edit&v=#{version1}"})
        end
        with_tag('div.blue', text: /#{version2}/) do
          with_tag('a', with: {class: 'edit', href: "analyser/file/#{@ftest_id}?op=edit&v=#{version2}"})
        end
      end
      with_tag('div.diffs')
    end
    success 'le correcteur voit la différence entre les deux fichiers'

    within('h3'){click_link /un héros très discret/i}
    retour_sur_page
    expect(page).to have_tag('ul#files_analyses')
    success 'En cliquant sur le titre, le correcteur peut revenir au tableau de bord'

    # sleep 10*60

    # On doit voir les différences entre les deux derniers versions

  end
end
