=begin

  On va se servir de la classe Ticket et tester entre des valeurs chargées
  et des valeurs non chargées grâce à la classes singée ici :

=end

require_lib_site

require_support_db_for_test


class Ticket
  include PropsAndDbMethods

  attr_accessor :id, :user_id, :code, :created_at, :updated_at

  def initialize id
    @id = id
  end

  def base_n_table
    @base_n_table ||= [:hot, 'tickets']
  end

end

describe PropsAndDbMethods do

  def create_ticket hdata
    truncate_table_tickets
    site.db.insert(:hot, 'tickets', hdata)
  end

  #     #set
  describe '#set' do

    let(:ticket) { @ticket ||= Ticket.new(@tid) }

    it 'répond' do
      expect(ticket).to respond_to :set
    end

    it 'enregistre une valeur dans la BDD et la redéfinit dans l’instance' do
      @tid = 'ffff'
      create_ticket({id:@tid, code:'MonCode6', user_id: 6})
      # ======= VÉRIFICATIONS PRÉLIMINAIRES ========
      ticket.get([:user_id, :code])
      expect(ticket.user_id).to eq 6
      expect(ticket.code).to eq 'MonCode6'
      # ==========> TEST <===========
      ticket.set({user_id: 10})
      # ========= VÉRIFICATIONS =========
      res = site.db.select(:hot, 'tickets', {id: @tid}).first
      expect(res[:user_id]).not_to eq 6
      expect(res[:user_id]).to eq 10
      expect(ticket.user_id).to eq 10
    end

  end

  #     #get
  describe '#get' do

    let(:ticket) { @ticket ||= Ticket.new(@tid) }

    context 'avec une clé comme argument et la valeur non définie' do
      before(:all) do
        @tid = 'aaaa'
        create_ticket({id: @tid, code:'MonCode1', user_id:1})
      end


      it 'retourne la valeur en la prenant dans la base de données et la met dans la donnée' do
        expect(ticket.code).to eq nil
        # =========> TEST <===============
        res = ticket.get(:code)
        expect(res).to eq 'MonCode1'
        expect(ticket.code).to eq 'MonCode1'
      end
    end

    context 'avec une clé comme argument et la valeur déjà chargée' do
      before(:all) do
        @tid = 'bbbb'
        create_ticket({id: @tid, code: 'MonCode2', user_id: 2})
      end
      it 'retourne la valeur déjà chargé' do
        ticket.instance_variable_set('@code', "C'est un autre code")
        expect(ticket.get(:code)).not_to eq 'MonCode2'
        expect(ticket.get(:code)).to eq "C'est un autre code"
      end
    end

    context 'avec une liste de clés et les valeurs non définie' do
      before(:all) do
        @tid = 'cccc'
        @now = Time.now.to_i
        create_ticket({id: @tid, code: 'MonCode3', user_id: 3, updated_at: @now})
      end
      it 'retourne un Hash avec les valeurs prises dans la base de données' do
        expect(ticket.code).to eq nil
        expect(ticket.user_id).to eq nil
        expect(ticket.updated_at).to eq nil
        # ===========> TEST <================
        res = ticket.get([:code, :user_id, :updated_at])
        expect(res[:code]).to eq 'MonCode3'
        expect(ticket.code).to eq 'MonCode3'
        expect(res[:user_id]).to eq 3
        expect(ticket.user_id).to eq 3
        expect(res[:updated_at]).to eq @now
        expect(ticket.updated_at).to eq @now
      end
    end

    context 'avec une liste de clés et des valeurs déjà définies' do
      before(:all) do
        @tid = 'dddd'
        create_ticket({id: @tid, code: 'MonCode4', user_id:4})
      end
      it 'retourne un Hash avec les valeurs chargées' do
        {
          id:   'azazazaz',
          code: 'Un autre code défini en 4',
          user_id: 8,
          updated_at: 1234567825
        }.each do |k, v|
          ticket.instance_variable_set("@#{k}", v)
        end
        # ==========> TEST <============
        res = ticket.get([:id, :code, :user_id, :updated_at])

        # ======= VÉRIFICATIONS =========
        expect(res[:code]).not_to eq 'MonCode4'
        expect(ticket.code).not_to eq 'MonCode4'
        expect(res[:id]).to eq 'azazazaz'
        expect(ticket.id).to eq 'azazazaz'
        expect(res[:code]).to eq 'Un autre code défini en 4'
        expect(ticket.code).to eq 'Un autre code défini en 4'
        expect(res[:user_id]).to eq 8
        expect(ticket.user_id).to eq 8
        expect(res[:updated_at]).to eq 1234567825
        expect(ticket.updated_at).to eq 1234567825
      end
    end

    context 'avec une liste de clés et des valeurs non définie et d’autres définies' do
      before(:all) do
        @tid = 'eeee'
        create_ticket({id: @tid, code: 'MonCode5', user_id:5})
      end
      it 'charge les valeurs non définies et les retournes avec les valeurs déjà chargées' do
        {
          code: 'Un autre code défini en 5',
          updated_at: 1234567826
        }.each do |k, v|
          ticket.instance_variable_set("@#{k}", v)
        end
        # ==========> TEST <============
        res = ticket.get([:id, :code, :user_id, :updated_at])

        # ======= VÉRIFICATIONS =========
        expect(res[:id]).to eq 'eeee'
        expect(ticket.id).to eq 'eeee'
        expect(res[:code]).to eq 'Un autre code défini en 5'
        expect(ticket.code).to eq 'Un autre code défini en 5'
        expect(res[:user_id]).to eq 5
        expect(ticket.user_id).to eq 5
        expect(res[:updated_at]).to eq 1234567826
        expect(ticket.updated_at).to eq 1234567826
      end
    end
  end
end
