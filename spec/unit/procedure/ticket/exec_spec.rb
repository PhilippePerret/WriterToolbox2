
require_support_db_for_test
require_lib_site
require_folder './lib/procedure/ticket'

class Ticket
  def self.pour_tester ca
    __notice(ca)
  end
end
describe Ticket do
  describe '::exec' do
    it 'répond' do
      expect(Ticket).to respond_to :exec
    end
    context 'sans argument' do
      it 'produit une erreur' do
        expect{Ticket.exec}.to raise_error(ArgumentError)
      end
    end
    context 'avec un argument invalide' do
      it 'produit une erreur' do
        [true, {un:'hash'}, 12].each do |badtckid|
          expect{Ticket.exec badtckid}.to raise_error(ArgumentError)
        end
      end
    end

    context 'avec un ID de ticket existant' do
      before(:all) do
        truncate_table_tickets
        dticket = {
          id: 'aaaaaaaaaa',
          code: '__notice("Ticket \'aaaaaaaaaa\' exécuté.".force_encoding("utf-8"))', user_id: 1
        }
        site.db.insert(:hot,'tickets',dticket)
      end
      it 'exécute le ticket' do
        expect(site.flash.messages.last).not_to eq "<div class=\"notice\">Ticket \'aaaaaaaaaa\' exécuté.</div>"
        Ticket.exec('aaaaaaaaaa')
        expect(site.flash.messages.last).to eq "<div class=\"notice\">Ticket \'aaaaaaaaaa\' exécuté.</div>"
      end
    end

    context 'avec un ID de ticket inexistant' do
      it 'produit une erreur non fatale' do
        tid = 'unmauvaisticketidpourvoir'
        Ticket.exec(tid)
        expect(site.flash.messages.last).to eq "<div class=\"error\">Le ticket '#{tid}' a déjà été exécuté, désolé.</div>"
      end
    end

    context 'avec une liste Array d’identifiant de ticket' do
      before(:all) do
        # On commence par supprimer tous les tickets
        truncate_table_tickets
        # On crée les trois tickets
        [
          {id: 'aaa', code: "Ticket.pour_tester('aaa')"},
          {id: 'bbb', code: "Ticket.pour_tester('bbb')"},
          {id: 'ccc', code: "Ticket.pour_tester('ccc')"}
        ].each do |dticket|
          site.db.insert(:hot, 'tickets', dticket)
        end
      end
      it 'crée les 3 tickets' do
        expect(site.db.count(:hot,'tickets',"id = 'aaa'")).to eq 1
        expect(site.db.count(:hot,'tickets',"id = 'bbb'")).to eq 1
        expect(site.db.count(:hot,'tickets',"id = 'ccc'")).to eq 1
      end
      it 'exécute tous les tickets' do
        # ======> TEST <===============
        liste = ['aaa', 'bbb', 'ccc']
        Ticket.exec(liste)
        expect(site.flash.messages[-3]).to eq '<div class="notice">aaa</div>'
        expect(site.flash.messages[-2]).to eq '<div class="notice">bbb</div>'
        expect(site.flash.messages[-1]).to eq '<div class="notice">ccc</div>'
      end
      it 'détruit les tickets après exécution' do
        expect(site.db.count(:hot,'tickets',"id = 'aaa'")).to eq 0
        expect(site.db.count(:hot,'tickets',"id = 'bbb'")).to eq 0
        expect(site.db.count(:hot,'tickets',"id = 'ccc'")).to eq 0
      end
    end
  end

  describe '#exec' do
    context 'avec un appel à une méthode propre' do
      before(:all) do
        truncate_table_tickets
        site.db.insert(:hot, 'tickets',{
          id: 'zzzzzzzz', code: 'User.get(1).confirm_mail', user_id: 1
          })
      end
      it 's’exécute sans problèmme' do
        if phil.options.get_bit(2) == 1
          phil.set(options: phil.options.set_bit(2,0))
        end

        expect(phil.options.get_bit(2)).to eq 0
        Ticket.exec('zzzzzzzz')
        expect(phil.options.get_bit(2)).to eq 1

      end
      it 'détruit le ticket' do
        expect(site.db.count(:hot, 'tickets', {id: 'zzzzzzzz'})).to eq 0
      end
    end
  end
end
