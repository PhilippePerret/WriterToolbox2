
require_lib_site
require_lib_uaus

require_support_integration
require_support_db_for_test
require_support_mails_for_test

feature "Abonnement au site" do
  before(:all) do
    remove_mails
  end

  scenario '=> Un visiteur quelconque peut s’abonner' do

    start_time = Time.now.to_i

    success_tab('  ')

    visit home_page
    expect(page).to have_link('s’abonner')
    success 'le visiteur à l’accueil un lien s’abonner'

    click_link('s’abonner', match: :first)
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

    # sleep 4 # pour voir un peu
    expect(page).to have_link('se déconnecter')
    success "le visiteur ##{newU.id} (#{newU.pseudo}/#{newU.mail}) s’inscrit avec succès au site"

    expect(page).to have_tag('h2', text: 'Soutenir le site')
    expect(page).to have_selector('div#paypal-button-container')
    success 'le visiteur est retourné au formulaire d’abonnement'

    tarif = site.configuration.tarif

    expect(page).to have_tag('span', with:{class:'tarif'}, text: "#{tarif} €")
    expect(page).to have_tag('div#indication_tarif > div', text: /offre un an d’accès complet/)
    success 'Il trouve un message de paiement correct, avec le bon tarif'

    # ICI, je ne sais pas comment gérer le clic sur le bouton de paiement,
    # puisqu'il se trouve sur une frame qui n'est même pas accessible. Donc,
    # j'essayerai manuellement cette partie là, avec un script juste pour ça,
    # qui m'amène jusqu'ici avec un nouvel user.
    # Pour le moment, je simule la réussite du paiement en visitant l'adresse
    # 'unanunscript/signup/1'
    prenom, nom = newU.get(:patronyme).split(' ')


    visit "http://#{site.url}/user/suscribe/1?"+
    "state=approved&status=VERIFIED&montant=#{tarif}&montant_total=#{tarif}" +
    '&montant_id=HFJDHS678S76S&montant_currency=EUR' +
    "&auteur_first_name=#{prenom}&auteur_last_name=#{nom}&auteur_email=#{newU.mail}" +
    '&id=Pay-ABCDEFGH&cart=HF7D68D65S'


    # Le paiement a dû être enregistré dans la table des paiements
    # (détruire la table des paiements en début de test)
    whereclause = "objet_id = 'ABONNEMENT' AND user_id = #{newU.id} AND created_at > #{start_time}"
    res = site.db.select(:cold, 'paiements', whereclause)
    res = res.first
    expect(res).not_to eq nil
    expect(res[:montant]).to eq tarif
    success 'Le paiement a été enregistré dans la base de données avec un montant valide'

    expect(newU).to have_mail(
      subject:    'Confirmation de votre abonnement',
      sent_after: start_time,
      message: [
        newU.pseudo, "Nous avons le plaisir de vous confirmer votre abonnement",
        site.configuration.titre,
        'la facture de votre paiement'
      ]
    )
    success 'la visiteuse a reçu un mail lui confirmant son abonnement (avec facture)'

    expect(phil).to have_mail(
      subject:      'Nouvel abonnement',
      sent_after:   start_time,
      message:      [newU.pseudo, newU.mail, "##{newU.id}"]
    )
    success 'l’administrateur a reçu un mail annonçant l’abonnement'


    success "#{newU.pseudo} arrive sur une page contenant…"
    expect(page).to have_tag('h2', text: 'Merci de votre soutien !')
    expect(page).to have_content("vous êtes maintenant abonnée pour un an au site")
    success '… le message de confirmation'
    expect(page).to have_tag('section#contents') do
      with_tag('a', with:{href:'aide'}, text: 'aide du site')
    end
    success '… un lien vers l’aide du site'
    expect(page).to have_tag('a', with:{href:'user/profil'}, text: "votre profil")
    success '… un lien vers son profil'
    success 'Donc une page de confirmation valide (testée plus profondément dans le test d’une inscription par un user quelconque)'

    visit home_page
    shot 'accueil-apres-suscribe-unan'
    expect(page).to have_content("Nouvelle abonnée : #{newU.pseudo}. Merci à elle !")
    success 'Le nouvel abonnement est annoncé en page d’accueil'

    # ---------------------------------------------------------------------
    #   SUPPLÉMENT POUR VÉRIFIER LES LIENS
    # ---------------------------------------------------------------------

    visit "http://#{site.url}/user/suscribe/1"
    expect(page).to have_tag('h2', text: /Merci de votre soutien/)
    success 'l’auteur peut rejoindre à nouveau la page de confirmation'

    click_link('votre profil', match: :first)
    expect(page).to have_tag('h2', text: 'Votre profil')
    success 'depuis la page de confirmation il peut rejoindre son profil'

    visit "http://#{site.url}/user/suscribe/1"
    expect(page).to have_tag('h2', text: /Merci de votre soutien/)
    expect(page).to have_tag('a',with:{href:'aide'}, text:'aide du site')
    click_link 'aide du site'
    expect(page).to have_tag('h2', text: 'Aide du site')
    success 'depuis la page de confirmation il peut rejoindre l’aide du site'

  end

end
