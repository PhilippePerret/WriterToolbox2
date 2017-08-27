require_lib_site

require './lib/utils/updates.rb'

describe Updates do

  describe '#base_n_table' do
    it 'répond' do
      expect(Updates).to respond_to :base_n_table
    end
    it 'retourne [:cold, "updates"]' do
      expect(Updates.base_n_table).to eq [:cold, 'updates']
    end
  end
  describe '#set' do
    it 'répond' do
      expect(Updates).to respond_to :set
    end
  end
  describe '#get' do
    it 'répond' do
      expect(Updates).to respond_to :get
    end
  end
  describe '#data_valides?' do
    let(:data) { @data }
    it 'répond' do
      expect(Updates).to respond_to :data_valides?
    end
    context 'avec des données valides' do
      before :all do
       @data = {
        message: "Un message correct",
        type:     :unan,
        route:    'unan/home',
        annonce:  2
       }
      end
      it 'retourne true' do
         expect(Updates.data_valides?(data)).to be true
      end
      it 'retourne true même sans route' do
        data.delete(:route)
        expect(Updates.data_valides?(data)).to be true
      end
    end

    context 'avec des données invalides' do
      before :all do
        @data = {
          message: "Un message pour les actualités",
          type:    :unan,
          route:   'unan/home',
          annonce: 1
        }
      end
      it 'retourne false si les données sont nil' do
        expect(Updates.data_valides?(nil)).to be false
      end
      it 'retourne false si le message n’est pas fourni ou est vide' do
        data.delete(:message)
        expect(Updates.data_valides?(data)).to be false
        expect(Updates.data_valides?(data.merge(message: ''))).to be false
      end
      it 'retourne false si le type n’est pas fourni ou est inconnu' do
        data.delete(:type)
        expect(Updates.data_valides?(data)).to be false
        expect(Updates.data_valides?(data.merge!(type:'badtypeupdate'))).to be false
      end
      it 'retourne false si la propriété d’annonce n’est pas fournie ou est invalide' do
        data.delete(:annonce)
        expect(Updates.data_valides?(data)).to be false
        expect(Updates.data_valides?(data.merge(annonce: 5))).to be false
        expect(Updates.data_valides?(data.merge(annonce: 'oui'))).to be false
      end
    end
  end
  describe '#add' do
    it 'répond' do
      expect(Updates).to respond_to :add
    end
    it 'permet d’ajouter une actualité' do
      start_time = Time.now.to_i - 1
      mess = "Marion est coquine le #{Time.now.strftime('%d %m %Y %H:%M')}"
      # =======> TEST <============
      Updates.add({
        message: mess,
        type:    :site,
        annonce: 0
      })
      # ========= VÉRIFICATION ===========
      res = site.db.select(:cold, 'updates', "created_at > #{start_time}").first
      expect(res).not_to be nil
      expect(res[:message]).to eq mess
    end
  end

end

describe 'Instance de Updates' do

  let(:update) { @update ||= Updates.new }

  describe '#set' do
    it 'repond' do
      expect(update).to respond_to :set
    end
  end
  describe '#get' do
    it 'répond' do
      expect(update).to respond_to :get
    end
  end
  describe '#base_n_table' do
    it 'répond' do
      expect(update).to respond_to :base_n_table
    end
    it 'retourne la valeur [:cold, "updates"]' do
      expect(update.base_n_table).to eq [:cold, "updates"]
    end
  end
end
