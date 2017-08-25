=begin

  Ce test permet de tester manuelle l'inscription au programme UN AN UN SCRIPT

  Il inscrit un nouvel utilisateur (une) puis s'arrête au bouton de paiement
  de paypal, pour essayer manuellement le paiement.

  L'opération est réussie si on revient sur une page de confirmation de
  l'inscription.

=end
require_support_integration
require_support_db_for_test

feature "Inscription au programme UN AN UN SCRIPT" do

  scenario 'Un visiteur quelconque peut s’inscrire au programme' do
    success_tab('  ')

    visit home_page
    expect(page).to have_link('outils')
    success 'le visiteur trouve un lien vers les outils'

    click_link 'outils'
    expect(page).to have_tag('h2', text: 'Outils d’écriture')
    expect(page).to have_link('Le programme UN AN UN SCRIPT')
    success 'le visiteur trouve la page des outils et un lien vers le programme'

    click_link 'Le programme UN AN UN SCRIPT'
    expect(page).to have_tag('h2', text: 'Le programme UN AN UN SCRIPT')
    expect(page).to have_link('S’inscrire au programme')
    success 'le visiteur trouve un lien pour s’inscrire au programme'

    click_link('S’inscrire au programme', match: :first)
    expect(page).to have_tag('h2', 'S’inscrire sur le site')
    expect(page).to have_selector('form#signup_form')
    expect(page).to have_tag('div.notice', text: /Vous devez au préalable vous inscrire au site lui-même/)

    # Remplissage du formulaire
    password = 'unanmotdepasse'
    duser = get_data_for_new_user(password: password)
    duser.merge!(captcha: '366', password: password)

    within('form#signup_form') do
      [
        :pseudo, :patronyme, :mail, :password, :sexe, :captcha
      ].each do |key|
        case key
        when :mail, :password
          fill_in "user_#{key}_confirmation", with: duser[key]
          fill_in "user_#{key}", with: duser[key]
        when :sexe
          within('select#user_sexe') do
            find("option[value=\"#{duser[:sexe]}\"]").click
          end
        else
          fill_in "user_#{key}", with: duser[key]
        end
      end
      click_button "S’inscrire"
    end

    # sleep 2 # pour voir un peu
    expect(page).to have_link('se déconnecter')
    success 'le visiteur s’inscrit avec succès au site'

    expect(page).to have_tag('h2', text: 'S’inscrire au programme UN AN UN SCRIPT')
    expect(page).to have_selector('div#paypal-button-container')
    success 'le visiteur est retourné au formulaire d’inscription au programme'

    # ICI, je ne sais pas comment gérer le clic sur le bouton de paiement,
    # puisqu'il se trouve sur une frame qui n'est même pas accessible. Donc,
    # je dois essayer manuellement cette partie là.

    10.times do |i|
      puts "TESTER MANUELLEMENT LE PAIEMENT AU PROGRAMME UN AN UN SCRIPT (#{i}/10)"
      sleep 60
    end

  end

end
