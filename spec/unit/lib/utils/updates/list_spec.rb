require_lib_site
require_support_db_for_test

require './__SITE__/home/_lib/_required/updates.rb'

def create_update hdata = nil
  hdata ||= Hash.new
  hdata[:created_at]  ||= NOW
  hdata[:route]       ||= nil
  hdata[:type]        = (hdata[:type] || 'site').to_s
  t = Time.new(hdata[:created_at])
  hdata[:message]     ||= "Message d'une actualité à #{t.strftime('%d %m %Y - %H:%M')}"
  hdata[:options]     ||= '100000000' # Affiché par défaut
  newid = site.db.insert(:cold,'updates',hdata)
  hdata[:id] ||= newid
  hdata
end

describe Updates do
  def create_updates data_updates
    @nombre = {
      updates:                0, # nombre total d'updates
      updates_in_site:        0,
      updates_in_narration:   0,
      updates_in_forum:       0,
      updates_in_unan:        0
    }

    @data_updates.each do |uid, hupdate|
      @nombre[:updates] += 1
      create_update(hupdate)
      @nombre["updates_in_#{hupdate[:type]}".to_sym] += 1
    end
  end

  before(:all) do
    truncate_table_updates
    @data_updates = {
      1 => {id: 1, created_at: NOW, type: 'narration', options: '100000'},
      2 => {id: 2, message:"Aussi envoyé par mail", type: 'site', created_at: NOW-2.jours, options: '110000'},
      5 => {id: 5, message:"Pour les abonnés", type: 'narration', created_at: NOW-2.jours, options: '200000'},
      6 => {id: 6, message:"Pour les simples inscrits", type: 'site', created_at: NOW-4.jours, options: '300000'},
      7 => {id: 7, message:"Pour UN AN UN SCRIPT", type: 'site', created_at: NOW-4.jours, options: '400000'},
      3 => {id: 3, message: "Déjà envoyé par mail", type: 'narration', created_at: NOW-3.jours, options: '110000'},
      4 => {id: 4, created_at: NOW-2.semaines, type: 'unan', options: '100000'},
      8 => {id: 8, message: "À ne pas afficher", type: 'unan', created_at: NOW-2.semaines, options: '000000'},
      9 => {id: 9, message: "Autre non affichée", type: 'narration', created_at: NOW-4.semaines, options: '000000'},
      12 => {id: 12, message:"Trop vieille", type: 'site', created_at: NOW - 1.an - 1.jours, options: '110000'},
      13 => {id: 13, message:"Trop vieille avec route", type: 'forum', route:'unanunscript/home', created_at: NOW - 1.an - 2.semaines, options: '110000'}
    }

    create_updates @data_updates

    # ===========> TEST <============
    @liste = Updates.list

  end

  describe '#list' do
    # Liste des identifiants
    let(:liste_ids) { @liste_ids ||= begin
      @liste.collect{ |update| update.get(:id) }
    end}

    it 'répond' do
      expect(Updates).to respond_to :list
    end

    context 'sans argument' do
      before(:all) do
        @liste = Updates.list()
      end
      it 'retourne une liste d’instances Updates' do
        res = Updates.list
        expect(res).to be_a(Array)
        expect(res.first).to be_a(Updates)
        expect(res.count).to eq @nombre[:updates]
      end
    end

    context 'avec le paramètre :all et l’option group: :type' do
      it 'retourne une liste d’actualités regroupés par types' do
        # Sous la forme
        # {
        #   site: {type: :site, updates: [liste des updates]},
        #   unan: {type: :unan, updates: [liste des updates]}
        # }
        res = Updates.list( { group_by_type: true } )
        expect(res).to be_a(Hash)
        expect(res).to have_key('site')
        expect(res).to have_key('unan')
        expect(res).to have_key('narration')
        expect(res['site']).to have_key(:updates)
        expect(res['site'][:updates].count).to eq @nombre[:updates_in_site]
        expect(res['narration'][:updates].count).to eq @nombre[:updates_in_narration]
        expect(res['unan'][:updates].count).to eq @nombre[:updates_in_unan]
      end
    end

    context 'avec le filtre à :home (actualités pour l’accueil)' do
      before(:all) do
        @liste = Updates.last_updates # = `list` avec params
      end
      it 'prend en compte les dernières actualités' do
        expect(liste_ids).to eq [1,2,3,4,5,6,7]
      end
      it 'ne prend pas en compte les updates à options commençant par 0' do
        expect(liste_ids).not_to include 8
      end
      it 'ne prend pas en compte les actualités de plus d’un an' do
        expect(liste_ids).not_to include 12
      end
    end
    context 'avec le filtre à :mail (message à envoyer par mail)' do
      before(:all) do
        @liste = Updates.list(not_sent: true)
      end
      it 'retourne seulement les updates récents non envoyées' do
        expect(liste_ids).to eq [1,4,5,6,7]
      end
      it 'ne retourne pas les updates déjà envoyés' do
        expect(liste_ids).not_to include 2
        expect(liste_ids).not_to include 3
      end
      it 'ne retourne pas les updates trops vieux' do
        expect(liste_ids).not_to include 12
        expect(liste_ids).not_to include 13
      end
    end
  end
end
