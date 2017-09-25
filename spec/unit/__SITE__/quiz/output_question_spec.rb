=begin

  Test de la classe Quiz::Question qui n'est définie que lorsqu'il
  faut construire le questionnaire

=end
require_lib_site
site.load_folder 'quiz'

describe Quiz::Question do
  before(:all) do
    q = Quiz.new(21)
    q.require_module 'build_output'
  end

  describe '#initialize' do
    it 'on peut initialiser une question avec son ID' do
      q = Quiz::Question.new(1)
      expect(q).to be_a(Quiz::Question)
    end
    it 'une question initialisée seulement avec son ID n’a pas de quiz' do
      q = Quiz::Question.new(2)
      expect(q.quiz).to eq nil
    end
    it 'une question initialisée avec son ID et un quiz connait son quiz' do
      q = Quiz::Question.new(2, Quiz.new(21))
      expect(q.quiz).not_to eq nil
      expect(q.quiz).to be_a(Quiz)
      expect(q.quiz.id).to eq 21
    end
  end

  describe '#question' do
    let(:question) { @question = Quiz::Question.new(10) }
    it 'répond' do
      expect(question).to respond_to :question
    end
    it 'retourne le string de la question' do
      res = question.question
      expect(res).to be_a String
      expect(res).to eq site.db.select(:quiz,'questions',{id:10},[:id,:question]).first[:question]
    end
  end

  describe '#reponses' do
    let(:question) { @question = Quiz::Question.new(1) }
    it 'répond' do
      expect(question).to respond_to :reponses
    end
    it 'retourne une liste d’instances Quiz::Question::Reponse' do
      res = question.reponses
      expect(res).to be_instance_of Array
      expect(res.first).to be_instance_of Quiz::Question::Reponse
    end
  end

  describe '#output' do
    let(:question) { @question ||= Quiz::Question.new(10, Quiz.new(21)) }
    it 'répond' do
      expect(question).to respond_to :output
    end
    # context 'avec une question dont les réponses doivent être affichée verticalement' do
    #   pending
    # end
    # context 'avec une question dont les réponses doivent être affichée horizontalement' do
    #   pending
    # end
    # context 'avec un question dont les réponses doivent être affichés dans l’ordre' do
    #   pending
    # end
    # context 'avec un question dont les réponses doivent être affichés dans le désordre' do
    #   pending
    # end
    describe 'le code retourné contient…' do
      # Note : attention, c'est seulement le code final du quiz qui va évaluer le
      # code ERB contenu. Donc, ici, on le trouve dans le code en brut.
      let(:code) { @code ||= begin
        c = question.output
        puts "Code question : #{c.inspect}"
        c
      end}

      it 'le div principal de la question' do
        expect(code).to have_tag('div', with:{id: "qz-21-q-#{question.id}"})
      end

      it 'le code ERB pour déterminer si la question est OK ou non' do
        classe = "class=\"<%= Quiz[21].class_question(#{question.id}) %>\""
        expect(code).to include(classe)
      end
      it 'le div du texte de la question' do
        expect(code).to have_tag("div#qz-21-q-#{question.id}") do
          with_tag('div', with: {class:'libelle'}, text: 'Première question')
        end
      end
      it 'la liste des réponses possibles' do
        expect(code).to have_tag("div#qz-21-q-#{question.id}") do
          with_tag('ul', with: {class: "reponses #{question.specs[1]}"})
        end
      end

      it 'le code ERB pour sélectionner les réponses éventuelles' do
        expect(code).to have_tag("div#qz-21-q-#{question.id}") do
          question.reponses.each do |reponse|
            expect(reponse).to be_a Quiz::Question::Reponse

            # La réponse est contenue dans un LI
            rep_id = "qz-21-q-#{question.id}-r-#{reponse.index}"
            with_tag('li', with: {id: "li-#{rep_id}"}) do
              # Un LI qui contient le label de la réponse
              with_tag('label', text: reponse.libelle)
              if question.specs[0] == 'c'
                # Un CB avec le bon ID et le bon NAME
                with_tag('input', with: {type: 'checkbox', id: rep_id, name: rep_id})
              else
                # Un RADIO avec le bon ID et le bon NAME
                with_tag('input', with: {type: 'radio', id: rep_id, name: "qz-21-q-#{question.id}"})
              end
            end

            # Le sous-code pour régler la class du LI de réponse
            souscode = "<%=Quiz[21].class_li_reponse(#{question.id},#{reponse.index})"
            expect(code).to include souscode
            # Le sous-code pour régler le checked du checkbox ou du radio
            souscode = "<%=Quiz[21].code_checked(#{question.id},#{reponse.index})"
            expect(code).to include souscode
          end
        end
      end

    end
  end



end
