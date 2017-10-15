=begin

  Test de la validation ou du refus par un administrateur d'une
  candidature de user

=end
require_lib_site
require_support_integration
require_support_mail_for_test

feature 'Validation ou refus de contribution aux analyses' do
  before(:each) do
    @start_time = Time.now.to_i
  end
  let(:start_time) { @start_time }

  scenario 'Un administrateur peut valider la candidature d’un analyste' do
    hcandidat = get_data_random_user(mail_confirmed: true, admin: false, analyste: 1)

    identify marion
    visit "#{base_url}/admin/analyse"
    # sleep 5

    expect(page).to have_tag('h2', 'Tableau de bord des analyses de films')
    expect(page).to have_tag('fieldset', with: {id: 'candidatures'}) do
      with_tag('legend', text: 'Candidatures aux analyses de films')
      with_tag("ul#candidats") do
        with_tag('li', with: {class: 'candidat', id: "candidat-#{hcandidat[:id]}"}) do
          with_tag('a', with: {href: "admin/analyse/#{hcandidat[:id]}?op=valider_candidature"}, text: 'valider')
          with_tag('a', text: 'refuser')
        end
      end
    end
    success 'Marion peut rejoindre le dashboard d’analyse et trouver la candidature'

    within("li#candidat-#{hcandidat[:id]}"){click_link 'valider'}
    expect(page).to have_tag('div.notice', text: "La candidature de #{hcandidat[:pseudo]} (##{hcandidat[:id]}) a été acceptée.")
    success 'Marion valide la candidature avec succès'
    candidat = User.get(hcandidat[:id])
    expect(candidat).to have_mail({
      sent_after: start_time,
      sujet:      "Votre candidature aux analyses a été acceptée !",
      message:    ["par où commencer"]
    })
    success 'le candidat a été prévenu par mail'
  end

  scenario 'Un administrateur peut refuser une candidature' do
    hcandidat = get_data_random_user(mail_confirmed: true, admin: false, analyste: 1)

    identify marion
    visit "#{base_url}/admin/analyse"
    sleep 1

    motif_refus = "Le motif du refus.\n\nLa **deuxième ligne**.\n\nLa troisième ligne."

    within("li#candidat-#{hcandidat[:id]}"){click_link 'refuser'}
    # Ça doit ouvrir le formulaire
    within("form#refus_form-#{hcandidat[:id]}") do
      fill_in('motif_refus', with: motif_refus)
    end
    expect(page).to have_tag('div.notice', "La candidature de #{hcandidat[:pseudo]} (##{hcandidat[:id]}) a été refusée")
    success 'Marion refuse la candidature avec succès'

    candidat = User.get(hcandidat[:id])
    expect(candidat).to have_mail({
      sent_after: start_time,
      sujet:      "Votre candidature aux analyses a été rejetée",
      message: ["<p>Le motif du refus.</p><p>La <strong>deuxième ligne</strong>.</p><p>La troisième ligne.</p>"]
    })
    success 'le candidat a été prévenu par mail du refus'

  end
end
