require_lib_site

describe 'Propriété var (class Vars)' do

  describe 'User#vars' do
    it 'existe' do
      expect(user).to respond_to :var
    end
    it 'retourne une instance Vars' do
      expect(user.var).to be_a User::Vars
    end
  end

  describe 'User#var[]' do
    it 'permet de récupérer une valeur' do
      @varname = "var_test_#{Time.now.to_i}"
      hdata = {
        name:   @varname,
        value:  12,
        type:   1,
        __strict: true
      }
      site.db.insert(:users_tables, 'variables_1', hdata)

      # ======> TEST <=========
      expect(phil.var[@varname]).to eq 12
    end
  end

  describe 'user#var[name] = valeur' do
    it 'permet de définir une nouvelle valeur' do
      varname = "var_at_#{Time.now.to_i}"
      phil.var[varname] = "C'est la valeur string"
      expect(phil.var[varname]).to eq "C'est la valeur string"
    end

    it 'permet de définir une valeur string' do
      [
        ['Un string', String],
        [12, Fixnum],
        [12.8, Float],
        [true, TrueClass],
        [false, FalseClass],
        [nil, NilClass],
        [[1,2,3,4], Array],
        [{un:"hash", avec:"valeurs"}, Hash]
      ].each do |val, type|
        phil.var['test'] = val
        expect(phil.var['test']).to be_a type
        expect(phil.var['test']).to eq val
      end
    end
  end

  describe 'Marion' do
    it 'peut déposer des variables' do
      marion.var['test_de_marion'] = 20170911
      expect(marion.var['test_de_marion']).to eq 20170911
    end
  end

  describe 'la table users_tables.variables_<id>' do
    context 'si elle n’existe pas' do
      it 'est créée pour l’utilisateur (son owner)' do
        require_support_db_for_test
        udata = create_new_user
        u = User.get(udata[:id])
        valeur = "Il est #{Time.now}"
        u.var['var_new_user'] = valeur
        expect(u.var['var_new_user']).to eq valeur
      end
    end
  end

end
