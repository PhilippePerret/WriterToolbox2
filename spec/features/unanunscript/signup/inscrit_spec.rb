=begin

  Test d'un user inscrit mais pas abonné au site

=end
require_lib_site
require_lib_uaus

require_support_integration
require_support_db_for_test
require_support_paiements
require_support_mails_for_test

feature "Inscription au programme UN AN UN SCRIPT par un user inscrit mais pas abonné" do
  before(:all) do
    # On fait de l'user un inscrit au site mais pas un abonné
    @duser = create_new_user(mail_confirmed: true)
  end
  scenario 'Un visiteur abonné peut s’inscrire au programme (en payant moins cher)' do

    montant_suscriber = Unan.tarif

    start_time = Time.now.to_i

    visit home_page
    click_link('s’identifier')
    within('form#signin_form') do
      fill_in 'user_mail', with: @duser[:mail]
      fill_in 'user_password', with: @duser[:password]
      click_button 'OK'
    end

    u = User.get(@duser[:id])
    expect(u).not_to be_suscribed
    success 'le visiteur n’est pas un abonné'

    click_link 'outils', match: :first
    expect(page).to have_tag('h2', text: 'Outils d’écriture')
    expect(page).to have_tag('a', with:{href:'unanunscript/home'}, text: 'Le programme UN AN UN SCRIPT')
    click_link 'Le programme UN AN UN SCRIPT'
    expect(page).to have_tag('h2', text: 'Le programme UN AN UN SCRIPT')
    expect(page).to have_link('S’inscrire au programme')
    click_link 'S’inscrire au programme', match: :first

    expect(page).to have_tag('div#indication_tarif > div', text: /compris : deux ans d’abonnement complet au site/)
    expect(page).to have_tag('span', with:{id:'tarif_unan'}, text: "#{montant_suscriber} €")
    success 'la page du formulaire présente le bon texte et le bon tarif pour un abonné'

    # Comme pour l'inscription normal, on ne peut pas (enfin… JE ne sais pas)
    # comment activer le formulaire PayPal pour simuler toute la procédure,
    # donc je dois retourner au site un lien comme celui que doit retourner
    # paypal, avec toutes les informations.

    newU = User.get(@duser[:id])

    prenom, nom = newU.get(:patronyme).split(' ')

    visit "http://#{site.url}/unanunscript/signup/1?"+
    "state=approved&status=VERIFIED&montant=#{montant_suscriber}&montant_total=#{montant_suscriber}" +
    '&montant_id=HFJDHS678S76S&montant_currency=EUR' +
    "&auteur_first_name=#{prenom}&auteur_last_name=#{nom}&auteur_email=#{newU.mail}" +
    '&id=Pay-ABCDEFGH&cart=HF7D68D65S'


    # sleep 60

    expect(page).to have_tag('h2', text: 'Inscription réussie !')
    expect(page).to have_content("vous êtes maintenant inscrite au programme")

    # sleep 5 # pour voir un peu la page d'arrivée

    # Le paiement a dû être enregistré dans la table des paiements
    # (détruire la table des paiements en début de test)
    whereclause = "objet_id = '1AN1SCRIPT' AND user_id = #{newU.id} AND created_at > #{start_time}"
    res = site.db.select(:cold, 'paiements', whereclause)
    res = res.first
    expect(res).not_to eq nil
    expect(res[:montant]).to eq montant_suscriber
    success 'Le paiement a été enregistré dans la base de données avec un montant valide'

    expect(newU).to have_mail(
      subject:    'Inscription au programme UN AN UN SCRIPT',
      sent_after: start_time,
      message: [
        newU.pseudo, "J’ai le plaisir de vous confirmer votre inscription au programme UN AN UN SCRIPT",
        '<a href="http://www.laboiteaoutilsdelauteur.fr/unanunscript/aide">Aide du programme UN AN UN SCRIPT</a>',
        'Votre facture'
      ]
    )
    success 'la visiteuse a reçu un mail lui confirmant son inscription (avec facture)'

    expect(phil).to have_mail(
      subject:      'Nouvelle inscription au programme UN AN UN SCRIPT',
      sent_after:   start_time,
      message:      [newU.pseudo, newU.mail, "##{newU.id}"]
    )
    success 'l’administrateur a reçu un mail annonçant l’inscription'

    hprogram = site.db.select(:unan, :programs, {auteur_id: newU.id}).first
    # expect(hprogram).not_to eq nil
    expect(hprogram[:created_at]).to be > start_time
    success 'Un nouveau programme est créé avec les bonnes données'

    hprojet = site.db.select(:unan, :projets, {auteur_id: newU.id}).first
    expect(hprojet).not_to eq nil
    expect(hprojet[:created_at]).to be > start_time
    success 'Un nouveau projet est créé, avec les bonnes données'

    expect(hprojet[:program_id]).to eq hprogram[:id]
    expect(hprogram[:projet_id]).to eq hprojet[:id]
    success 'le programme et le projet sont liés'


    success "#{newU.pseudo} arrive sur une page contenant…"

    expect(page).to have_content("ID Programme : ##{hprogram[:id]}")
    expect(page).to have_content("ID Projet : ##{hprojet[:id]}")
    success '… les identifiants des programmes et projet'
    expect(page).to have_tag('a', with:{href:'unanunscript/aide'}, text: "l’aide du programme")
    success '… un lien vers l’aide du programme'
    expect(page).to have_tag('a', with:{href:'unanunscript/bureau'}, text: "le bureau de votre programme")
    success '… un lien vers le bureau de l’auteur pour son programme'
    success 'Donc une page de confirmation valide (testée plus profondément dans le test d’une inscription par un user quelconque)'

    visit home_page
    shot 'accueil-apres-signup-unan'
    expect(page).to have_content("#{newU.pseudo} commence le programme UN AN UN SCRIPT")
    success 'Le nouveau programme est annoncé en page d’accueil'

  end
end
