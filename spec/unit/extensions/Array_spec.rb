
require_lib_site

describe Array do
  let(:arr) { @arr ||= [1,2,3,4] }
  describe '#nil_if_empty' do
    it 'répond' do
      expect(arr).to respond_to :nil_if_empty
    end
    it 'retourne nil si la liste est vide' do
      expect([].nil_if_empty).to eq nil
    end
    it 'retourne la liste si elle n’est pas vide' do
      expect(arr.nil_if_empty).to eq arr
    end
  end


  describe 'pretty_join' do
    it 'répond' do
      expect(arr).to respond_to :pretty_join
    end
    it 'donne simplement l’élément avec un seul élément dans la liste' do
      expect(['seul'].pretty_join).to eq 'seul'
    end
    it 'donne une liste se terminant par « et » quand plusieurs éléments' do
      expect(['je', 'ne','suis','pas','seul'].pretty_join).to eq 'je, ne, suis, pas et seul'
    end
  end
end
