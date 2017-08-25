
require_lib_site
require_lib_uaus

require_support_integration
require_support_db_for_test

feature "Inscription au programme UN AN UN SCRIPT" do

  scenario 'Un visiteur quelconque peut s’inscrire au programme' do

    start_time = Time.now.to_i

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


    res = site.db.select(:hot, 'users', {mail: duser[:mail]}).first
    newU = User.new(res)

    # sleep 2 # pour voir un peu
    expect(page).to have_link('se déconnecter')
    success "le visiteur ##{newU.id} (#{newU.pseudo}/#{newU.mail}) s’inscrit avec succès au site"

    expect(page).to have_tag('h2', text: 'S’inscrire au programme UN AN UN SCRIPT')
    expect(page).to have_selector('div#paypal-button-container')
    success 'le visiteur est retourné au formulaire d’inscription au programme'

    # ICI, je ne sais pas comment gérer le clic sur le bouton de paiement,
    # puisqu'il se trouve sur une frame qui n'est même pas accessible. Donc,
    # j'essayerai manuellement cette partie là, avec un script juste pour ça,
    # qui m'amène jusqu'ici avec un nouvel user.
    # Pour le moment, je simule la réussite du paiement en visitant l'adresse
    # 'unanunscript/signup/1'

    visit "http://#{site.url}/unanunscript/signup/1"

    expect(page).to have_tag('h2', text: 'Inscription réussie !')
    expect(page).to have_content("vous êtes maintenant inscrite au programme")


    # Le paiement a dû être enregistré dans la table des paiements
    # (détruire la table des paiements en début de test)
    res = site.db.select(:cold, 'paiements', "objet_id = '1UN1SCRIPT' AND user_id = #{newU.id} AND created_at > #{start_time}")
    res = res.first
    expect(res).not_to eq nil
    expect(res[:montant]).to eq Uaus.tarif
    success 'Le paiement a été enregistré dans la base de données'

    expect(newU).to have_mail(
      subject:    'Inscription au programme UN AN UN SCRIPT',
      sent_after: start_time,
      message: [
        newU.pseudo, "J’ai le plaisir de vous confirmer votre inscription au programme UN AN UN SCRIPT",
        '<a href="http://www.laboiteaoutilsdelauteur.fr/unanunscript/aide">Aide du programme UN AN UN SCRIPT</a>'
      ]
    )
    success 'la visiteuse a reçu un mail lui confirmant son inscription'

    expect(phil).to have_mail(
      subject:      'Nouvelle inscription au programme UN AN UN SCRIPT',
      sent_after:   start_time,
      message:      [newU.pseudo, newU.mail, "##{newU.id}"]
    )
    success 'l’administrateur a reçu un mail annonçant l’inscription'

    failure 'Un nouveau programme est créé avec les bonnes données'

    failure 'Un nouveau projet est créé, avec les bonnes données'

    failure 'Le nouveau programme est annoncé en page d’accueil'
  end

end