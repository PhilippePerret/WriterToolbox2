require_lib_site

require './lib/utils/paiement'

describe Paiement do
  before :all do
    @data = {
      auteur: {
        prenom: "Benoit", nom: "Ackerman",
        mail: "benoit.ackerman@yahoo.fr"
      },
      objet:    "UNTEST",
      user_id:  0,
      id:       "aufdiodqfdf7D7FIID5D",
      cart:     "DGHFJ65D7DJS",
      state:    "approved",
      status:   "VERIFIED",
      montant: {
        id:       "DGFHD67DSJD6D5D4D",
        spec:     10.0,
        total:    10.0,
        monnaie:  'EUR'
      }
    }
  end

  let(:pmt) { Paiement.new(@data) }

  describe '#facture_id' do
    it 'répond' do
      expect(pmt).to respond_to :facture_id
    end
    it 'retourne l’ID de facture du paiement' do
      expect(pmt.facture_id).to eq @data[:id]
    end
    it 'retourne les 32 premiers caractères si l’ID est trop long' do
      @data[:id] = 'AD'*100
      expect(pmt.facture_id).to eq 'AD'*16
    end
  end

  describe '#auteur' do
    it 'répond' do
      expect(pmt).to respond_to :auteur
    end
    it 'retourne l’auteur du paiement comme Hash' do
      expect(pmt.auteur).to be_a(Hash)
      expect(pmt.auteur).to have_key :prenom
      expect(pmt.auteur).to have_key :nom
      expect(pmt.auteur).to have_key :mail
    end
  end

  describe '#patronyme' do
    it 'répond' do
      expect(pmt).to respond_to :auteur_patronyme
    end
    it 'retourne le patronyme de l’auteur du paiement' do
      @data[:auteur] = {prenom: "Philippe", nom:"Perret"}
      expect(Paiement.new(@data).auteur_patronyme).to eq "Philippe Perret"
      @data[:auteur] = {prenom: "Marion", nom: "Michel"}
      expect(Paiement.new(@data).auteur_patronyme).to eq "Marion Michel"
      @data[:auteur] = {prenom: "Phil", nom: ""}
      expect(Paiement.new(@data).auteur_patronyme).to eq "Phil"
    end
  end
  describe '#save' do
    before(:all) do
      User.current = marion
      @data[:montant][:spec] = @data[:montant][:total] = 15.0
      @data[:user_id] = 3
    end
    it 'répond' do
      expect(pmt).to respond_to :save
    end
    it 'enregistre le paiement dans la table' do
      # ======== PRÉPARATION ==========
      start_time = Time.now.to_i - 1
      #=======> TEST <=========
      pmt.save
      #========= VÉRIFICATION ===========
      res = site.db.select(:cold, 'paiements', "created_at > #{start_time}")
      res = res.first
      expect(res).not_to be_nil
      expect(res[:user_id]).to eq 3
      expect(res[:montant]).to eq 15.0
    end
  end

  describe 'Facture' do
    it 'répond' do
      expect(pmt).to respond_to :facture
    end
    it 'retourne une facture conforme au format HTML' do
      data = @data.merge({
        auteur: {prenom: "Benoit", nom: "Ackerman", mail: "benoit.ackerman@yahoo.fr"},
        montant: {total: 115.0},
        id: 'ZT'*25
      })

      User.current = marion
      now = Time.now
      f = Paiement.new(data).facture
      expect(f).to have_tag('table#facture')
      expect(f).to have_tag('td', text: data[:id][0..31])
      expect(f).to have_tag('td', text: "La Boite à outils de l’auteur")
      expect(f).to have_tag('td', text: /Benoit Ackerman \(Marion #3\)/)
      expect(f).to have_tag('td', text: /benoit\.ackerman@yahoo\.fr/)
      expect(f).to have_tag('td', text: "UNTEST")
      expect(f).to have_tag('td', text: "115.0 €")
      expect(f).to have_tag('td', text: now.strftime('%d %m %Y - %H:%M'))
    end
  end
end
