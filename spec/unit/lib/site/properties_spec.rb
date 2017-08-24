require_lib_site

describe 'Site' do
  describe '#admin' do
    it 'répond' do
      expect(site).to respond_to :admin
    end
    it 'retourne l’instance User de l’administrateur Phil' do
      expect(site.admin).to be_a(User)
      expect(site.admin.id).to eq 1
      expect(site.admin.pseudo).to eq 'Phil'
    end
  end
end
