require_lib_site


describe 'User' do
  before(:all) do
    @huser = site.db.select(:hot,'users',"1 = 1 LIMIT 1").first
  end

  let(:huser) { @huser }
  let(:u) { @u ||= User.get(huser[:id]) }


  describe '#route' do
    it 'répond' do
      expect(u).to respond_to :route
    end
    context 'sans argument' do
      it 'retourne la route vers le profil de l’user' do
        expect(u.route).to eq "user/profil/#{huser[:id]}"
      end
    end

    context 'avec un premier argument true ou :online' do
      it 'retourne la route online' do
        uri = "http://#{site.configuration.url_online}/user/profil/#{huser[:id]}"
        expect(u.route(true)).to eq uri
        expect(u.route(:online)).to eq uri
      end
    end
    context 'avec un premier argument nil ou :offline' do
      it 'retourne la route offline' do
        uri = "user/profil/#{huser[:id]}"
        expect(u.route(nil)).to eq uri
        expect(u.route(:offline)).to eq uri
      end
    end

  end
end
