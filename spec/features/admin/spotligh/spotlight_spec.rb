=begin

    Test pour l'administration du coup de projecteur

=end

require_support_db_for_test
require_support_integration

feature "Définition du coup de projecteur" do
  before(:all) do
    @duser = create_new_user(mail_confirmed: true)
  end
  scenario "Un visiteur même identifié ne peut pas le définir" do
    identify @duser
    visit "#{base_url}/admin/spotlight"
    expect(page).not_to have_tag('h2', text: /coup de projecteur/)
    expect(page).to have_tag('h2', text: 'Vous avez été redirigée')
  end

  scenario 'un administrateur peut redéfinir le coup de projecteur' do
    identify phil
    visit "#{base_url}/admin/spotlight"
    expect(page).to have_tag('h2', text: 'Admin : coup de projecteur')
    expect(page).to have_tag('form', with:{id: 'spotlight_form'})
    success 'l’administrateur trouve un formulaire pour le coup de projecteur'

    # Définition des nouvelles données pour le coup de projecteur
    @dproj = {
      objet: 'Le programme UN AN UN SCRIPT',
      route: 'unanunscript/home',
      text_before: 'Découvrez ou redécouvrez',
      text_after:  'Pour développer son histoire personnelle sur une année, tout en apprenant la dramaturgie.'
    }

    within('form#spotlight_form') do
      @dproj.each do |prop, val|
        fill_in( "spotlight_#{prop}", with: val)
      end
      shot 'spotlight-form-filled'
      click_button 'Actualiser'
    end
    expect(page).to have_tag('div.notice', text: 'Nouveau coup de projecteur enregistré.')
    success 'l’administrateur peut définir les nouvelles données et soumettre le formulaire avec succès'

    # ======== VÉRIFICATION DANS LA BASE ===========
    @dproj.each do |prop, val|
      expect(site.get_var("spotlight_#{prop}").force_encoding('utf-8')).to eq @dproj[prop]
    end
    success 'les nouvelles données du coup de projecteur sont enregistrées dans la base'

    # ======== VÉRIFICATION SUR LA PAGE D'ACCUEIL =========

    click_link 'boite'
    shot 'retour-home-page'
    expect(page).to have_tag('section#home_spotlight') do
      with_tag('div', text: @dproj[:objet])
      with_tag('a', with:{href: @dproj[:route]})
      with_tag('div#spotlight_text_before', text: @dproj[:text_before])
      with_tag('div#spotlight_text_after', text: @dproj[:text_after])
    end

  end
end
