=begin

  Test de l'édition d'un fichier

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
    @ftest_extrait  = "C'est un autre paragraphe pour voir"
                      # EXTRAIT du fichier qu'on doit pouvoir retrouver dans la page
                      # Ce doit être une version humaine, sans balise HTML
    @ftest_code = <<-MARKDOWN
    #### Un titre du fichier

    Ceci est un premier paragraphe du fichier d'analyse.

    C'est un autre paragraphe pour voir.
    <!-- Ne pas modifier ce paragraphe ci-dessus qui sert aux tests -->

    On va vers [Icare](http://www.atelier-icare.net) pour s'inscrire.
    MARKDOWN

    # On fabrique ce fichier dans la base, mais on le détruit physiquement
    #
    @ftest_id = site.db.insert(:biblio,'files_analyses',{
      film_id:  @film_id,
      titre:    @ftest_titre,
      specs:    '0100'+'0000'
    })
    site.db.insert(:biblio,'user_per_file_analyse',{
      file_id:  @ftest_id,
      user_id:  @hANACreator[:id],
      role:     1 # le créateur
    })
    # # NON ! NE PAS LE METTRE EN RÉDACTEUR DE CE FICHIER
    # site.db.insert(:biblio,'user_per_file_analyse',{
    #   file_id:  @ftest_id,
    #   user_id:  @hANARedacteur[:id],
    #   role:     2 # en rédacteur
    # })

    # On met Marion en correctrice du fichier (mais elle est
    # aussi administratrice)
    site.db.insert(:biblio,'user_per_file_analyse',{
      file_id:  @ftest_id,
      user_id:  marion.id,
      role:     4 # correctrice
    })

    # On met le correcteur défini par la base comme correcteur du premier
    # fichier
    site.db.insert(
      :biblio, 'user_per_file_analyse',{
        file_id: @ftest_id,
        user_id: @hANASimpleCorrector[:id],
        role: 4
    })

    # Path du premier fichier
    @ftest_path = File.join('.','__SITE__','analyser','_data_','files',"#{@film_id}","#{@ftest_id}.md")
    File.exist?(@ftest_path) && File.unlink(@ftest_path)
    add_file2destroy(@ftest_path)



    # === SECOND FICHIER ====

    @ftest2_titre   = "Un fichier en chantier lisible par tout inscrit"
    @ftest2_extrait = "Paragraphe extrait du second fichier"
    @ftest2_code = <<-MD
    #### LE TITRE DU SECOND FICHIER

    Paragraphe extrait du second fichier.
    <!-- Ne pas modifier ce paragraphe ci-dessus qui sert aux tests -->

    C'est un lien possible mais pas définitif.
    MD

    @ftest2_id = site.db.insert(:biblio,'files_analyses',{
      film_id: @film_id,
      titre:   @ftest2_titre,
      specs:   '0101'+'0000' # lisible
      })
    site.db.use_database(:biblio)
    site.db.execute(
      "INSERT INTO user_per_file_analyse (file_id, user_id, role) VALUES (?, ?, ?)",
      [
        [@ftest2_id, @hANARedacteur[:id] ,1],
        [@ftest2_id, @hANACreator[:id]   ,2] # ce n'est pas le créateur de
                                              # l'analyse le créateur du fichier
      ]
    )

    # Path du second fichier
    @ftest2_path = File.join('.','__SITE__','analyser','_data_','files',"#{@film_id}","#{@ftest2_id}.md")
    File.exist?(@ftest2_path) && File.unlink(@ftest2_path)
    add_file2destroy(@ftest2_path)


  end
  # Fin de la préparation

  before(:each) do
    @start_time = Time.new.to_i
  end
  let(:start_time) { @start_time }






  context 'Un administrateur non contributeur', check: true do
    scenario '=> peut éditer et modifier tous les fichiers' do

      identify marion

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=voir"
      expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
      expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
      expect(page).to have_tag('h4', text: @ftest_titre)
      expect(page).to have_tag('div.file_content')
      if File.exist?(@ftest_path)
        expect(page).to have_content(@ftest_extrait)
      end
      success 'peut voir la page'

      expect(page).to have_tag('div.file_buttons') do
        with_tag('a', text: 'éditer',     with: {href: "analyser/file/#{@ftest_id}?op=edit"})
        with_tag('a', text: 'publier',    with: {href: "analyser/file/#{@ftest_id}?op=publish"})
        with_tag('a', text: 'détruire',   with: {href: "analyser/file/#{@ftest_id}?op=rem"})
      end
      success 'trouve tous les boutons (publication, édition, etc.)'

      expect(page).not_to have_tag('form#edit_file_form')
      within('div.file_buttons.top'){click_link 'éditer'}
      sleep 10
      expect(page).to have_tag('form#edit_file_form')
      success 'clique le bouton « éditer » et passe le fichier en édition'

    end
  end



  context 'Le créateur de l’analyse', check: false do
    scenario '=> peut éditer et modifier tous les fichiers' do

      identify @hANACreator

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------

      (0..1).each do |i|
        suffix = ['', '2'][i]

        fid       = eval("@ftest#{suffix}_id")
        ftitre    = eval("@ftest#{suffix}_titre")
        fpath     = eval("@ftest#{suffix}_path")
        fextrait  = eval("@ftest#{suffix}_extrait")

        visit "#{base_url}/analyser/file/#{fid}?op=voir"
        expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
        expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
        expect(page).to have_tag('h4', text: ftitre)
        expect(page).to have_tag('div.file_content')
        if File.exist?(fpath)
          expect(page).to have_content(fextrait)
        end
        success 'il peut voir la page'

        expect(page).to have_tag('div.file_buttons') do
          with_tag('a', text: 'éditer',       with: {href: "analyser/file/#{fid}?op=edit"})
          with_tag('a', text: 'publier',      with: {href: "analyser/file/#{fid}?op=publish"})
          with_tag('a', text: 'détruire',     with: {href: "analyser/file/#{fid}?op=rem"})
        end
        success 'il trouve tous les boutons (publication, édition, etc.)'

      end
      #/ loop sur chaque fichier
    end
  end



  context 'Un contributeur rédacteur', check: false do
    scenario '=> peut éditer et modifier tous les fichiers qu’il rédige' do

      identify @hANARedacteur

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------
      visit "#{base_url}/analyser/file/#{@ftest2_id}?op=voir"
      expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
      expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
      expect(page).to have_tag('h4', text: @ftest2_titre)
      expect(page).to have_tag('div.file_content')
      if File.exist?(@ftest2_path)
        expect(page).to have_content(@ftest2_extrait)
      end
      success 'peut voir la page'

      expect(page).to have_tag('div.file_buttons') do
        with_tag('a', text: 'éditer',   with: {href: "analyser/file/#{@ftest2_id}?op=edit"})
        with_tag('a', text: 'publier',  with: {href: "analyser/file/#{@ftest2_id}?op=publish"})
        with_tag('a', text: 'détruire', with: {href: "analyser/file/#{@ftest2_id}?op=rem"})
      end
      success 'trouve tous les boutons (publication, édition, etc.)'

    end
    scenario '=> ne peut pas éditer ou modifier les autres fichiers' do

      identify @hANARedacteur

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------

      visit "#{base_url}/analyser/file/#{@ftest_id}?op=voir"

      expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
      expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
      expect(page).to have_tag('h4', text: @ftest_titre)
      expect(page).to have_tag('div.file_content', text: /Vous n’avez pas accès au contenu de ce fichier/)
      success 'peut voir la page (sans le texte)'

      expect(page).to have_tag('div.file_buttons') do
        without_tag('a', text: 'éditer',   with: {href: "analyser/file/#{@ftest_id}?op=edit"})
        without_tag('a', text: 'publier',  with: {href: "analyser/file/#{@ftest_id}?op=publish"})
        without_tag('a', text: 'détruire', with: {href: "analyser/file/#{@ftest_id}?op=rem"})
      end
      success 'ne trouve pas tous les boutons (publication, édition, etc.)'

    end
  end



  context 'Un contributeur correcteur', check: false do
    scenario '=> peut éditer et modifier tous les fichiers où il est en correcteur' do

      identify @hANASimpleCorrector

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=voir"
      expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
      expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
      expect(page).to have_tag('h4', text: @ftest_titre)
      expect(page).to have_tag('div.file_content')
      if File.exist?(@ftest_path)
        expect(page).to have_content(@ftest_extrait)
      end
      success 'il peut voir la page'

      expect(page).to have_tag('div.file_buttons') do
        with_tag('a', text: 'éditer',       with: {href: "analyser/file/#{@ftest_id}?op=edit"})
        with_tag('a', text: 'publier',      with: {href: "analyser/file/#{@ftest_id}?op=publish"})
        without_tag('a', text: 'détruire',  with: {href: "analyser/file/#{@ftest_id}?op=rem"})
      end
      success 'il trouve tous les boutons (publication, édition, etc.)'

    end

    scenario '=> ne peut pas éditer ou modifier les autres fichiers mais il peut les voir en entier' do

      identify @hANASimpleCorrector

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------
      visit "#{base_url}/analyser/file/#{@ftest2_id}?op=voir"
      expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
      expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
      expect(page).to have_tag('h4', text: @ftest2_titre)
      if File.exists?(@ftest2_path)
        expect(page).to have_content(@ftest2_extrait)
      end
      success 'peut voir la page complète du fichier'

      expect(page).to have_tag('div.file_buttons') do
        without_tag('a', text: 'éditer',     with: {href: "analyser/file/#{@ftest2_id}?op=edit"})
        without_tag('a', text: 'publier',    with: {href: "analyser/file/#{@ftest2_id}?op=publish"})
        without_tag('a', text: 'détruire',   with: {href: "analyser/file/#{@ftest2_id}?op=rem"})
      end
      success 'ne trouve pas tous les boutons (publication, édition, etc.)'
    end
  end


  context 'Un analyse non contributeur', check: false do
    scenario '=> ne peut rien faire sur un fichier que le voir s’il est lisible' do

      identify @hBenoit

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------
      ['voir','edit','publish','rem'].each do |ope|
        visit "#{base_url}/analyser/file/#{@ftest2_id}?op=#{ope}"
        expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
        expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
        expect(page).to have_tag('h4', text: @ftest2_titre)
        expect(page).to have_tag('div', with:{class: 'file_content', id:"file-#{@ftest2_id}-content"})

        expect(page).to have_tag('div.file_buttons') do
          without_tag('a', text: 'éditer',    with: {href: "analyser/file/#{@ftest2_id}?op=edit"})
          without_tag('a', text: 'publier',   with: {href: "analyser/file/#{@ftest2_id}?op=publish"})
          without_tag('a', text: 'détruire',  with: {href: "analyser/file/#{@ftest2_id}?op=rem"})
        end
      end
      success 'peut voir la page avec le texte sans autres boutons pour toutes les tentatives'

    end

    scenario '=> ne peut rien faire sur un fichier que voir son titre s’il n’est pas visible' do
      identify @hBenoit

      # ---------------------------------------------------------------------
      #     LA PAGE DU FICHIER
      # ---------------------------------------------------------------------
      ['voir','edit','publish','rem'].each do |ope|
        visit "#{base_url}/analyser/file/#{@ftest_id}?op=#{ope}"
        expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
        expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
        expect(page).to have_tag('h4', text: @ftest_titre)
        expect(page).to have_tag('div.file_content', text: /Vous n’avez pas accès au contenu de ce fichier/)
        expect(page).to have_tag('div.file_buttons') do
          without_tag('a', text: 'éditer',    with: {href: "analyser/file/#{@ftest_id}?op=edit"})
          without_tag('a', text: 'publier',   with: {href: "analyser/file/#{@ftest_id}?op=publish"})
          without_tag('a', text: 'détruire',  with: {href: "analyser/file/#{@ftest_id}?op=rem"})
        end
      end
      success 'peut voir la page sans le texte'
      success 'ne trouve pas tous les boutons (publication, édition, etc.)'
    end
  end

  context 'Un simple inscrit', check: false do
    scenario '=> ne peut rien faire d’autre sur les fichiers que les visualiser' do

      huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: false)
      identify huser

      ['edit', 'rem','publish'].each do |ope|
        visit "#{base_url}/analyser/file/#{@ftest_id}?op=#{ope}"
        expect(page).to have_tag('div.error', text: /La seule action possible pour un simple inscrit/)
        expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
        expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
        expect(page).to have_tag('h4', text: @ftest_titre)
        # Pas de contenu pour ce fichier puisqu'il n'est pas visible
        expect(page).to have_tag('div.file_content', text: /Vous n’avez pas accès au contenu de ce fichier/)

        expect(page).to have_tag('div.file_buttons') do
          without_tag('a', text: 'éditer')
          without_tag('a', text: 'publier')
          without_tag('a', text: 'détruire')
        end
      end

      visit "#{base_url}/analyser/file/#{@ftest_id}?op=voir"
      expect(page).to have_tag('h2', text:/Contribuer aux analyses/)
      expect(page).not_to have_tag('div.error')
      expect(page).to have_tag('h3', text: /#{@titre_analyse}/i)
      expect(page).to have_tag('h4', text: @ftest_titre)
      expect(page).not_to have_tag('file_content')
      success 'peut voir la page'
      expect(page).to have_tag('div.file_buttons') do
        without_tag('a', text: 'éditer')
        without_tag('a', text: 'publier')
        without_tag('a', text: 'détruire')
      end

      # En revanche, le second fichier peut avoir du contenu
      ['edit', 'rem','publish', 'voir'].each do |ope|
        visit "#{base_url}/analyser/file/#{@ftest2_id}?op=#{ope}"
        expect(page).to have_tag('div', with:{class: 'file_content', id: "file-#{@ftest2_id}-content"})
      end

      expect(page).to have_link('Contribuer')
      expect(page).to have_link('Postuler pour devenir analyste')
      success 'trouve aussi un lien pour postuler'

    end
  end

  context 'Un simple visiteur', check: false do
    scenario '=> ne peut rien faire sur les fichiers' do
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=voir"
      expect(page).to be_signin_page
      expect(page).to have_tag('div.notice', text: /Pour atteindre la page demandée, vous devez être identifié/i)
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=edit"
      expect(page).to be_signin_page
      expect(page).to have_tag('div.notice', text: /Pour atteindre la page demandée, vous devez être identifié/i)
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=save"
      expect(page).to be_signin_page
      expect(page).to have_tag('div.notice', text: /Pour atteindre la page demandée, vous devez être identifié/i)
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=rem"
      expect(page).to be_signin_page
      expect(page).to have_tag('div.notice', text: /Pour atteindre la page demandée, vous devez être identifié/i)
      visit "#{base_url}/analyser/file/#{@ftest_id}?op=publish"
      expect(page).to be_signin_page
      expect(page).to have_tag('div.notice', text: /Pour atteindre la page demandée, vous devez être identifié/i)
    end
  end

end
