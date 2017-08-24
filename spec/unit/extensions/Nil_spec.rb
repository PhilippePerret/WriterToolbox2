describe 'NilClass' do
  describe '#nil_if_empty' do
    it 'répond' do
      expect(nil).to respond_to :nil_if_empty
    end
    it 'retourne nil dans tous les cas' do
      expect(nil.nil_if_empty).to eq nil
    end
  end
end
