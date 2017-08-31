=begin

  Test général de la page d'accueil telle qu'elle doit se présenter
  à un visiteur quelconque

=end
feature "Page d'accueil" do
  scenario "Un visiteur quelconque trouve une page valide" do
    visit home_page

    success 'le visiteur trouve une bande logo contenant…'
    expect(page).to have_tag('section', with:{id:'header', class:'home'}) do
      with_tag( 'a', with:{href:'user/signin'}, text: 's’identifier')
      success '… un lien pour s’identifier'
      with_tag('a', with:{href: 'user/signup'}, text: 's’inscrire')
      success '… un lien pour s’inscrire'
      with_tag('a', with:{href: ''}, text: 'boite')
      success '… un lien pour revenir à l’accueil'
      with_tag('a', with:{href: 'outils'}, text: 'outils')
      success '… un lien pour aller à la liste des outils'
      with_tag('a', with:{href: 'user/profil'}, text: 'auteur')
      success '… un lien pour aller au profil de l’auteur'
    end
    success 'donc un entête valide.'

    success 'le visiteur trouve un incipit contenant…'
    expect(page).to have_tag('div', with:{id: 'incipit'}) do
      with_tag( 'img', with:{id: 'medaillon_phil_accueil'})
      success '… le médaillon de Phil'
      with_tag('a', with:{href: 'site/phil'}, text: 'Philippe Perret')
      success '… un lien conduisant au profil de Phil'
      with_tag('a', with:{href: 'site/charte'}, text: /charte/)
      success '… un lien conduisant à la charte du site'
    end

    # TODO Mettre le coup de projecteur à la collection narration
    expect(page).to have_tag('section', with:{id: 'home_spotlight'}) do
      with_tag('a', with: {href: 'narration/home'}, text: 'collection Narration')
    end
    success 'le visiteur trouve une section avec le coup de projecteur sur Narration et un lien y conduisant'

    expect(page).to have_tag('fieldset', with:{id: 'last_updates'})
    success 'le visiteur trouve un fieldset avec les dernières actualités'

    expect(page).to have_tag('section', with:{id: 'last_post'})
    success 'le visiteur trouve une section contenant le dernier article de blog'

    expect(page).to have_tag('a', with:{href:'user/suscribe'}, text: 's’abonner')
    success 'le visiteur trouve un lien pour s’abonner au site'

    success 'le visiteur trouve un pied de page avec…'
    expect(page).to have_tag('section', with:{id:'footer'}) do
      with_tag('a', with:{href:''}, text: 'accueil')
      success '… un lien pour revenir à la page d’accueil'
      with_tag('a', with:{href:'site/contact'}, text: 'contact')
      success '… un lien pour rejoindre le formulaire de contact'
      with_tag('a', with:{href:'outils'}, text: 'tous les outils')
      success '… un lien pour rejoindre la liste des outils'
    end
    success 'donc un pied de page valide'

  end
end
