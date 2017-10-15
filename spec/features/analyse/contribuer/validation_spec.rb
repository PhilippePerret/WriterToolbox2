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
    sleep 30
    expect(page).to have_tag('h2', 'Tableau de bord des analyses de films')
    expect(page).to have_tag('fieldset', with: {id: 'candidatures'}) do
      with_tag('legend', text: 'Candidature aux analyses de films')
      with_tag("ul.candidats") do
        with_tag('li', with: {class: 'candidat', id: "candidat-#{hcandidat[:id]}"}) do
          with_tag('a', with: {href: "admin/analyse/#{hcandidat}?op=valider_candidature"}, text: 'valider')
          with_tag('a', with: {href: "admin/analyse/#{hcandidat}?op=refuser_candidature"}, text: 'refuser')
        end
      end
    end
    success 'Marion peut rejoindre le dashboard d’analyse et trouver la candidature'

    within("li#candidat-#{hcandidat[:id]}"){click_link 'valider'}
    expect(page).to have_tag('div.notice', "La candidature de #{hcandidat[:pseudo]} a été validée")
    success 'Marion valide la candidature avec succès'
    candidat = User.get(hcandidat[:id])
    expect(candidat).to have_mail({
      sent_after: start_time,
      sujet:      "Votre candidature aux analyses a été acceptée !",
      message:    ["comment commencer ?"]
    })
    success 'le candidat a été prévenu par mail'
  end

  scenario 'Un administrateur peut refuser une candidature' do
    pending
  end
end
