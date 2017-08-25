
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

  describe '#set_bit' do
    it 'répond' do
      expect('string').to respond_to :set_bit
    end
    context 'sans base définie' do
      it 'permet de modifier un bit' do
        expect('0000000000'.set_bit(2, 9)).to eq '0090000000'
        expect('0090000000'.set_bit(9, 2)).to eq '0090000002'
      end
    end
    context 'avec une base définie' do
      it 'modifie le bit dans la base voulue' do
        [
          [9,  10, '000900'],
          [10, 11, '000a00'],
          [15, 16, '000f00'],
          [35, 36, '000z00']
        ].each do |provided, base, expected|
          expect('000000'.set_bit(3, provided, base)).to eq expected
        end
      end
    end
  end

  describe '#get_bit' do
    it 'répond' do
      expect('string').to respond_to :get_bit
    end
    context 'sans base définie' do
      it 'retourne le bit voulu en base 10' do
        expect("0000000008".get_bit(9)).to eq 8
        expect("0000000004".get_bit(9)).to eq 4
      end
    end
    context 'avec une base définie' do
      it 'retourne le bit dans la base voulue' do
        [
          ['00a',   11, 10],
          ['00z00', 36, 35]
        ].each do |provided, base, expected|
          expect(provided.get_bit(2,base)).to eq expected
        end
      end
    end
  end

end
