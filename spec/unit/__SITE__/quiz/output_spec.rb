=begin

  Test de la sortie du quiz

=end
require_lib_site
site.load_folder 'quiz'

describe 'Quiz#output' do
  before(:all) do
    @q = Quiz.new(21) # le quiz test
  end

  let(:q) { Quiz.new(21) }

  context 'sans output défini' do
    before(:all) do
      @q.set(output: nil)
    end
    it 'construit la sortie' do
      pending
    end
  end

  context 'avec un output défini' do
    after(:all) do
      Quiz.new(21).set(output: nil)
    end
    it 'reprend ce output tout simplement' do
      q = Quiz.new(21)
      q.set(output: 'Le output provisoire')
      expect(q.output).to eq 'Le output provisoire'
    end
  end

  context 'sans résultats déjà fournis' do
    it 'ne met aucun résultat' do
      pending
    end
  end

  context 'avec des résultats fournis' do
    it 'remet ces résultats' do
      pending
    end
  end
end
