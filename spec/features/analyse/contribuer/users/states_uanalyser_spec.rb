=begin

  Test des méthodes `creator?`, `corrector?` etc. utilisées pour les
  `Analyse::UAnalyser` et `Analyse::AFile::UFiler`

=end
require_lib_site

describe 'States d’un user quelconque' do
  before(:all) do
    require_folder './__SITE__/analyser/_lib/_required'
    @huser = get_data_random_user(mail_confirmed: true, admin: false)

    # On choisit une analyse faite
    hanalyse = site.db.select(
      :biblio, 'films_analyses',
      "SUBSTRING(specs,1,1) = '1' LIMIT 10"
    ).shuffle.shuffle.first
    @analyse = Analyse.new(hanalyse[:id])

    @tuser = User.get(@huser[:id])

  end
  before(:each) do
    @u    = Analyse::UAnalyser.new(@analyse, @tuser)
  end

  let(:u) { @u }

  context 'avec un user non identifié', check: false do
    before(:each) do
      @tuser  = User.new(nil)
      @u      = Analyse::UAnalyser.new(@analyse, @tuser)
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
    it 'contributor? return false' do
      expect(u).not_to be_contributor
    end
  end


  context 'avec un simple inscrit', check: false do
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
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
  end

  context 'avec un administrateur sans lien avec l’analyse', check: false do
    before(:each) do
      @tuser.instance_variable_set('@is_admin', true)
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
    it 'admin? retourne true' do
      expect(u).to be_admin
    end
  end


  context 'avec le créateur actif de l’analyse (non administrateur)' do
    before(:all) do
      @tuser.instance_variable_set('@is_admin', false)
    end
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(1|32)
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
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? retourne true' do
      expect(u).to be_actif
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
  end
  context 'avec un créateur INACTIF (non administrateur)' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(32)
    end
    it 'creator? est true' do
      expect(u).to be_creator
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? est false' do
      expect(u).not_to be_actif
    end
  end

  context 'avec un rédacteur non administrateur actif de l’analyse' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(1|16)
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
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? retourne true' do
      expect(u).to be_actif
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
  end

  context 'avec un rédacteur non administrateur de l’analyse INACTIF' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(16)
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? retourne false' do
      expect(u).not_to be_actif
    end
  end

  context 'avec un correcteur (non administrateur) actif de l’analyse' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(1|4|8)
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne true (occasionnellement)' do
      expect(u).to be_redactor
    end
    it 'corrector? retourne true' do
      expect(u).to be_corrector
    end
    it 'simple_corrector? retourne false' do
      expect(u).not_to be_simple_corrector
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? retourne true' do
      expect(u).to be_actif
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
  end

  context 'avec un correcteur non actif' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(4|8)
    end
    it 'corrector? est true' do
      expect(u).to be_corrector
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? est false' do
      expect(u).not_to be_actif
    end
  end


  context 'avec un simple correcteur actif de l’analyse (non administrateur)' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(1|4)
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne false' do
      expect(u).not_to be_redactor
    end
    it 'corrector? retourne true' do
      expect(u).to be_corrector
    end
    it 'simple_corrector? retourne true' do
      expect(u).to be_simple_corrector
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? retourne true' do
      expect(u).to be_actif
    end
    it 'admin? retourne false' do
      expect(u).not_to be_admin
    end
  end

  context 'avec un simple correcteur inactif' do
    before do
      allow_any_instance_of(Analyse::UAnalyser).to receive(:role).and_return(4)
    end
    it 'creator? retourne false' do
      expect(u).not_to be_creator
    end
    it 'redactor? retourne false' do
      expect(u).not_to be_redactor
    end
    it 'corrector? est true' do
      expect(u).to be_corrector
    end
    it 'simple_corrector? est true' do
      expect(u).to be_simple_corrector
    end
    it 'contributor? return true' do
      expect(u).to be_contributor
    end
    it 'actif? est false' do
      expect(u).not_to be_actif
    end
  end

end
