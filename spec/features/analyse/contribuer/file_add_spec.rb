=begin

  Test de l'ajout d'un fichier à une analyse

=end
require_lib_site
require_support_integration

feature 'Ajout d’un fichier à une analyse' do
  before(:all) do
    @film_id = 180 # Un héros très discret
  end
  context 'Un administrateur' do

  end
  context 'Le créateur de l’analyse' do

  end
  context 'Un contributeur de l’analyse' do
    scenario '=> peut créer un fichier' do
      where = "NOT( role & 32 )"
      hs = site.db.select(:biblio,'user_per_analyse',where).first
      analyse_id = hs[:film_id]
      analyste_id = hs[:user_id]
      hanalyste = get_data_user(analyste_id)

      # =========== PRÉ-VÉRIFICATIONS ===========
      nombre_fichiers_init = site.db.count(:biblio,'files_analyses', {film_id: analyse_id})

      identify hanalyste
      visit "#{base_url}/analyser/dashboard/#{analyse_id}"
      sleep 5

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
        without_tag('form#new_file_form', visible: true)
      end
      success 'il trouve le bouton pour créer un nouveau fichier'

      within('fieldset#fs_files div#files_buttons') do
        click_link('+')
      end
      expect(page).to have_tag('fieldset#fs_files') do
        with_tag('form#new_file_form', visible: true)
      end
      success 'en cliquant sur le bouton + il fait apparaitre le formulaire'

      file_titre = "Un fichier à #{Time.now.to_i}"
      within('form#new_file_form') do
        fill_in('file_titre', with: file_titre)
        # On garde le type par défaut
        click_button 'Ajouter ce fichier'
      end
      success 'il remplit le formulaire et le soumet'


      # ========== VÉRIFICATION ============
      # Le fichier a dû être créé
      expect(page).not_to be_home_page
      nombre_fichiers_apres = site.db.count(:biblio,'files_analyses', {film_id: analyse_id})
      expect(nombre_fichiers_apres).to eq nombre_fichiers_init + 1
      where = "film_id = #{analyse_id} AND created_at > #{start_time}"
      hfiledb = site.db.select(:biblio,'files_analyses',where).first
      expect(hfiledb[:user_id]).to eq hanalyste[:id]
      success 'un nouveau fichier a été créé dans la base de données avec les bonnes données'

      # Le fichier n'a pas encore été créé en dur
      expect(File.exist?("./__SITE__/analyser/_data_/files/#{analyse_id}/#{hfiledb[:id]}.md")).to eq false
      success 'le fichier physique n’existe pas encore'

      expect(page).to have_tag('ul#files_analyses') do
        with_tag('li', with: {class: 'file', id: "file-#{hfiledb[:id]}"}) do
          with_tag('span', text: file_titre)
        end
      end
      success 'le fichier apparait dans la liste des fichiers'

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
