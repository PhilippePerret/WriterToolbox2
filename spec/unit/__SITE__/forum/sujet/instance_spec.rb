require_lib_site


describe 'Forum::Sujet' do
  before(:all) do
    require_folder('./__SITE__/forum/_lib/_required')
    expect(defined?(Forum)).to eq 'constant'
    expect(defined?(Forum::Sujet)).to eq 'constant'

    @hsujet = site.db.select(:forum,'sujets',"1 = 1 LIMIT 1").first

  end

  let(:hsujet) { @hsujet }
  let(:sujet) { @sujet ||= Forum::Sujet.new(hsujet[:id]) }


  describe '#route' do
    context 'sans argument' do
      it 'retourne la route vers le sujet' do
        expect(sujet.route).to eq "forum/sujet/#{hsujet[:id]}?from=1"
      end
    end

    context 'avec un premier argument true ou :online' do
      it 'retourne la route online' do
        uri = "http://#{site.configuration.url_online}/forum/sujet/#{hsujet[:id]}?from=1"
        expect(sujet.route(true)).to eq uri
        expect(sujet.route(:online)).to eq uri
      end
    end
    context 'avec un premier argument nil ou :offline' do
      it 'retourne la route offline' do
        uri = "forum/sujet/#{hsujet[:id]}?from=1"
        expect(sujet.route(nil)).to eq uri
        expect(sujet.route(:offline)).to eq uri
      end
    end

    context 'avec un second argument true (fin du sujet)' do
      it 'retourne la route vers le dernier message' do
        expect(sujet.route(nil, true)).to eq "forum/sujet/#{sujet.id}?from=-1"
      end
    end
    context 'avec un second argument nil ou false (début du sujet)' do
      it 'retourne la route vers le premier message' do
        uri = "forum/sujet/#{sujet.id}?from=1"
        expect(sujet.route(nil, nil)).to eq uri
        expect(sujet.route(nil, false)).to eq uri
      end
    end
  end
end
