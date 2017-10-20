=begin

  Test de l'ajout d'un fichier à une analyse

=end
require_lib_site
require_support_integration
require_support_mail_for_test
require_support_db_for_test

feature 'Ajout d’un fichier à une analyse' do
  before(:all) do

    # Si on passe par ici, il faut absolument protéger les données biblio qui
    # vont être modifiées. On doit les sauver si nécessaire et demander leur
    # rechargement.
    backup_base_biblio # seulement si nécessaire
    protect_biblio

    remove_mails

    @film_id = 180 # Un héros très discret

  end

  before(:each) do
    @start_time = Time.new.to_i
  end
  let(:start_time) { @start_time }

  context 'Un administrateur' do

  end




  context 'Le créateur de l’analyse' do
    scenario '=> peut créer un fichier' do
      hs = site.db.select(:biblio,'user_per_analyse', 'role & 32').first
      analyse_id  = hs[:film_id]
      analyste_id = hs[:user_id]
      hanalyste = get_data_user(analyste_id)
      opts = hanalyste[:options]
      if opts[16].to_i != 3
        opts = opts.ljust(17,'0')
        opts[16] = '3'
        site.db.update(:hot,'users',{options: opts},{id: hanalyste[:id]})
      end

      # puts "Analyste id : #{hanalyste[:id]} (#{hanalyste[:pseudo]})"
      # puts "Analyse ID : #{analyse_id}"

      # =========== PRÉ-VÉRIFICATIONS ===========
      nombre_fichiers_init = site.db.count(:biblio,'files_analyses', {film_id: analyse_id})

      identify hanalyste
      visit "#{base_url}/analyser/dashboard/#{analyse_id}"

      # ===============> TEST <==============
      expect(page).to have_tag('h2') do
        with_tag('a', text: 'Contribuer')
        with_tag('a', text: 'analyses de films')
      end
      expect(page).to have_tag('fieldset#fs_files') do
        with_tag('ul#files_analyses')
        with_tag('div#files_buttons') do
          with_tag('a', text: '+')
        end
        # without_tag('form#new_file_form')
      end
      success 'trouve le bouton pour créer un nouveau fichier'

      within('fieldset#fs_files div#files_buttons') do
        click_link('+')
      end
      expect(page).to have_tag('fieldset#fs_files') do
        with_tag('form#new_file_form', visible: true)
      end
      success 'en cliquant sur le bouton, fait apparaitre le formulaire'

      file_titre = "Un fichier à #{Time.now.to_i}"
      within('form#new_file_form') do
        fill_in('file_titre', with: file_titre)
        # On garde le type par défaut
        click_button 'Ajouter ce fichier'
      end
      success 'remplit le formulaire et le soumet'
      # sleep 10


      # ========== VÉRIFICATION ============
      expect(page).not_to be_home_page
      nombre_fichiers_apres = site.db.count(:biblio,'files_analyses', {film_id: analyse_id})
      expect(nombre_fichiers_apres).to eq nombre_fichiers_init + 1
      where = "film_id = #{analyse_id} AND created_at > #{start_time}"
      hfiledb = site.db.select(:biblio,'files_analyses',where).first
      expect(hfiledb[:created_at]).to be > start_time

      hupf = site.db.select(:biblio,'user_per_file_analyse',{file_id: hfiledb[:id]}).first
      expect(hupf).not_to eq nil
      expect(hupf[:user_id]).to eq hanalyste[:id]
      expect(hupf[:created_at]).to be > start_time
      success 'un nouveau fichier a été créé (et lié à un user) dans la base de données avec les bonnes données'

      # Le fichier n'a pas encore été créé en dur
      expect(File.exist?("./__SITE__/analyser/_data_/files/#{analyse_id}/#{hfiledb[:id]}.md")).to eq false
      success 'le fichier physique n’existe pas encore'

      expect(page).to have_tag('ul#files_analyses') do
        with_tag('li', with: {class: 'file', id: "file-#{hfiledb[:id]}"}) do
          with_tag('span', text: file_titre)
        end
      end
      success 'le fichier apparait dans la liste des fichiers'

      creator = User.get(hanalyste[:id])
      expect(creator).not_to have_mail({
        sent_after: start_time,
        subject: "Nouveau fichier créé sur votre analyse",
        })
      success 'le créateur ne reçoit aucun message '

      mdata = {
        sent_after: start_time,
        subject: "Nouveau fichier sur une analyse à laquelle vous contribuez",
        message: ["analyser/dashboard/#{analyse_id}", "analyser/file/#{hfiledb[:id]}"]
      }
      site.db.select(:biblio,'user_per_analyse',{film_id: analyse_id})
        .each do |hcont|
          hcont[:role] & 32 > 0 && next
          cont = User.get(hcont[:user_id])
          expect(cont).to have_mail(mdata)
      end
      success 'les contributors sauf le créateur reçoivent tous un message'

    end
  end




  context 'Un contributeur de l’analyse' do
    scenario '=> peut créer un fichier' do
      where = "NOT( role & 32 )"
      hs = site.db.select(:biblio,'user_per_analyse', where).first
      analyse_id  = hs[:film_id]
      analyste_id = hs[:user_id]
      hanalyste = get_data_user(analyste_id)
      opts = hanalyste[:options]
      if opts[16].to_i != 3
        opts = opts.ljust(17,'0')
        opts[16] = '3'
        site.db.update(:hot,'users',{options: opts},{id: hanalyste[:id]})
      end

      # puts "Analyste id : #{hanalyste[:id]} (#{hanalyste[:pseudo]})"
      # puts "Analyse ID : #{analyse_id}"

      # =========== PRÉ-VÉRIFICATIONS ===========
      nombre_fichiers_init = site.db.count(:biblio,'files_analyses', {film_id: analyse_id})

      identify hanalyste
      visit "#{base_url}/analyser/dashboard/#{analyse_id}"

      # ===============> TEST <==============
      expect(page).to have_tag('h2') do
        with_tag('a', text: 'Contribuer')
        with_tag('a', text: 'analyses de films')
      end
      expect(page).to have_tag('fieldset#fs_files') do
        with_tag('ul#files_analyses')
        with_tag('div#files_buttons') do
          with_tag('a', text: '+')
        end
        # without_tag('form#new_file_form')
      end
      success 'trouve le bouton pour créer un nouveau fichier'

      within('fieldset#fs_files div#files_buttons') do
        click_link('+')
      end
      expect(page).to have_tag('fieldset#fs_files') do
        with_tag('form#new_file_form', visible: true)
      end
      success 'en cliquant sur le bouton, fait apparaitre le formulaire'

      file_titre = "Un fichier à #{Time.now.to_i}"
      within('form#new_file_form') do
        fill_in('file_titre', with: file_titre)
        # On garde le type par défaut
        click_button 'Ajouter ce fichier'
      end
      success 'remplit le formulaire et le soumet'
      # sleep 10


      # ========== VÉRIFICATION ============
      expect(page).not_to be_home_page
      nombre_fichiers_apres = site.db.count(:biblio,'files_analyses', {film_id: analyse_id})
      expect(nombre_fichiers_apres).to eq nombre_fichiers_init + 1
      where = "film_id = #{analyse_id} AND created_at > #{start_time}"
      hfiledb = site.db.select(:biblio,'files_analyses',where).first
      expect(hfiledb[:created_at]).to be > start_time

      hupf = site.db.select(:biblio,'user_per_file_analyse',{file_id: hfiledb[:id]}).first
      expect(hupf).not_to eq nil
      expect(hupf[:user_id]).to eq hanalyste[:id]
      expect(hupf[:created_at]).to be > start_time
      success 'un nouveau fichier a été créé (et lié à un user) dans la base de données avec les bonnes données'

      # Le fichier n'a pas encore été créé en dur
      expect(File.exist?("./__SITE__/analyser/_data_/files/#{analyse_id}/#{hfiledb[:id]}.md")).to eq false
      success 'le fichier physique n’existe pas encore'

      expect(page).to have_tag('ul#files_analyses') do
        with_tag('li', with: {class: 'file', id: "file-#{hfiledb[:id]}"}) do
          with_tag('span', text: file_titre)
        end
      end
      success 'le fichier apparait dans la liste des fichiers'

      where = "film_id = #{analyse_id} AND role & 32 LIMIT 1"
      hcreator = site.db.select(:biblio,'user_per_analyse',where).first
      creator = User.get(hcreator[:user_id])
      expect(creator).to have_mail({
        sent_after: start_time,
        subject: "Nouveau fichier créé sur votre analyse",
        message: [
          hanalyste[:pseudo], "analyser/file/#{hfiledb[:id]}", hfiledb[:titre],
          "analyser/dashboard/#{analyse_id}"
        ]
        })
      success 'un message avertit le créateur'

      mdata = {
        sent_after: start_time,
        subject: "Nouveau fichier sur une analyse à laquelle vous contribuez",
        message: ["analyser/dashboard/#{analyse_id}", "analyser/file/#{hfiledb[:id]}"]
      }
      site.db.select(:biblio,'user_per_analyse',{film_id: analyse_id})
        .each do |hcont|
          cont = User.get(hcont[:user_id])
          if hcont[:user_id] == hanalyste[:id]
            # Le dépositeur du fichier ne reçoit pas de mail
            expect(cont).not_to have_mail(mdata)
          else
            expect(cont).to have_mail(mdata)
          end
      end
      success 'les contributors sauf le créateur reçoivent tous un message'

    end
  end
  context 'Un analyste non contributeur' do
    scenario '=> ne peut pas créer un fichier pour l’analyse' do
      huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)
      # Trouver une analyse à laquelle ne collabore pas l'user
      ids = site.db.select(:biblio,'user_per_analyse',{user_id: huser[:id]},[:film_id])
              .collect{|h| h[:film_id]}
      ana_id =
        if ids.count == 0 # l'user ne participe à aucune analyse, on peut garder la même
          @film_id
        else
          where = "id NOT IN (#{ids.join(', ')})"
          site.db.select(:biblio,'films_analyses',where,[:id])[0][:id]
        end
      identify huser
      visit "#{base_url}/analyser/dashboard/#{ana_id}?op=add_file"
      expect(page).to be_home_page
      expect(page).to have_tag('div.error', text: /Vous n’êtes pas en mesure d’accomplir cette opération…/)
    end
  end
  context 'Un inscrit non analyste' do
    scenario '=> ne peut pas créer un fichier pour une analyse en forçant l’URL' do
      huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: false)
      identify huser
      visit "#{base_url}/analyser/dashboard/#{@film_id}?op=add_file"
      expect(page).to be_home_page
      expect(page).to have_tag('div.error', text: /Vous n’êtes pas en mesure d’accomplir cette opération…/)
    end
  end

  context 'Un simple visiteur' do
    scenario '=> ne peut pas créer un fichier pour une analyse en forçant l’URL' do
      visit "#{base_url}/analyser/dashboard/#{@film_id}?op=add_file"
      expect(page).to be_home_page
      expect(page).to have_tag('div.error', text: /Vous n’êtes pas en mesure d’accomplir cette opération…/)
    end
  end

end
