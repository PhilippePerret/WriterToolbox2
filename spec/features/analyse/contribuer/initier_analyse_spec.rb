=begin

  Test de l'initiation d'une nouvelle analyse

=end
require_lib_site
require_support_integration
require_support_db_for_test
require_support_mail_for_test

protect_biblio

feature 'Initiation d’une nouvelle analyse' do

  before(:each) do
    @start_time = Time.now.to_i
  end
  let(:start_time) { @start_time }

  scenario '=> Un visiteur lambda ne peut pas initer une nouvelle analyse' do
    visit "#{base_url}/analyse/contribuer/new"
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_content('Pour pouvoir initier une nouvelle analyse de film')
    expect(page).to have_content('vous devez impérativement être inscrit sur le site et avoir fait une demande de contribution aux analyses')
    expect(page).not_to have_tag('form', with:{id: "analyse_new_film_form"})
  end


  scenario '=> Un visiteur inscrit non analyste ne peut pas initier une nouvelle analyse' do
    huser = get_data_random_user(mail_confirmed: true, admin: false, analyste: false)
    identify huser
    visit "#{base_url}/analyse/contribuer/new"
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_content('Pour pouvoir initier une nouvelle analyse de film')
    expect(page).to have_content('vous devez déposer une demande de contribution aux analyses')
    expect(page).not_to have_tag('form', with:{id: "analyse_new_film_form"})
  end




  scenario '=> Un inscrit analyste peut initier une nouvelle analyse par le menu Filmodico' do
    hanalyste = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)
    analyste_id = hanalyste[:id]
    identify hanalyste
    visit "#{base_url}/analyse/contribuer/new"
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('form', with:{id: "analyse_new_film_form"}) do
      with_tag('input', with:{type: 'submit', value: 'Initier l’analyse de ce film'})
    end
    # On choisit un film qui n'est pas encore analysé
    request = <<-SQL
    SELECT f.titre, f.id
      FROM films_analyses fa
      INNER JOIN filmodico f ON f.id = fa.id
      WHERE SUBSTRING(fa.specs,1,1) = '0'
      LIMIT 10
    SQL
    site.db.use_database(:biblio)
    hfilm = site.db.execute(request).first
    film_id = hfilm[:id]
    # puts "hfilm : #{hfilm.inspect}"
    within("form#analyse_new_film_form") do
      select(hfilm[:titre], from: 'analyse_film_id')
      click_button 'Initier l’analyse de ce film'
    end
    success 'l’analyste peut soumettre la demande d’initiation'

    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('div.notice', text: /L’analyse a été initiée/)
    expect(page).to have_tag('p', text: /Données générales de l’analyse du film/)
    success 'Un message confirme l’initiation de l’analyse et on se trouve sur sa page'
    expect(page).to have_tag('a', with: {href: "analyse/contribuer/#{film_id}"})
    expect(page).to have_tag('a', with: {href: "analyse/lire/#{film_id}"})
    expect(page).to have_tag('a', with: {href: "aide?p=analyse%2Fcontribuer"})
    success 'il contient tous les liens utiles (pour lire, contribuer ou trouver de l’aide)'

    hfa = site.db.select(:biblio,'films_analyses',{id: film_id}).first
    expect(hfa[:specs][0]).to eq '1'
    success 'les specs du film_analyse ont été modifiés (premier bit à 1)'

    hlien = site.db.select(:biblio,'user_per_analyse', {user_id: analyste_id, film_id: film_id}).first
    expect(hlien).not_to eq nil
    expect(hlien[:created_at]).to be > start_time
    role = hlien[:role]
    # Créateur | Peut modifier les données générale | Peut détruire l'analyse
    expect(role & (1|128|256)).to eq 1|128|256
    success 'un lien analyste/analyse a été créé, avec le bon rôle pour l’analyste'

    [phil,marion].each do |admin|
      expect(admin).to have_mail({
        subject: "Nouvelle analyse initiée par #{hanalyste[:pseudo]}",
        sent_after: start_time,
        message: [hanalyste[:mail], "analyse/lire/#{film_id}"]
        })
    end
    success 'les administrateurs ont été prévenus de cette nouvelle analyse'

  end

  scenario 'Un analyste ne peut pas initier l’analyse d’un film déjà analysé avec son ID' do
    # NOTE : Noter que par défaut, seuls les films non analysés sont présents.
    # Donc, pour analyser un film inexistant, il faut soit le rentrer sous forme
    # de titre sans savoir qu'il existe, soit forcer l'url avec un identifiant
    hanalyste = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)
    film_id = site.db.select(:biblio,'filmodico',{titre: "Seven"},[:id]).first[:id]

    identify hanalyste
    visit "#{base_url}/analyse/contribuer/new?op=create&analyse_film_id=#{film_id}&analyse_film_annee=1995"
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('div.error', text: /Ce film fait déjà l’objet d’une analyse/)
    expect(page).to have_tag('a', with:{href: "analyse/lire/#{film_id}"}, text: /Consulter l’analyse de SEVEN/)
  end

  scenario '=> Un analyste ne peut pas initier une analyse d’un film déjà analysé avec son titre' do
    # Lire la NOTE ci-dessus
    hanalyste = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)
    analyste_id = hanalyste[:id]
    identify hanalyste
    visit "#{base_url}/analyse/contribuer/new"
    expect(page).to have_tag('h2', text: /analyses de films/i)
    within("form#analyse_new_film_form") do
      fill_in('analyse_film_titre', with: "Taxi Driver")
      fill_in('analyse_film_annee', with: '1976')
      click_button 'Initier l’analyse de ce film'
    end
    expect(page).to have_tag('h2', text: /analyses de films/i)
    expect(page).to have_tag('div.error', text: /Ce film fait déjà l’objet d’une analyse/)
    success 'alerte indique que l’analyse existe déjà'
    expect(page).to have_tag('a', with:{href: "analyse/lire/137"}, text: /Consulter l’analyse de TAXI DRIVER/)
    success 'un lien permet de rejoindre cette analyse'

    nb = site.db.count(:biblio,'user_per_analyse',{user_id: analyste_id, film_id: film_id})
    expect(nb).to eq 0
    success 'aucun lien n’a été créé entre l’analyste et l’analyse mais un message lui suggère de rejoindre l’analyse'
  end

  scenario '=> Un analyste qui n’a pas suffisamment de privilège ne peut initier que l’analyse d’un film Filmodico' do
    pending
    # TODO Un message lui explique qu'une demande a été faite auprès de
    # l'administration, qui créera la fiche du film pour lui permettre de procéder à cette
    # analyse.

    # TODO Le film n'existe pas dans les films_analyses
    success 'l’analyse n’a pas été créée'

  end

end
