
require_support_integration
require_support_db_for_test


feature "Présence des dernières actualités sur la page d'accueil" do
  scenario "=> Un visiteur se rendant sur la page d'accueil trouve les dernières actualités" do
    # ======== PRÉPARATION ==========
    truncate_table_updates
    # On enregistre des dernières actualités pour les voir
    now = Time.now.to_i
    JOUR = 3600*24
    yesterday   = now - 1.jour
    a_year_ago  = now - 365.jours
    a_month_ago = now - 1.mois
    a_week_ago  = now - 1.semaine

    @liste_updates = {

      #  POURSUIVRE LES TYPES

      1 => {id: 1, message: 'Une dernière actualisation',        type: 'site', route: nil, options: '10000000', created_at: yesterday},
      2 => {id: 2, message: 'Autre dernière actualisation',      type: 'site', route: nil, options: '10000000', created_at: now},
      3 => {id: 3, message: 'Une actualisation UAUS avec route', type: 'unan', route: 'unanunscript/home', options: '10000000', created_at: a_month_ago},
      6 => {id: 6, message: 'Une actualisation Narration',       type: 'narration', route: 'narration', options: '10000000', created_at: a_month_ago},
      7 => {id: 7, message: 'Autre actualisation Narration',     type: 'narration', route: 'narration', options: '10000000', created_at: a_month_ago},
      8 => {id: 8, message: '3e actualisation Narration',        type: 'narration', route: 'narration/state', options: '10000000', created_at: a_month_ago},
      4 => {id: 4, message: 'On ne doit pas voir celle-ci',      type: 'unan', route: 'unanunscript/home', options: '00000000', created_at: now - 12.jours},
      5 => {id: 5, message: 'On ne doit pas voir celle-là', type: 'forum', route: 'unanunscript/home', options: '00000000', created_at: now - 96.jours},
      10 => {id: 10, message: 'On ne doit pas voir celle-là (#10)', type: 'forum', route: 'unanunscript/home', options: '00000000', created_at: a_year_ago + 1.jour}

    }
    @liste_updates.each do |uid, hupdate|
      id = site.db.insert(:cold,'updates',hupdate)
      hupdate.merge!(id: id)
    end

    # ===========> TEST <=============
    visit home_page
    success 'Un visiteur qui se rend sur la page d’accueil…'

    # =========== VÉRIFICATION ==============
    expect(page).to have_tag('fieldset', {id: 'last_updates'}) do
      with_tag('legend', text: 'Dernières actualités')
    end
    success 'trouve la section#last_updates avec sa légende'

    def check_updates type, goods
      expect(page).to have_tag('ul', with:{class:'updates', id: "updates-#{type}"}) do
        goods.each do |uid|
          with_tag('li', with: {id: "update-#{uid}"}, text: @liste_updates[uid][:message])
        end
        (1..20).each do |uid|
          goods.include?(uid) && next
          without_tag('li', with: {id: "update-#{uid}"})
        end
      end
    end

    check_updates( 'site', [1,2] )
    success 'trouve les dernières actualités du site dans sa partie'

    check_updates( 'unan', [3] )
    success 'trouve les dernières actualités du programme UAUS dans sa partie'

    check_updates( 'narration', [6,7,8] )
    success 'trouve les dernières actualités de la collection Narration'

  end
end
