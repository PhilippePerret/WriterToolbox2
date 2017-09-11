feature "Bureau d'un auteur du programme UN AN UN SCRIPT" do
  before(:all) do
    @data_auteur = unanunscript_create_auteur
  end

  let(:auteur) { @data_auteur }

  scenario "un auteur non inscrit au programme ne peut pas rejoindre le bureau UN AN" do
    visit "#{base_url}/unanunscript/bureau"
    expect(page).not_to have_tag('h2', text: 'Votre bureau UN AN UN SCRIPT')
  end

  scenario 'suivant ses préférences, l’auteur inscrit au programme rejoint son bureau après l’identification' do
    # TODO Régler les options de l'auteur pour qu'il rejoigne son bureau après
    # son identification
    u = User.get(auteur[:id])
    u.set_var('goto_after_login', 9)
    identify auteur
    expect(page).to have_tag('h2', text: 'Votre bureau UN AN UN SCRIPT')

  end
  scenario 'un auteur inscrit au programme peut rejoindre son bureau UN AN UN SCRIPT' do
    # TODO Faire un auteur UN AN UN SCRIPT
    # TODO S'assurer que ses préférences sont réglés de telle sorte qu'il
    # rejoint l'accueil à son identification
    # TODO Identifier l'auteur
    identify auteur
    expect(page).to have_link 'Votre programme UN AN UN SCRIPT'
    click_link('Votre programme UN AN UN SCRIPT')
    expect(page).to have_tag('h2', text: 'Votre bureau UN AN UN SCRIPT')
  end
end
