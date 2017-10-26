=begin

  Test de la liste des analyses en cours

=end
require_lib_site
require_support_integration

feature 'Liste des analyses en cours' do
  before(:all) do
    # Si on passe par ici, il faut absolument protéger les données biblio qui
    # vont être modifiées. On doit les sauver si nécessaire et demander leur
    # rechargement.
    backup_base_biblio # seulement si nécessaire
    protect_biblio
  end

  context 'Un analyste' do

    scenario '=> trouve une liste conforme des analyses en cours' do
      hanalyste = get_data_random_user(admin: false, analyste: true)

      require_lib('analyse:listes')
      all_analyses = Analyse.all(current: true)

      # Il faut qu'il y ait des analyses en cours
      expect(all_analyses.count).to be > 0

      identify hanalyste
      visit "#{base_url}/analyser/list"
      # sleep 30
      expect(page).to have_tag('h2') do
        with_tag('a', with: {href: 'analyser'}, text: 'Contribuer')
      end
      expect(page).to have_tag('h3', text: 'Analyses en cours')
      expect(page).to have_tag('ul#analyses') do
        all_analyses.each do |analyse|
          # puts "analyse: #{analyse.inspect}"

          pseudos_contributors =
            analyse[:contributors].collect do |hcont|
              hcont[:pseudo]
            end.join(', ')

          hcreator = analyse[:contributors].first
          creator_id = hcreator[:id]

          # Il faut savoir si le visiteur, un analyste, est contributeur
          # à cette analyse.
          # Car si c'est le cas, certains boutons n'apparaitront pas.
          visitor_is_contributor = false
          analyse[:contributors].each do |hcont|
            if hcont[:id] == hanalyste[:id]
              visitor_is_contributor = true
              break
            end
          end

          # if visitor_is_contributor
          #   puts "#{hanalyste[:pseudo]} contribut à l'analyse #{analyse[:titre]}"
          # else
          #   puts "#{hanalyste[:pseudo]} ne contribut pas à l'analyse #{analyse[:titre]}"
          # end

          titre = analyse[:titre].force_encoding('utf-8')
          with_tag('li', with: {class: 'analyse', id: "analyse-#{analyse[:id]}"}) do
            with_tag('span',with: {class: 'titre'}, text: /#{titre}/) do
              with_tag('a', with: {href: "filmodico/voir/#{analyse[:id]}"})
            end
            with_tag('div', with: {class: 'states'}) do
              with_tag('span', with:{class: 'creator'}, text: hcreator[:pseudo]) do
                with_tag('a', with:{href: "user/profil/#{creator_id}"})
              end
              with_tag('span', with:{class: 'contributors', title: pseudos_contributors})
            end
            with_tag('div', with: {class: 'buttons'}, visible: false) do
              if visitor_is_contributor
                with_tag('a', with: {href: "analyser/dashboard/#{analyse[:id]}"}, text: 'vous contribuez')
              else
                with_tag('a', with: {href: "analyser/postuler/#{analyse[:id]}"}, text: 'contribuer')
              end
              with_tag('a', with: {href: "analyse/lire/#{analyse[:id]}"}, text: 'voir')
            end
          end
        end
      end
      success 'il trouve une liste complète et informée'

      expect(page).to have_tag('a', with: {href: "analyser/list?filtre[which]=all"}, text: 'Voir toutes les analyses')
      success 'il trouve un lien pour voir toutes les analyses (même les analyses non en cours)'

    end

  end


  context 'Un non analyste' do
    scenario '=> trouve une liste minimale des analyses en cours' do
      visit "#{base_url}/analyser/list"
      expect(page).to have_tag('h2') do
        with_tag('a', with: {href: 'analyser'}, text: 'Contribuer')
      end
      expect(page).to have_tag('h3', text: 'Analyses en cours')

      require_lib('analyse:listes')
      all_analyses = Analyse.all(current: true)

      # Il faut qu'il y ait des analyses en cours
      expect(all_analyses.count).to be > 0

      expect(page).to have_tag('ul#analyses') do
        all_analyses.each do |analyse|
          # puts "analyse: #{analyse.inspect}"

          pseudos_contributors =
            analyse[:contributors].collect do |hcont|
              hcont[:pseudo]
            end.join(', ')

          hcreator = analyse[:contributors].first
          creator_id = hcreator[:id]

          titre = analyse[:titre].force_encoding('utf-8')
          with_tag('li', with: {class: 'analyse', id: "analyse-#{analyse[:id]}"}) do
            with_tag('span',with: {class: 'titre'}, text: /#{titre}/) do
              with_tag('a', with: {href: "filmodico/voir/#{analyse[:id]}"})
            end
            with_tag('div', with: {class: 'states'}) do
              with_tag('span', with:{class: 'creator'}, text: hcreator[:pseudo]) do
                with_tag('a', with:{href: "user/profil/#{creator_id}"})
              end
              with_tag('span', with:{class: 'contributors', title: pseudos_contributors})
            end
            with_tag('div', with: {class: 'buttons'}, visible: false) do
              without_tag('a', with: {href: "analyser/dashboard/#{analyse[:id]}"}, text: 'vous contribuez')
              without_tag('a', with: {href: "analyser/postuler/#{analyse[:id]}"}, text: 'contribuer')
              if analyse[:specs][4] == '1'
                with_tag('a', with: {href: "analyse/lire/#{analyse[:id]}"}, text: 'voir')
              else
                without_tag('a', text: 'voir')
              end
            end
          end
        end
      end
      success 'il trouve une liste complète sans bouton, sauf le bouton voir quand l’analyse est lisible'

      expect(page).not_to have_tag('a', with: {href: "analyser/list?filtre[which]=all"}, text: 'Voir toutes les analyses')
      success 'il ne trouve pas de lien pour voir toutes les analyses'

    end
  end
end
