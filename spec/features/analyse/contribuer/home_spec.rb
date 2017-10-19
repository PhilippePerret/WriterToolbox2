=begin

  Test de la page d'accueil des contributions

=end
require_support_integration
require_support_analyse
require_support_db_for_test
require_support_mail_for_test

protect_biblio

feature 'Accueil de la section de contribution aux analyses de films', check: false do
  before(:each) do
    @start_time = Time.now.to_i
  end
  let(:start_time) { @start_time }

  context 'un visiteur quelconque' do
    scenario '=> trouve une page conforme' do
      visit analyses_page
      click_link('contribuer aux analyses')
      expect(page).to have_tag('h2', text: 'Contribuer aux analyses de films')
      expect(page).to have_tag('a', with:{href: 'aide?p=analyse%2Fcontribuer'})
      success 'il peut rejoindre une page de conbribution valide (avec lien vers l’aide)'

      expect(page).to have_content("Pour contribuer aux analyses, vous devez au préalable vous inscrire sur le site")
      expect(page).to have_tag('a', with:{href:'user/signup', class: 'exergue'}, text: /vous inscrire sur le site/)
      success 'un lien pour rejoindre l’inscription'

      click_link('vous inscrire sur le site')
      expect(page).to have_tag('form#signup_form')
      success 'le visiteur peut rejoindre le formulaire d’inscription'
    end
  end

  context 'un visiteur inscrit' do

    scenario '=> trouve une page de départ de contribution conforme' do
      huser = get_data_random_user(mail_confirmed: true, admin: false, grade: 4, analyste: false)
      v = User.get(huser[:id])

      identify huser
      visit analyses_page
      click_link('contribuer aux analyses')
      expect(page).to have_tag('h2', text: 'Contribuer aux analyses de films')
      success 'il peut rejoindre la page de conbribution'

      t = "Pour contribuer aux analyses, puisque vous êtes déjà inscrit#{v.f_e}, il vous suffit de soumettre une demande de participation."
      expect(page).to have_content(t)
      expect(page).to have_tag('a', with:{href:'analyser/postuler', class: 'exergue'}, text: 'soumettre une demande de participation')
      success 'un lien lui permet de candidater pour les analyses'

      click_link 'soumettre une demande de participation'
      expect(page).to have_tag('h2', text: 'Contribuer aux analyses de films')
      expect(page).to have_tag('p.notice', text:/Votre demande a été transmise/)
        # Note : ce n'est pas un message flash, mais une notice dans la page
      success 'le visiteur peut soumettre sa candidature'

      # sleep 4

      [phil,marion].each do |admin|
        expect(admin).to have_mail({
          sent_after: start_time,
          subject:    'Demande de participation aux analyses de films',
          message:    ["#{huser[:pseudo]}", "##{huser[:id]}","admin/analyse"]
        })
      end
      success 'Les administrateurs ont reçu une demande de participation'

      expect(page).not_to have_link('soumettre une demande de participation')
      expect(page).to have_content('Votre demande a été transmise')
      success 'si l’user ressoumet sa candidature, on lui dit qu’elle est déjà à l’étude'
    end
  end

  context 'un visiteur ayant postulé pour les analyses' do
    scenario '=> trouve une page de départ de contribution conforme' do
      huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: 1)
      v = User.get(huser[:id])

      identify huser
      visit analyses_page
      click_link('contribuer aux analyses')
      expect(page).to have_tag('h2', text: 'Contribuer aux analyses de films')
      success 'il peut rejoindre la page de conbribution'

      expect(page).to have_content("Votre candidature est à l’étude")
      expect(page).not_to have_tag('a', with:{href:'analyser/postuler', class: 'exergue'}, text: 'soumettre une demande de participation')
      success 'On l’informe que sa candidature est à l’étude et aucun lien ne lui permet pas de candidater à nouveau'

    end

  end

  context 'un visiteur participant aux analyses' do

    scenario '=> trouve une page de départ de contribution conforme' do
      huser = get_data_random_user(mail_confirmed: true, admin: false, grade: 4, analyste: true)

      identify huser
      visit analyses_page
      click_link('contribuer aux analyses')
      expect(page).to have_tag('h2', text: 'Contribuer aux analyses de films')
      success 'il peut rejoindre la page de conbribution'

      expect(page).to have_content("Vous êtes analyste")
      expect(page).to have_content("vous pouvez contribuer aux analyses ou en initier")
      success 'la page lui indique qu’il est analyste'
      expect(page).to have_tag('a', with: {href: 'analyser/new'})
      expect(page).to have_tag('a', with: {href: 'analyser/list'})
      success 'la page lui offre des liens pour rejoindre les différentes parties'

    end

  end
end
