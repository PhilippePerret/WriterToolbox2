=begin

  Test des méthodes `creator?`, `corrector?` etc. utilisées pour les
  `Analyse::AFile::UFiler`

=end
require_lib_site

describe 'States d’un user quelconque' do

  def set_analyste u
    opts = u.data[:options]
    opts[16] = '3'
    u.instance_variable_set('@options', opts)
  end

  before(:all) do
    require_folder './__SITE__/analyser/_lib/_required'
    require_folder './__SITE__/analyser/file/_lib/_required'

    @huser =
      get_data_random_user(mail_confirmed: true, admin: false, analyste: true)
    @huser_non_analyste =
      get_data_random_user(mail_confirmed: true, admin: false, analyste: false)

    # On choisit une analyse faite
    hanalyse = site.db.select(
      :biblio, 'films_analyses',
      "SUBSTRING(specs,1,1) = '1' LIMIT 10"
    ).shuffle.shuffle.first
    @analyse = Analyse.new(hanalyse[:id])
    @afile = Analyse::AFile.new(nil)
    @tuser_analyste     = User.get(@huser[:id])
    @tuser_non_analyste = User.get(@huser_non_analyste[:id])
    expect(@tuser_non_analyste).not_to eq nil
  end
  before(:each) do
    @ua   = Analyse::AFile::UFiler.new(@analyse, @afile, @tuser_analyste)
    @una  = Analyse::AFile::UFiler.new(@analyse, @afile, @tuser_non_analyste)
  end

  let(:u) { @u }

  context 'avec un user non identifié', check: false do
    before(:each) do
      @u = Analyse::AFile::UFiler.new(@analyse, @afile, User.new(nil))
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne false' do
      expect(u).not_to be_redactor
    end
    it 'corrector? retourne false' do
      expect(u).not_to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'contributor? return false' do
      expect(u).not_to be_contributor
    end
    describe 'raccourcis d’état' do
      describe 'admin?' do
        it 'répond' do
          expect(u).to respond_to :admin?
        end
        it 'retourne false' do
          expect(u).not_to be_admin
        end
      end
      describe 'analyste?' do
        it 'répond' do
          expect(u).to respond_to :analyste?
        end
        it 'retourne false pour un user non identifé' do
          expect(u).not_to be_analyste
        end
      end
      describe 'identified?' do
        it 'répond' do
          expect(u).to respond_to :identified?
        end
        it 'retourne false' do
          expect(u).not_to be_identified
        end
      end
    end
  end


  context 'avec un simple inscrit', check: false do
    before do
      @u = @una
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne false' do
      expect(u).not_to be_redactor
    end
    it 'corrector? retourne false' do
      expect(u).not_to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
    it 'identified? retourne true' do
      expect(u).to be_identified
    end
    it 'analyste? retourne false' do
      expect(u).not_to be_analyste
    end
    it 'contributor? return false' do
      expect(u).not_to be_contributor
    end
  end

  context 'avec un administrateur sans lien avec l’analyse', check: false do
    before do
      @tuser_non_analyste.instance_variable_set('@is_admin', true)
      @u = @una
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne false' do
      expect(u).not_to be_redactor
    end
    it 'corrector? retourne false' do
      expect(u).not_to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'admin? retourne true' do
      expect(u).to be_admin
    end
    it 'identified? retourne true' do
      expect(u).to be_identified
    end
    it 'analyste? retourne false' do
      expect(u).not_to be_analyste
    end
    it 'contributor? return false' do
      expect(u).not_to be_contributor
    end
  end

  context 'avec le créateur du fichier (non administrateur)' do
    before do
      allow_any_instance_of(Analyse::AFile::UFiler).to receive(:role).and_return(1)
      @u = @ua
    end
    it 'creator? retourne vrai' do
      expect(u).to be_creator
    end
    it 'redactor? retourne true' do
      expect(u).to be_redactor
    end
    it 'corrector? retourne false' do
      expect(u).not_to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
    it 'identified? retourne true' do
      expect(u).to be_identified
    end
    it 'analyste? retourne true' do
      expect(u).to be_analyste
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
  end

  context 'avec un rédacteur non administrateur du fichier' do
    before do
      allow_any_instance_of(Analyse::AFile::UFiler).to receive(:role).and_return(2)
      @u = @ua
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne true' do
      expect(u).to be_redactor
    end
    it 'corrector? retourne false' do
      expect(u).not_to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
    it 'identified? retourne true' do
      expect(u).to be_identified
    end
    it 'analyste? retourne true' do
      expect(u).to be_analyste
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
  end

  context 'avec un correcteur (non administrateur) du fichier' do
    before do
      allow_any_instance_of(Analyse::AFile::UFiler).to receive(:role).and_return(2|4)
      @u = @ua
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne true (il l’est aussi)' do
      expect(u).to be_redactor
    end
    it 'corrector? retourne true' do
      expect(u).to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
    it 'identified? retourne true' do
      expect(u).to be_identified
    end
    it 'analyste? retourne true' do
      expect(u).to be_analyste
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
  end

  context 'avec un simple correcteur du fichier' do
    before do
      allow_any_instance_of(Analyse::AFile::UFiler).to receive(:role).and_return(4)
      @u = @ua
    end
    it 'creator? est false' do
      expect(u).not_to be_creator
    end
    it 'redactor? est false' do
      expect(u).not_to be_redactor
    end
    it 'corrector? est true' do
      expect(u).to be_corrector
    end
    it 'simple_corrector? est true' do
      expect(u).to be_simple_corrector
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
    it 'identified? retourne true' do
      expect(u).to be_identified
    end
    it 'analyste? retourne true' do
      expect(u).to be_analyste
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
  end

end
