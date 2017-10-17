=begin

  Test de « l'inscription » a une analyse, c'est-à-dire le fait de proposer
  sa contribution pour une analyse dont on n'est pas le créateur

  Synopsis
  ========

    Un analyste (il faut l'être) rejoint une analyse en cours depuis
    la liste des analyses en cours et demande à s'inscrire

=end
require_lib_site
require_support_integration
require_support_db_for_test
require_support_mail_for_test
require_support_analyse

feature 'Proposition de contribution à une analyse en cours' do
  scenario '=> Un analyste peut proposer sa participation à une analyse en cours' do
    hanalyste = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)

    identify hanalyste
    visit analyse_page
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('a', {href: "analyse/contribuer/list"})
    page.find("a[href=\"analyse/contribuer\"]").click
    expect(page).to have_tag('h2', text: /Contribuer/)
    page.find("a[href=\"analyse/contribuer/list\"]").click
    expect(page).to have_tag('h3', 'Analyses en cours')
    success 'il peut rejoindre la liste des analyses en cours'

    # Il choisit la première analyse à laquelle il ne participe pas
    require_lib 'analyse:listes'
    current_analyses = Analyse.all(current: true)
    hanalyse = nil
    current_analyses.each do |analyse|
      analyse[:contributors].each do |hcont|
        hcont[:id] != hanalyste[:id] || next
      end
      hanalyse = analyse
      break
    end

    expect(hanalyse).not_to eq nil

    # ON rend visible les boutons, comme si on passait la souris dessus
    page.execute_script(<<-JS)
    let e = document.querySelector("ul#analyses li#analyse-#{hanalyse[:id]} div.buttons");
    e.style.visibility = 'visible';
    JS

    within("ul#analyses li#analyse-#{hanalyse[:id]} div.buttons") do
      click_link 'contribuer'
    end
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('h3', text: /#{hanalyse[:titre]}/)
    expect(page).to have_tag('a', with: {href: "analyse/contribuer/#{hanalyse[:id]}?op=proposition"}, text: '→ Contribuer')
    success 'il peut rejoindre une analyse en cours'

    click_link('→ Contribuer')
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('div.notice', text: /a été envoyée au créateur de cette analyse/)
    expect(page).to have_tag('div.notice', text: /vous répondre rapidement/)
    success 'il peut soumettre sa candidature'

    hticket = site.db.select(:hot,'tickets',"created_at > #{start_time} AND user_id = #{hanalyste[:ID]}").first
    expect(hticket).not_to eq nil
    expect(hticket[:code]).to eq "require_lib('analyse:validation_proposition')\nAnalyse.validate_proposition(#{hanalyse[:id]},#{hanalyste[:id]})"
    ticket_id = hticket[:id]
    success 'Un ticket a été créé pour valider la proposition, avec les bonnes données'

    hticket = site.db.select(:hot,'tickets',"created_at > #{start_time} AND user_id = #{hanalyste[:ID]}").first
    expect(hticket).not_to eq nil
    expect(hticket[:code]).to eq "require_lib('analyse:refus_proposition')\nAnalyse.refuser_proposition(#{hanalyse[:id]},#{hanalyste[:id]})"
    ticket_id = hticket[:id]
    success 'Un ticket a été créé pour refuser la proposition, avec les bonnes données'

    creator = User.get(hanalyse[:contributors].first[:id])
    expect(creator).to have_mail({
      sent_after: start_time,
      subject: raise,
      message: [hanalyste[:pseudo], hanalyste[:mail], "tckid=#{ticket_id}"]
      })
    success 'le créateur de l’analyse reçoit la candidature'

    pending "L'administrateur voit passer cette demande"

  end

  scenario '=> Un non analyste ne peut pas proposer sa contribution' do
    pending
  end
end
