require_support_integration

feature "Le pied de page" do

  def check_lien dlien
    href, titre, message = dlien
    expect(page).to have_tag('section#footer') do
      with_tag('a', with:{href: href}, text:titre)
      success "… possède un lien #{message}"
    end
  end

  scenario "=> est conforme, pour la page d'accueil" do
    visit home_page
    success 'de la page d’accueil…'
    [
      ['site/contact', 'contact', 'vers le formulaire de contact'],
      ['user/signin', 's’identifier', 'pour s’identifier'],
      ['user/signup', 's’inscrire', 'pour s’identifier'],
      ['user/suscribe', 's’abonner', 'pour s’abonner']
    ].each do |dlien|
      check_lien dlien
    end
    expect(page).to have_tag('section#footer') do
      without_tag('a', with:{href:''}, text: 'accueil')
      success '… ne possède pas de lien vers elle'
      without_tag('a', with:{href:'outils'}, text: 'outils')
      success '… ne possède pas de lien vers les outils '
    end
  end

  scenario '=> est conforme pour une page quelconque' do
    visit "#{base_url}/unanunscript/home"
    [
      ['', 'accueil', 'vers l’accueil'],
      ['outils', 'outils', 'vers les outils'],
      ['site/contact', 'contact', 'vers le formulaire de contact'],
      ['user/signin', 's’identifier', 'pour s’identifier'],
      ['user/signup', 's’inscrire', 'pour s’identifier'],
      ['user/suscribe', 's’abonner', 'pour s’abonner']
    ].each do |dlien|
      check_lien dlien
    end
  end
end
