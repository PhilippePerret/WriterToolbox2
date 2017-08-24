require_lib_site
require_support_db_for_test

describe 'User' do
  describe 'get' do
    it 'répond' do
      expect(User).to respond_to :get
    end
    it 'retourne nil si l’on demande un user inexistant' do
      truncate_table_users
      res = User.get(100)
      expect(res).to be_nil
    end
    it 'retourne l’instance user si l’on demande un user existant' do
      res = User.get(1)
      expect(res).not_to eq nil
      expect(res).to be_a(User)
      expect(res.pseudo).to eq 'Phil'
      res = User.get(3)
      expect(res.pseudo).to eq 'Marion'
    end
    it 'enregistre l’user dans une table' do
      User._users = nil
      res = User.get(1)
      expect(User._users).not_to eq nil
      expect(User._users).to be_a(Hash)
      expect(User._users).to have_key(1)
      expect(User._users[1]).to be_a(User)
      expect(User._users[1].pseudo).to eq 'Phil'
    end
  end
end
