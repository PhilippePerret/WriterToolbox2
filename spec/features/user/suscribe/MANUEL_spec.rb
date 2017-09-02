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

    5.times do |i|
      puts "TESTER MANUELLEMENT LE PAIEMENT AU PROGRAMME UN AN UN SCRIPT (#{i}/10)"
      sleep 60
    end

  end

end
