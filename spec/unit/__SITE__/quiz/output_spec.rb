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

  it 'produit un code en exécutant le code ERB' do
    q = Quiz.new(21)
    q.data[:output] = 'Une opération est égale à <%= 2+3 %>.'
    expect(q.output).to include 'Une opération est égale à 5.'
  end

  describe 'produit un code qui contient' do
    let(:code) { @code ||= Quiz.new(21).output }
    it '…un formulaire' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"})
    end
    it '… l’identifiant du quiz' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"}) do
        with_tag('input', with: {type: 'hidden', name:'quiz[id]', id: 'quiz_id', value: '21'})
      end
    end
    it '… l’identifiant de l’user faisant le quiz' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"}) do
        with_tag('input', with: {type: 'hidden', name:'quiz[owner]', id: 'quiz_owner'})
      end
    end
    it '… le div du questionnaire lui-même' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"}) do
        with_tag('div', with: {class: 'quiz', id: "quiz-21"})
      end
    end
    it '… un bouton pour soumettre le questionnaire' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"}) do
        with_tag('input', with:{type: 'submit', value: "Soumettre ce quiz"})
      end
    end
  end

  context 'sans output défini' do
    before(:all) do
      @q.set(output: nil)
    end
    it 'construit la sortie' do
      expect(q.data[:output]).to eq nil
      # ========> TEST <===========
      q.output
      # =========== VÉRIFICATIONS =============
      expect(q.data[:output]).not_to eq nil
    end
  end

  context 'avec un output défini' do
    after(:all) do
      Quiz.new(21).set(output: nil)
    end
    it 'reprend ce output tout simplement' do
      q = Quiz.new(21)
      q.set(output: 'Le output provisoire')
      expect(q.output).to include 'Le output provisoire'
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
