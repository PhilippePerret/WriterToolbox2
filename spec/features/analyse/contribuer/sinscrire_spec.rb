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

protect_biblio

feature 'Proposition de contribution à une analyse en cours' do

  before(:all) do
    require_support_tickets
    remove_tickets
  end

  before(:each) do
    @start_time = Time.now.to_i
  end
  let(:start_time) { @start_time }

  scenario '=> Un analyste peut proposer sa participation à une analyse en cours' do
    hanalyste = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)

    identify hanalyste
    visit analyse_page
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('a', {href: "analyse/contribuer/list"})
    page.find("a[href=\"analyse/contribuer\"]").click
    expect(page).to have_tag('h2', text: /Contribuer/)
    page.find("a[href=\"analyse/contribuer/list\"]").click
    # sleep 10
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

    # sleep 10

    within("ul#analyses li#analyse-#{hanalyse[:id]} div.buttons") do
      click_link 'contribuer'
    end
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('h3', text: /#{hanalyse[:titre]}/)
    expect(page).to have_tag('a', with: {href: "analyse/contribuer/#{hanalyse[:id]}?op=proposition"}, text: '→ Contribuer')
    success 'il peut rejoindre une analyse en cours'

    click_link('→ Contribuer')
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('div.notice', text: /Votre proposition de contribution vient d’être transmise/)
    expect(page).to have_tag('div.notice', text: /vous répondre rapidement/)
    success 'il peut soumettre sa candidature'

    # Doit relever les deux tickets
    htickets = site.db.select(:hot,'tickets',"created_at > #{start_time} AND user_id = #{hanalyste[:id]}")
    expect(htickets.count).to eq 2

    ticket_val_id = nil
    ticket_ref_id = nil
    htickets.each do |hticket|
      if hticket[:code].match(/validation_proposition/)
        expect(hticket[:code]).to eq "require_lib('analyse:validation_proposition')\nAnalyse.validate_proposition(#{hanalyse[:id]},#{hanalyste[:id]})"
        ticket_val_id = hticket[:id]
        success 'Un ticket a été créé pour valider la proposition, avec les bonnes données'
      else
        expect(hticket[:code]).to eq "require_lib('analyse:refus_proposition')\nAnalyse.refuser_proposition(#{hanalyse[:id]},#{hanalyste[:id]})"
        ticket_ref_id = hticket[:id]
        success 'Un ticket a été créé pour refuser la proposition, avec les bonnes données'
      end
    end

    expect(ticket_val_id).not_to eq nil
    expect(ticket_ref_id).not_to eq nil
    success 'les deux tickets (pour la validation et le refus) ont été trouvés'

    creator = User.get(hanalyse[:contributors].first[:id])
    expect(creator).to have_mail({
      sent_after: start_time,
      subject: /Proposition de contribution à l’analyse de/,
      message: [hanalyste[:pseudo], hanalyste[:mail], "tckid=#{ticket_val_id}", "tckid=#{ticket_ref_id}"]
      })
    success 'le créateur de l’analyse reçoit la candidature'

    [phil,marion].each do |admin|
      expect(admin).to have_mail({
        subject: 'Proposition de contribution à une analyse',
        sent_after: start_time
        })
    end
    success "Les administrateurs sont informés de cette demande"

  end

  scenario '=> Un non analyste ne peut pas proposer sa contribution' do
    huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: false)

    identify huser
    visit analyse_page
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('a', {href: "analyse/contribuer/list"})
    page.find("a[href=\"analyse/contribuer\"]").click
    expect(page).to have_tag('h2', text: /Contribuer/)
    # sleep 30
    page.find("a[href=\"analyse/contribuer/list\"]").click
    expect(page).to have_tag('h3', 'Analyses en cours')
    success 'il peut rejoindre la liste des analyses en cours'

    # Il choisit la première analyse
    require_lib 'analyse:listes'
    hanalyse = Analyse.all(current: true).first

    expect(hanalyse).not_to eq nil

    # ON rend visible les boutons, comme si on passait la souris dessus
    page.execute_script(<<-JS)
    let e = document.querySelector("ul#analyses li#analyse-#{hanalyse[:id]} div.buttons");
    e.style.visibility = 'visible';
    JS

    within("ul#analyses li#analyse-#{hanalyse[:id]} div.buttons") do
      expect(page).not_to have_link('contribuer')
    end
    success 'l’user ne trouve pas le bouton pour contribuer'

  end


  scenario '=> Un non analyste ne peut pas forcer la proposition de contribution par l’URL' do
    huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: false)
    identify huser
    # On prend la première analyse
    require_lib 'analyse:listes'
    hanalyse = Analyse.all(current: true).first
    # On fake le bouton contribuer
    visit "#{base_url}/analyse/contribuer/#{hanalyse[:id]}?op=proposition"
    # sleep 10
    expect(page).to have_tag('h2', text: /Contribuer/)
    expect(page).to have_tag('div.error', text: /Seul un analyste peut proposer sa contribution/i)
    success 'l’user reçoit un message d’erreur'

    expect(page).not_to have_tag('a', with: {href: "analyse/contribuer/#{hanalyse[:id]}?op=proposition"}, text: '→ Contribuer')
    expect(page).to have_tag('a', text:/Devenir analyste/)
    success 'la page ne contient pas le bouton Contribuer mais le bouton pour devenir analyste'

  end

  scenario '=> Un analyste qui contribue déjà ne peut pas soumettre de proposition' do
    huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)

    identify huser
    visit analyse_page
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('a', {href: "analyse/contribuer/list"})
    page.find("a[href=\"analyse/contribuer\"]").click
    expect(page).to have_tag('h2', text: /Contribuer/)
    # sleep 30
    page.find("a[href=\"analyse/contribuer/list\"]").click
    expect(page).to have_tag('h3', 'Analyses en cours')
    success 'il peut rejoindre la liste des analyses en cours'

    # Il choisit la première analyse
    require_lib 'analyse:listes'
    hanalyse = Analyse.all(current: true).first
    expect(hanalyse).not_to eq nil
    # Si l'user n'est pas contributeur, on l'ajoute
    found = false
    hanalyse[:contributors].each do |hcont|
      if hcont[:id] == huser[:id]
        found = true
        break
      end
    end
    unless found
      datacont = {
        user_id: huser[:id], film_id: hanalyse[:id], role: 1|4
      }
      site.db.insert(:biblio,'user_per_analyse',datacont)
    end

    visit "#{base_url}/analyse/contribuer/#{hanalyse[:id]}"
    success 'il peut rejoindre la page d’analyse du film'

    # sleep 30

    expect(page).not_to have_tag('a', with: {href: "analyse/contribuer/#{hanalyse[:id]}?op=proposition"}, text: '→ Contribuer')
    expect(page).not_to have_tag('a', text:/Devenir analyste/)
    success 'il ne trouve ni le bouton « Contribuer » (puisqu’il contribue déjà à cette analyse) ni le bouton « Devenir analyse »'
    expect(page).to have_content('Vous contribuez à cette analyse')
    success 'en revanche, un text lui indique qu’il contribue à cette analyse'

    notice '* il essaie de proposer à nouveau par l’URL'
    visit "#{base_url}/analyse/contribuer/#{hanalyse[:id]}?op=proposition"

    expect(page).to have_tag('div.notice', text: /Vous contribuez déjà à cette analyse/)
    success 'un message lui annonce qu’il contribue déjà'

  end

  scenario '=> Un analyste ne peut pas proposer sa contribution sur une analyse qui n’est pas en cours' do
    huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)

    where = "SUBSTRING(specs,6,1) = '0' LIMIT 1"
    hanalyse = site.db.select(:biblio,'films_analyses',where).first
    expect(hanalyse).not_to eq nil # Une analyse non en cours doit exister
    identify huser
    visit analyse_page

    visit "#{base_url}/analyse/contribuer/#{hanalyse[:id]}?op=proposition"
    expect(page).to have_tag('h2', text: /Contribuer/)
    expect(page).to have_tag('div.error', text: /cette analyse n’est pas en cours/i)

  end

end
