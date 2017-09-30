require_lib_site

describe Fixnum do
  describe '#as_human_date' do
    it 'répond' do
      expect(1).to respond_to :as_human_date
    end
    context 'sans argument' do
      it 'retourne la valeur au format par défaut' do
        x = Time.now.to_i
        f = Time.now.strftime('%d %m %Y - %H:%M')
        expect(x.as_human_date).to eq f
      end
    end

    context 'avec un argument définissant le format' do
      it 'retourne la valeur au format demandé' do
        fmt = '%d %m %Y'
        x = Time.now.to_i
        expect(x.as_human_date(fmt)).to eq Time.now.strftime(fmt)
      end
    end
  end
end
