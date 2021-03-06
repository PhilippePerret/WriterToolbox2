=begin

  Tests unitaires des quiz
  Généralités

=end
require_lib_site
site.load_folder 'quiz'

describe Quiz do
  describe 'Class' do
    it 'définit la base et la table des quiz' do
      q = Quiz.new(21)
      expect(q).to respond_to :base_n_table
      expect(q.base_n_table).to eq [:quiz, 'quiz']
    end
  end
  describe 'Instance' do
    let(:q) { @q ||= Quiz.new(21) }
    it 'on peut instancier un quiz avec son ID' do
      tq = Quiz.new(1)
      expect(tq).to be_a(Quiz)
    end
    describe '#base_n_table' do
      it 'répond à #base_n_table' do
        expect(q).to respond_to :base_n_table
      end
      it 'qui retourne la bonne valeur' do
        expect(q.base_n_table).to eq [:quiz, 'quiz']
      end
    end

    describe '#get' do
      it 'répond' do
        expect(q).to respond_to :get
      end
      it 'retourne une valeur du quiz' do
        expect(q.get(:titre)).to eq 'Test quiz'
      end
    end


    describe '#output' do
      it 'répond' do
        expect(q).to respond_to :output
      end
      it 'retourne le code HTML du questionnaire' do
        expect(q.output).to have_tag('div',with: {class: 'quiz'})
      end
    end
  end
end
