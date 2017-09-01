=begin
Test de la partie publique du blog.
On doit pouvoir y lire tous les articles et même les commenter.

=end

require_lib_site
require_support_integration


feature "Partie publique du blog (articles)" do
  before(:all) do
    require './__SITE__/blog/current_article.rb' # => CURRENT_ARTICLE_ID
  end
  # Retourne le code du dernier article
  def last_article
    @last_article ||= begin
      affixe = CURRENT_ARTICLE_ID.to_s.rjust(4,'0')
      folder_articles = './__SITE__/blog/articles'
      mdpath = File.join(folder_articles,"#{affixe}.md")
      if File.exist? mdpath
        kramdown(mdpath)
      else
        deserb(File.join(folder_articles,"#{affixe}.erb"))
      end
    end
  end
  scenario "Un visiteur quelconque peut rejoindre le blog par l'accueil" do
    visit home_page
    expect(page).to have_tag('a', with:{href:"blog/lire/#{CURRENT_ARTICLE_ID}"})
    page.find("a[href=\"blog/lire/#{CURRENT_ARTICLE_ID}\"]", match: :first).click
    expect(page).to have_tag('h2', text: "Blog de Phil")

    expect(page).to have_tag('span#article_id', text: "Article ##{CURRENT_ARTICLE_ID}")
    expect(page).to have_tag('h3')
    expect(page).to have_content(last_article.gsub(/<(.*?)>/, ' ')[100..200])
    success 'le visiteur trouve une page avec le titre et l’article'

    expect(page).to have_tag('a', with:{href: "blog/lire/#{CURRENT_ARTICLE_ID - 1}"})
    success 'le visiteur trouve un lien pour lire l’article précédent'

    expect(page).not_to have_tag('a', with:{href: "blog/lire/#{CURRENT_ARTICLE_ID + 1}"})
    success 'le visiteur ne trouve pas de lien pour lire l’article suivant'

    expect(page).not_to have_link('éditer l’article')
    success 'le visiteur ne trouve pas de lien pour éditer l’article'
  end

  scenario 'Un administrateur trouve un lien pour éditer l’article' do
    identify phil
    visit "#{base_url}/blog/lire/#{CURRENT_ARTICLE_ID}"
    expect(page).to have_tag('h2', text: /Blog de Phil/) do
      with_tag('a', with:{href:"admin/blog/#{CURRENT_ARTICLE_ID}?op=edit"}, text:'éditer l’article')
    end
    click_link('éditer l’article', match: :first)
    expect(page).to have_tag('h2', text: 'Administration du blog')
  end
end
