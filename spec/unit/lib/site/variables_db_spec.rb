=begin

  Pour tester les méthodes permettant d'enregistrer des variables sites

  Rappel : les variables site sont enregistrées dans la table `variables_0`,
  celle de l'user #1 (moi)

=end
require_lib_site
require_support_db_for_test

describe Site do

  # Récupère et renvoie la donnée de name +vname+ dans la table des
  # variables site (:users_tables.variables_0)
  def gvar vname
    site.db.select(:users_tables,'variables_0', {name: vname}).first
  end

  describe '#set_var' do
    before(:all) do
      truncate_table_variables(0)
    end
    it 'répond' do
      expect(site).to respond_to :set_var
    end
    it 'permet d’enregistrer une variable dans la table variables_0' do
      site.set_var('spotlight_objet', 'collection Narration')
      # ======== VÉRIFICATIONS =======
      res = site.db.select(:users_tables,'variables_0', {'name': 'spotlight_objet'})
      res = res.first
      expect(res[:name]).to eq 'spotlight_objet'
      expect(res[:value]).to eq 'collection Narration'
      expect(res[:type]).to eq 0 # String
    end
    it 'permet d’enregistrer une string et un nombre entier ou flottant' do
      # =========> TEST <===========
      site.set_var('unstring', "Mon texte")
      site.set_var('unfixnume', 12)
      site.set_var('unflottant', 12.12)
      # ============ VÉRIFICATION ===========
      res = gvar('unstring')
      expect(res[:type]).to eq 0
      expect(res[:value]).to eq 'Mon texte'
      res = gvar('unfixnume')
      expect(res[:type]).to eq 1
      expect(res[:value]).to eq '12'
      res = gvar('unflottant')
      expect(res[:type]).to eq 3
      expect(res[:value]).to eq '12.12'
    end
    it 'permet d’enregistrer true, false et nil dans la table' do
      site.set_var('unclasstrue', true)
      site.set_var('unclassfalse', false)
      site.set_var('unclassnil', nil)
      # =========> VÉRIFICATIONS <==============
      expect(gvar('unclasstrue')[:value]).to  eq 'true'
      expect(gvar('unclassfalse')[:value]).to eq 'false'
      expect(gvar('unclassnil')[:value]).to   eq 'nil'
    end

    it 'permet d’enregistrer une liste ou un hash' do
      # ==========> TESTS <==========
      site.set_var('unelistearray', [1,3,5,7])
      site.set_var('unhashtableau', {un: "1", deux: 2})
      # =======> VÉRIFICATIONS =========
      res = gvar('unelistearray')
      expect(res[:value]).to eq '[1,3,5,7]'
      res = gvar('unhashtableau')
      expect(res[:value]).to eq '{"un":"1","deux":2}'
    end
  end


  describe '#get_var' do
    before(:all) do
      truncate_table_variables(0)
    end
    it 'répond' do
      expect(site).to respond_to :get_var
    end
    it 'retourne la variable voulue dans son bon type' do
      # ======= PRÉPARATION =========
      site.set_var('unstring', 'le string pour voir')
      site.set_var('unfixnum', 12)
      site.set_var('uneboolfalse', false)
      site.set_var('uneliste', [2,4,6,8])
      # ==========> TEST <============
      expect(site.get_var('unstring')).to eq 'le string pour voir'
      expect(site.get_var('unfixnum')).to eq 12
      expect(site.get_var('uneboolfalse')).to eq false
      expect(site.get_var('uneliste')).to eq [2,4,6,8]
    end
    it 'retourne nil si la variable n’existe pas' do
      truncate_table_variables(0)
      expect(site.get_var('unstring')).to eq nil
    end
  end
end
