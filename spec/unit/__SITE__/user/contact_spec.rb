require_lib_site

describe 'Contact User' do

  def set_type_contact someone, valeur
    opts = someone.data[:options]
    opts[4] = valeur.to_s
    someone.data[:options] = opts
    reset_contact someone
  end
  def reset_contact someone
    someone.instance_variable_set('@tcontact', nil)
    ['ww','wi','wa','wn'].each do |pref|
      someone.instance_variable_set("@#{pref}_contact", nil)
    end
  end

  before(:all) do
    require_lib('user:contact')
    @u = User.get(2)
  end

  let(:u) { @u }

  context 'avec un user qui ne veut pas de contact' do

    before(:all) do
      set_type_contact @u, 0
    end

    it 'son tcontact est à 0' do
      expect(u.tcontact).to eq 0
    end
    it 'son world_contact? retourne false' do
      expect(u).not_to be_world_contact
    end
    it 'son inscrits_contact? retourne false' do
      expect(u).not_to be_inscrits_contact
    end
    it 'son admin_contact? retourne false' do
      expect(u).not_to be_admin_contact
    end
    it 'son aucun_contact? retourne true' do
      expect(u).to be_aucun_contact
    end

  end

  context 'avec un user qui ne veut des contacts qu’avec l’administration' do
    before(:all) do
      set_type_contact @u, 2
    end
    it 'son tcontact est à 2' do
      expect(u.tcontact).to eq 2
    end
    it 'son world_contact? retourne false' do
      expect(u).not_to be_world_contact
    end
    it 'son inscrits_contact? retourne false' do
      expect(u).not_to be_inscrits_contact
    end
    it 'son admin_contact? retourne true' do
      expect(u).to be_admin_contact
    end
    it 'son aucun_contact? retourne false' do
      expect(u).not_to be_aucun_contact
    end
  end

  context 'avec un user qui ne veut des contacts qu’avec les inscrits' do
    before(:all) do
      set_type_contact @u, 4
    end
    it 'son tcontact est à 4' do
      expect(u.tcontact).to eq 4
    end
    it 'son world_contact? retourne false' do
      expect(u).not_to be_world_contact
    end
    it 'son inscrits_contact? retourne true' do
      expect(u).to be_inscrits_contact
    end
    it 'son admin_contact? retourne false' do
      expect(u).not_to be_admin_contact
    end
    it 'son aucun_contact? retourne false' do
      expect(u).not_to be_aucun_contact
    end
  end

  context 'avec un user qui veut des contacts avec tout le monde' do
    before(:all) do
      set_type_contact @u, 8
    end
    it 'son tcontact est à 8' do
      expect(u.tcontact).to eq 8
    end
    it 'son world_contact? retourne true' do
      expect(u).to be_world_contact
    end
    it 'son inscrits_contact? retourne false' do
      expect(u).not_to be_inscrits_contact
    end
    it 'son admin_contact? retourne false' do
      expect(u).not_to be_admin_contact
    end
    it 'son aucun_contact? retourne false' do
      expect(u).not_to be_aucun_contact
    end
  end

  context 'avec un user dont les options ne définissent pas le contact (seulement 3 bits)' do
    before(:all) do
      @u.data[:options] = @u.data[:options][0..2]
      reset_contact @u
    end
    it 'ses options n’ont que 3 bits' do
      expect(@u.data[:options].length).to eq 3
    end
    it 'son tcontact est à 6' do
      expect(u.tcontact).to eq 6
    end
    it 'son world_contact? retourne false' do
      expect(u).not_to be_world_contact
    end
    it 'son inscrits_contact? retourne true' do
      expect(u).to be_inscrits_contact
    end
    it 'son admin_contact? retourne true' do
      expect(u).to be_admin_contact
    end
    it 'son aucun_contact? retourne false' do
      expect(u).not_to be_aucun_contact
    end
  end
end
