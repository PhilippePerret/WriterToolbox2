
require_lib_site

describe 'User properties' do
  describe '#dispatch' do
    it 'répond' do
      expect(user).to respond_to :dispatch
    end
    it 'permet de dispatcher les données dans l’instance' do
      pending
    end
  end

  describe '#set' do
    it 'répond' do
      expect(user).to respond_to :set
    end
    it 'actualise les données dans la base de données' do
      pending
    end
    it 'dispatch les données dans l’instance' do
      pending
    end
  end
end
