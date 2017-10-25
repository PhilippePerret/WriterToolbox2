=begin

  Test d'un user inscrit mais pas abonné au site

=end
require_lib_site

require_support_integration
require_support_db_for_test
require_support_paiements
require_support_mails_for_test

feature "Abonnement par un user déjà inscrit" do
  before(:all) do
    # On fait de l'user un inscrit au site mais pas un abonné
    @duser = create_new_user
  end
  scenario 'Un visiteur inscrit peut s’abonner au site' do

    montant_suscription = site.configuration.tarif

    start_time = Time.now.to_i

    visit home_page
    click_link('s’identifier', match: :first)
    within('form#signin_form') do
      fill_in 'user_mail', with: @duser[:mail]
      fill_in 'user_password', with: @duser[:password]
      click_button 'OK'
    end

    u = User.get(@duser[:id])
    expect(u).not_to be_suscribed
    success 'le visiteur n’est pas encore abonné'

    click_link 's’abonner', match: :first

    expect(page).to have_tag('div#indication_tarif > div', text: /offre un an d’accès complet/)
    expect(page).to have_tag('span', with:{class:'tarif'}, text: "#{montant_suscription} €")
    success 'la page du formulaire présente le bon texte et le bon tarif pour un abonné'

    # Comme pour l'inscription normal, on ne peut pas (enfin… JE ne sais pas)
    # comment activer le formulaire PayPal pour simuler toute la procédure,
    # donc je dois retourner au site un lien comme celui que doit retourner
    # paypal, avec toutes les informations.

    newU = User.get(@duser[:id])

    prenom, nom = newU.get(:patronyme).split(' ')

    visit "http://#{site.url}/user/suscribe/1?"+
    "state=approved&status=VERIFIED&montant=#{montant_suscription}&montant_total=#{montant_suscription}" +
    '&montant_id=HFJDHS678S76S&montant_currency=EUR' +
    "&auteur_first_name=#{prenom}&auteur_last_name=#{nom}&auteur_email=#{newU.mail}" +
    '&id=Pay-ABCDEFGH&cart=HF7D68D65S'

    # Le paiement a dû être enregistré dans la table des paiements
    # (détruire la table des paiements en début de test)
    whereclause = "objet_id = 'ABONNEMENT' AND user_id = #{newU.id} AND created_at > #{start_time}"
    res = site.db.select(:cold, 'paiements', whereclause)
    res = res.first
    expect(res).not_to eq nil
    expect(res[:montant]).to eq montant_suscription
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

  end
end
