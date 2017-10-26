require_lib_site

describe 'site.titre_page' do
  it 'répond' do
    expect(site).to respond_to :titre_page
  end
  context 'sans argument' do
    context 'avec un titre simple (sans tag HTML)' do
      it 'retourne le titre simple' do
        # On définit la page
        site.titre_page('Mon titre de page')
        # On le récupère pour TITLE
        res = site.titre_page
        # Noter que l'espace avant est normal
        expect(res).to eq ' Mon titre de page'
      end
    end
    context 'avec un titre à balise' do
      it 'retourne le texte simple' do
        # On définit le titre
        site.titre_page('Mon <i>titre> avec <b>balises</b>')
        # On le récupère
        expect(site.titre_page).to eq ' Mon titre> avec balises'
      end
    end
  end
  context 'avec un seul argument' do
    it 'définit le titre de la page, en le mettant entre balises h2' do
     titre = "Mon titre de page"
     res = site.titre_page(titre)
     expect(res).to have_tag('h2', text: 'Mon titre de page')
    end
  end

  context 'avec des options' do
    context 'définissant la class CSS' do
      it 'applique la classe au titre' do
        res = site.titre_page('Mon titre', {class: 'maClasse'})
        expect(res).to eq '<h2 class="maClasse">Mon titre</h2>'
      end
    end
    context 'définissant l’identifiant de titre' do
      it 'applique cet ID' do
        res = site.titre_page('Mon titre avec ID', {id: 'monID'})
        expect(res).to eq '<h2 id="monID">Mon titre avec ID</h2>'
      end
    end

    context 'définissant des “under-buttons”' do
      it 'ajouter ces under-buttons' do
        res = site.titre_page('Mon titre avec boutons',{
          under_buttons: ['<a href="#monlien">Mon lien</a>', '<a href="#lien2">Lien 2</a>']
        })
        expect(res).to have_tag('div', with:{class:'under-buttons'}) do
          with_tag('a', with: {href: "#monlien"}, text: 'Mon lien')
          with_tag('a', with: {href: "#lien2"}, text: 'Lien 2')
        end
      end
    end
  end
end
