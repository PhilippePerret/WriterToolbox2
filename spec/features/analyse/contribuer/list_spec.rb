=begin

  Test de la liste des analyses en cours

=end
require_lib_site
require_support_integration

feature 'Liste des analyses en cours' do
  context 'Un analyste' do

    scenario '=> trouve une liste conforme des analyses en cours' do
      hanalyste = get_data_random_user(mail_confirmed: true, admin: false, analyste: true)

      request = <<-SQL
      SELECT fa.*, f.*
        FROM films_analyses fa
        INNER JOIN filmodico f ON f.id = fa.id
        WHERE specs LIKE '1____1%'
      SQL
      site.db.use_database(:biblio)
      all_analyses = site.db.execute(request)

      # Il faut qu'il y ait des analyses en cours
      expect(all_analyses.count).to be > 0

      visit "#{base_url}/analyse/contribuer/list"
      # sleep 30
      expect(page).to have_tag('h2') do
        with_tag('a', with: {href: 'analyse/contribuer'}, text: 'Contribuer')
      end
      expect(page).to have_tag('h3', text: 'Analyses en cours')
      expect(page).to have_tag('ul#analyses') do
        all_analyses.each do |analyse|
          puts "analyse: #{analyse.inspect}"
          titre = analyse[:titre].force_encoding('utf-8')
          with_tag('li', with: {class: 'analyse', id: "analyse-#{analyse[:id]}"}) do
            with_tag('span',with: {class: 'titre'}, text: /#{titre}/)
            with_tag('div', with: {class: 'states'})
            with_tag('div', with: {class: 'buttons'}) do
              with_tag('a', with: {href: "analyse/contribuer/#{analyse[:id]}"}, text: 'contribuer')
              with_tag('a', with: {href: "analyse/lire/#{analyse[:id]}"}, text: 'lire')
            end
          end
        end
      end
      success 'il trouve une liste complète et informée'


    end

  end


  context 'Un non analyste' do
    scenario '=> trouve une liste minimale des analyses en cours' do
      visit "#{base_url}/analyse/contribuer/list"
      expect(page).to have_tag('h2') do
        with_tag('a', with: {href: 'analyse/contribuer'}, text: 'Contribuer')
      end
      expect(page).to have_tag('h3', text: 'Analyses en cours')
    end
  end
end
