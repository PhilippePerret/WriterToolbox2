require_lib_site
require_folder './__SITE__/blog/_lib/'

describe Blog do
  describe 'module home' do
    it 'exist' do
      expect(File.exist?('./__SITE__/blog/_lib/module/home.rb')).to be true
    end
    it 'définit la méthode #home_extract' do
      require './__SITE__/blog/_lib/module/home.rb'
      expect(Blog).to respond_to :home_extract
    end
    describe '#home_extract' do
      it 'répond' do
        expect(Blog).to respond_to :home_extract
      end
      it 'retourne l’extrait du dernier article pour l’accueil' do
        res = Blog.home_extract
        expect(res).to have_tag('section#last_article') do
          with_tag('a', with:{href: "blog/lire/#{Blog.last_article_id}"})
          with_tag('span', with:{id:'extrait_article'})
          with_tag('span', text: '[lire la suite]')
        end
      end
    end
  end
end
