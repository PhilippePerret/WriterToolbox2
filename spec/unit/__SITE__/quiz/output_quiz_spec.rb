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
    it '… un formulaire' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"})
    end
    it '… la route à suivre pour soumettre le quiz' do
      expect(code).to have_tag('form', with:{class: 'quiz_form', id: "quiz_form-21"}) do
        with_tag('input', with: {type: 'hidden', name:'operation', value: 'evaluate_quiz'})
      end
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

  # Retourne le nombre de questions dans le codes fourni
  def nombre_questions_in code
    code.scan(/div([^>]+)class="question"/).to_a.count
  end
  def ids_questions_in code
    code.scan(/div(?:[^>]+)id="([a-z0-9\-]+)"(?:[^>]+)class="question"/).to_a.collect do |tout,rien|
      # puts "tout:#{tout.inspect} / rien:#{rien.inspect}"
      tout.split('-').last.to_i
    end
  end

  describe 'enregistrement dans la base' do
    before(:all) do
      site.db.update(:quiz,'quiz',{output:nil},{id: 21})
    end
    it 'la construction enregistre le output construit dans la table' do
      q = Quiz.new(21)
      res = site.db.select(:quiz,'quiz',{id: 21},[:output]).first
      expect(res[:output]).to eq nil
      # ========> TEST <=========
      q.output
      # ========= VÉRIFICATION ========
      res = site.db.select(:quiz,'quiz',{id: 21},[:output]).first
      expect(res[:output]).not_to eq nil
    end
  end

  context 'avec un nombre de questions définies' do
    it 'ne met que ce nombre de questions' do
      q = Quiz.new(11)
      questions_ids = q.data[:questions_ids].as_id_list
      nombre_questions_init = questions_ids.count
      # ==========> TEST <===========
      q.data[:specs][9] = '1'

      [4, 8, 5].each do |nombre_questions_expected|
        q.data[:specs][10..12] = nombre_questions_expected.to_s.rjust(3,'0')
        code = q.output
        expect(nombre_questions_in(code)).to eq nombre_questions_expected
        q.data[:output] = nil
      end
    end
  end

  context 'avec des questions dans le désordre' do
    before(:all) do
      site.db.update(:quiz,'quiz',{output: nil},{id: 30})
    end
    after(:all) do
      site.db.update(:quiz,'quiz',{output: nil},{id: 30})
    end
    it 'mélange les questions' do
      q = Quiz.new(30)
      questions_ids = q.data[:questions_ids].as_id_list
      # ==========> TEST <===========
      q.data[:specs][9] = '0' # => dans l'ordre
      code = q.output
      expect(ids_questions_in(code)).to eq questions_ids
      q.data[:output] = nil

      q.data[:specs][9] = '1' # => dans le désordre
      code = q.output
      expect(ids_questions_in(code)).not_to eq questions_ids
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
