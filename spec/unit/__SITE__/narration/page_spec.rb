require_lib_site

load_route('narration/page')

describe 'Page Narration' do
  let(:page) { @page ||= Narration::Page.new(6) }
  describe '#titre_chapitre' do
    it 'répond' do
      expect(page).to respond_to :titre_chapitre
    end
    it 'retourne le titre du chapitre' do
      expect(page.titre_chapitre).to have_tag('span', with:{class:'chap_titre'}) do
        with_tag('a', with:{href: "narration/page/1"}, text: 'Introduction à la structure')
      end
    end
  end

  describe '#titre_sous_chapitre' do
    it 'répond' do
      expect(page).to respond_to :titre_sous_chapitre
    end
    it 'retourne le titre du sous-chapitre' do
      expect(page.titre_sous_chapitre).to have_tag('span', with:{class:'schap_titre'}) do
        with_tag('a', with:{href: 'narration/page/2'}, text: 'Prologue')
      end
    end
  end
end
