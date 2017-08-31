=begin

Cette feuille de test vérifie tous les liens partant de l'accueil

=end
require_support_integration

feature "Depuis l'accueil" do
  scenario "=> tous les liens de la page d'accueil sont valides" do

    visit home_page

    # Données des liens
    # On ajoutera :url au cours de la recherche dans la page
    data_liens = {
      'unanunscript/home' => {titre: 'Le programme UN AN UN SCRIPT'},
      'site/phil'         => {titre: "Philippe Perret"},
      'site/charte'       => {titre: 'Charte du site'},
      'user/signin'       => {titre: 'S’identifier'},
      'user/signup'       => {titre: 'S’inscrire sur le site'},
      'user/profil'       => {titre: 'Votre profil'},
      'user/suscribe'     => {titre: 'Soutenir le site'},
      'outils'            => {titre: 'Outils d’écriture'},
    }

    # On relève tous les liens sur la page d'accueil pour les
    # suivre
    # TODO À l'avenir, on pourra essayer de parcourir l'intégralité des
    # liens.
    links_checked = Hash.new
    page.all('a').each do |lien|
      href = lien['href']

      href != nil || next

      # puts "HREF: #{href.inspect}"
      full_url = "#{href}"
      href = href.sub(/^#{base_url}\/?/,'')

      full_url != '' || next
      links_checked.key?(full_url) && next
      full_url.match(/WriterToolbox2/) || next

      titre = lien.text

      data_liens[href] || raise("La route '#{href}' doit être définie dans les données de liens partant de la page d'accueil")

      data_liens[href].merge!(url: full_url)
    end


    # On vérifie tous les liens
    data_liens.each do |href, dhref|

      visit dhref[:url]
      success "Le lien `#{dhref[:url]}`…"
      expect(page).to have_tag('h2', text: dhref[:titre])
      success "…est valide"
      links_checked.merge!(href => true)

      # On revient à l'accueil
      visit home_page

    end
  end
end
