=begin

  Test général de la page d'accueil telle qu'elle doit se présenter
  à un visiteur quelconque

=end

require_lib_site
require_support_integration

feature "Page d'accueil" do
  scenario "Un visiteur quelconque trouve une page valide" do

    # ========= PRÉPARATION ============
    site.set_var('spotlight_objet', 'collection Narration')
    site.set_var('spotlight_text_after', 'les cours de narration en ligne de Philippe Perret')
    site.set_var('spotlight_route', 'narration/home')


    # ============> TEST <============
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
    expect(page).to have_tag('section', with:{id: 'incipit'}) do
      with_tag( 'img', with:{src: './img/phil-medaillon.png'})
      success '… le médaillon de Phil'
      with_tag('a', with:{href: 'site/phil'}, text: 'philippe perret')
      success '… un lien conduisant au profil de Phil'
      with_tag('a', with:{href: 'site/charte'}, text: /charte/i)
      success '… un lien conduisant à la charte du site'
    end

    expect(page).to have_tag('section', with:{id: 'home_spotlight'}) do
      with_tag('a', with: {href: 'narration/home'}, text: 'collection Narration')
      with_tag('div', text: 'les cours de narration en ligne de Philippe Perret')
    end
    success 'le visiteur trouve une section avec le coup de projecteur sur Narration et un lien y conduisant'

    expect(page).to have_tag('section', with:{id:'suscribe'}) do
      with_tag('a', with:{href:'user/suscribe'}, text: 'S’ABONNER')
    end
    success 'le visiteur trouve un cadre d’abonnement avec un lien pour s’abonner au site'


    expect(page).to have_tag('fieldset', with:{id: 'last_updates'})
    success 'le visiteur trouve un fieldset avec les dernières actualités'



    expect(page).to have_tag('fieldset', with:{id: 'last_article'}) do
      require './__SITE__/blog/current_article'
      with_tag('a', with:{href: "blog/lire/#{CURRENT_ARTICLE_ID}" } )
      with_tag('h3')
    end
    success 'le visiteur trouve une section contenant le dernier article de blog'


    success 'le visiteur trouve un pied de page…'
    expect(page).to have_tag('section', with:{id:'footer'}) do
      without_tag('a', with:{href:''}, text: 'accueil')
      success '… sans lien pour revenir à la page d’accueil'
      with_tag('a', with:{href:'site/contact'}, text: 'contact')
      success '… un lien pour rejoindre le formulaire de contact'
      without_tag('a', with:{href:'outils'}, text: 'tous les outils')
      success '… sans lien pour rejoindre la liste des outils'
    end
    success 'donc un pied de page valide'

  end
end
