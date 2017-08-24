
describe 'String extensions' do
  before(:all) do
    require './lib/extensions/String'
  end
  describe '#nil_if_empty' do
    it 'respond' do
      expect('string').to respond_to :nil_if_empty
    end
    it 'retourne nil si la string est vide' do
      expect(''.nil_if_empty).to be_nil
    end
    it 'retourne le string si le string n’est pas nil' do
      expect('string'.nil_if_empty).to eq 'string'
    end
  end

  describe '#titleize' do
    it 'répond' do
      expect('string').to respond_to :titleize
    end
    context 'avec une première lettre non accentuée et non diacritique' do
      it 'passe la première lettre (seulement) en capitale' do
        expect('string encore'.titleize).to eq 'String encore'
      end
    end
    context 'avec une première lettre accentée' do
      it 'la passe en capitale' do
        expect('été indien'.titleize).to eq 'Été indien'
      end
    end
    context 'avec une première lettre diacritique' do
      it 'la passe en capitale' do
        expect('ça va bien'.titleize).to eq 'Ça va bien'
      end
    end
  end
end
