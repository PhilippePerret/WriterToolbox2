=begin

  Test du retour à la page voulue après signin

=end
require_support_integration
require_support_db_for_test

feature 'Retour à la page voulue après identification (case à cocher S’identifier ”puis revenir”)' do

  scenario '=> Sans cocher la case “puis revenir”, l’inscrit ne revient pas à la page' do
    # Il ne peut survenir une erreur (improbable) que si :
    # On :
    # • choisit par hasard un user qui
    # • a visité la même page dans un test précédent en dernière page
    # • a réglé ses préférences pour revenir sur sa dernière page
    # (cas fortement improbable, sauf si, par exemple, le test suivant est joué avant celui-ci…)

    huser = get_data_random_user(admin: false, analyste: false)

    visit "#{base_url}/narration/page/3"
    expect(page).to have_tag('h2', text: 'La collection Narration')
    expect(page).to have_tag('span.titre_livre', text: 'La Structure')
    expect(page).to have_tag('h2.titre_page', text: /La structure, qu'est-ce que c'est/)
    success 'il arrive sur la bonne page'

    expect(page).to have_tag('form', with:{id: 'signin_link_form'}) do
      with_tag('label', with:{for: 'cb_goback'}, text: 'puis revenir')
      with_tag('input', with:{type: 'checkbox', name:'goback', id: 'cb_goback'})
      with_tag('input', with:{type: 'hidden', value: 'narration/page/3', name: 'goback_route'})
      with_tag('input', with:{type: 'submit', value: 's’identifier'})
    end
    success 'il trouve le formulaire pour le lien vers l’identification'

    within('form#signin_link_form') do
      uncheck('cb_goback') # on ne sait jamais
      click_button 's’identifier'
    end

    expect(page).to be_signin_page
    within('form#signin_form') do
      fill_in('user_mail', with: huser[:mail])
      fill_in('user_password', with: huser[:password])
      click_button 'OK'
    end
    success 'il rejoint l’identification et s’identifie'

    expect(page).not_to have_tag('h2', text: 'La collection Narration')
    expect(page).not_to have_tag('span.titre_livre', text: 'La Structure')
    expect(page).not_to have_tag('h2.titre_page', text: /La structure, qu'est-ce que c'est/)
    success 'il n’est retourné à la page initiale'


  end

  scenario '=> En cochant la case “puis revenir”, l’inscrit revient à sa page après identification' do
    huser = get_data_random_user(admin: false, analyste: false)

    visit "#{base_url}/narration/page/3"
    expect(page).to have_tag('h2', text: 'La collection Narration')
    expect(page).to have_tag('span.titre_livre', text: 'La Structure')
    expect(page).to have_tag('h2.titre_page', text: /La structure, qu'est-ce que c'est/)
    success 'il arrive sur la bonne page'

    expect(page).to have_tag('form', with:{id: 'signin_link_form'}) do
      with_tag('label', with:{for: 'cb_goback'}, text: 'puis revenir')
      with_tag('input', with:{type: 'checkbox', name:'goback', id: 'cb_goback'})
      with_tag('input', with:{type: 'hidden', value: 'narration/page/3', name: 'goback_route'})
      with_tag('input', with:{type: 'submit', value: 's’identifier'})
    end
    success 'il trouve le formulaire pour le lien vers l’identification'

    within('form#signin_link_form') do
      check('cb_goback')
      click_button 's’identifier'
    end

    expect(page).to be_signin_page
    within('form#signin_form') do
      fill_in('user_mail', with: huser[:mail])
      fill_in('user_password', with: huser[:password])
      click_button 'OK'
    end
    success 'il rejoint l’identification et s’identifie'

    expect(page).to have_tag('h2', text: 'La collection Narration')
    expect(page).to have_tag('span.titre_livre', text: 'La Structure')
    expect(page).to have_tag('h2.titre_page', text: /La structure, qu'est-ce que c'est/)
    success 'il est retourné à la page initiale'

  end
end
