=begin

  Test du réglage des specs de l'analyse

=end

require_lib_site
require_support_integration
require_support_db_for_test
require_support_analyse
require_support_mail_for_test

feature 'Réglages de l’analyse' do

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

  end

  before do
    @start_time = Time.now.to_i
  end
  let(:start_time) { @start_time }


  scenario '=> Un administrateur peut régler toutes les analyses' do

    identify marion
    visit "#{base_url}/analyser/dashboard/#{@film_id}"
    expect(page).to have_tag('fieldset#fs_specs') do
      with_tag('form', with: {id: 'analyse_specs_form'})
    end

  end

  scenario '=> Le créateur de l’analyse peut régler son analyse' do

    huser = @hANACreator

    identify huser
    visit "#{base_url}/analyser/dashboard/#{@film_id}"
    expect(page).to have_tag('fieldset#fs_specs') do
      with_tag('form', with: {id: 'analyse_specs_form'})
    end

  end

  scenario '=> Un non créateur de l’analyse ne peut pas régler une analyse' do
    pending
  end

  scenario '=> Un simple inscrit ne peut pas venir régler une analyse' do
    hinsc = get_data_random_user(analyste: false, admin: false)
    visit "#{base_url}/analyser/dashboard/4"
    expect(page).to have_tag('fieldset#fs_specs') do
      without_tag('form', with: {id: 'analyse_specs_form'})
    end
  end
  scenario '=> Un simple visiteur ne peut pas régler une analyse' do
    visit "#{base_url}/analyser/dashboard/4"
    expect(page).to be_signin_page
    expect(page).to have_tag('div.notice', text: /vous devez vous identifier/i)
  end
end
