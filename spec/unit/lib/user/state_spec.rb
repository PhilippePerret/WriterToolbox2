require_lib_site
require_support_db_for_test

describe 'Statut de l’user' do
  def add_paiement u, dpaiement
    dpaiement[:objet_id] ||= 'ABONNEMENT'
    dpaiement.merge!(user_id: u.id)
    dpaiement[:montant]  ||= (dpaiement[:objet_id] == '1AN1SCRIPT' ? 19.8 : 6.90)
    dpaiement[:facture]  ||= "ABVDGFH#{Time.now.to_i.to_s(36)}"[0..31]
    site.db.insert(:cold,'paiements',dpaiement)
    @nuser.instance_variable_set('@is_suscribed', nil)
    @nuser.instance_variable_set('@is_unanunscript', nil)
  end
  before(:all) do
    truncate_table_paiements
    @dataU = create_new_user
    @nuser = User.get( @dataU[:id] )
  end
  before(:each) do
    @nuser.instance_variable_set('@is_suscribed', nil)
    @nuser.instance_variable_set('@is_unanunscript', nil)
  end
  let(:nuser) { @nuser }
  describe 'méthodes utiles' do
    it '#suscriber? répond' do
      expect(nuser).to respond_to :suscriber?
    end
    it '#suscribed? répond' do
      expect(nuser).to respond_to :suscribed?
    end
    it '#unanunscript? répond' do
      expect(nuser).to respond_to :unanunscript?
    end
    it '#analyste? répond' do
      expect(nuser).to respond_to :analyste?
    end
    it '#icarien? répond' do
      expect(nuser).to respond_to :icarien?
    end
  end

  context 's’il est abonné au site' do
    before(:all) do
      add_paiement(@nuser, {objet_id:'ABONNEMENT', created_at: NOW - 263.jours})
    end
    it 'suscriber? répond true' do
      expect(nuser).to be_suscriber
    end
    it 'suscribed? répond true' do
      expect(nuser).to be_suscribed
    end
  end

  context 's’il était abonné au site mais ne l’est plus depuis 2 jours' do
    before(:all) do
      truncate_table_paiements
      add_paiement(@nuser, {objet_id: 'ABONNEMENT', created_at: NOW - 368.jours})
    end
    it 'suscribed? répond false' do
      wclause = "user_id = #{nuser.id} AND objet_id = 'ABONNEMENT' AND created_at > #{NOW - 1.annee}"
      expect(nuser).not_to be_suscribed
      expect(nuser).not_to be_suscriber
    end
  end
  context 's’il est inscrit au programme UN AN UN SCRIPT depuis moins d’un an' do
    before(:all) do
      truncate_table_paiements
      add_paiement(@nuser, {objet_id: '1AN1SCRIPT', created_at: NOW - 12.jours})
    end
    it '#unanunscript? retourne true' do
      expect(nuser).to be_unanunscript
    end
    it '#suscribed? retourne true' do
      expect(nuser).to be_suscribed
      expect(nuser).to be_suscriber
    end
  end

  context 's’il est inscrit au programme depuis plus d’un an' do
    before(:all) do
      truncate_table_paiements
      add_paiement(@nuser, {objet_id: '1AN1SCRIPT', created_at: NOW - 380.jours})
    end
    it '#unanunscript? répond true' do
      expect(nuser).to be_unanunscript
    end
    it '#suscribed? répond true' do
      expect(nuser).to be_suscribed
      expect(nuser).to be_suscriber
    end
  end

  context 's’il n’est pas inscrit au programme UN AN UN SCRIPT' do
    before(:all) do
      truncate_table_paiements
    end
    it '#unanunscript? répond false' do
      expect(nuser).not_to be_unanunscript
    end
    context 's’il n’est pas abonné' do
      it '#suscribed? répond false' do
        expect(nuser).not_to be_suscribed
      end
      it '#suscriber? répond false' do
        expect(nuser).not_to be_suscriber
      end
    end
  end

  context 's’il participe aux analyses (17e bit/16)' do
    before(:all) do
      @nuser.instance_variable_set('@is_analyste', nil)
      @nuser.set(options: @nuser.get(:options).set_bit(16,1))
    end
    it '#analyste? répond true' do
      expect(nuser).to be_analyste
    end
  end
  context 's’il ne participe pas aux analyses' do
    before(:all) do
      @nuser.instance_variable_set('@is_analyste', nil)
      @nuser.set(options: @nuser.get(:options).set_bit(16,0))
    end
    it '#analyste? répond false' do
      expect(nuser).not_to be_analyste
    end
  end

  context 's’il est icarien (32e bit/31)' do
    before(:all) do
      @nuser.instance_variable_set('@is_icarien', nil)
      @nuser.set(options: @nuser.get(:options).set_bit(31,1))
    end
    it '#icarien? répond true' do
      expect(nuser).to be_icarien
    end
  end
  context 's’il n’est pas icarien' do
    before(:all) do
      @nuser.instance_variable_set('@is_icarien', nil)
      @nuser.set(options: @nuser.get(:options).set_bit(31,0))
    end
    it '#icarien? répond false' do
      expect(nuser).not_to be_icarien
    end
  end
end
