
require_lib_site
require_support_db_for_test

describe 'Site.db' do
  describe '#use_database/#user_db' do
    it 'répond' do
      expect(site.db).to respond_to :use_database
      expect(site.db).to respond_to :use_db
    end
  end

  describe '#execute' do
    it 'répond' do
      expect(site.db).to respond_to :execute
    end
    it 'permet d’exécuter une requête unique simple' do
      res = site.db.execute('SELECT LAST_INSERT_ID();')
      expect(res).not_to eq nil
      expect(res).to include( {:"LAST_INSERT_ID()" => 0} )
    end
    it 'permet d’exécuter plusieurs requêtes simples' do
      requests = []
      requests << 'SELECT LAST_INSERT_ID();'
      requests << 'use `boite-a-outils_hot`;'
      requests << 'SHOW TABLES;'
      res = site.db.execute(requests)
      expect(res.count).to eq 3
      expect(res[0]).to include( {:"LAST_INSERT_ID()" => 0} )
      expect(res[1]).to be_empty
      expect(res[2][0]).to have_key('Tables_in_boite-a-outils_hot'.to_sym)
    end
    it 'permet d’exécuter une requête préparée' do
      site.db.use_database(:hot)
      res = site.db.execute('SELECT * FROM users WHERE id = ?', [1])
      expect(res.first[:pseudo]).to eq 'Phil'
    end
    it 'permet d’exécuter plusieurs requêtes simples et préparées' do
      site.db.use_database(:hot)
      requests = []
      requests << 'SELECT LAST_INSERT_ID();'
      requests << ['SELECT * FROM users WHERE id = ?', [1]]
      requests << ['SELECT * FROM users WHERE id = ?', [3]]
      res = site.db.execute(requests)
      expect(res[0][0]).to have_key "LAST_INSERT_ID()".to_sym
      expect(res[1][0][:pseudo]).to eq 'Phil'
      expect(res[2][0][:pseudo]).to eq 'Marion'
    end
    it 'permet d’exécuter plusieurs fois une requête préparée' do
      truncate_table_users
      # Le principe est d'envoyer en second argument une liste de liste de valeurs
      site.db.use_database('hot')
      # ON va tenter de créer plusieurs utilisateurs
      request = "INSERT INTO tickets (id, user_id, code) VALUES (?,?,?)"
      values  = [
        ['f25d4sqf5f6fdqdf5fd', 12, 'return nil'],
        ['azeruipfdf55fdf5fdq', 15, 'return false'],
        ['af4d5s6q5df4dqf455f', 16, 'return true']
      ]

      # =======> TEST <=========
      site.db.execute(request, values)

      # ======= VÉRIFICATIONS ==========
      res = site.db.select(:hot, 'tickets', "user_id > 11 AND user_id < 17")
      expect(res.count).to eq 3
      u2id = {
        12 => 'f25d4sqf5f6fdqdf5fd',
        15 => 'azeruipfdf55fdf5fdq',
        16 => 'af4d5s6q5df4dqf455f'
      }
      res.each do |hdata|
        expect(hdata[:id]).to eq u2id[hdata[:user_id]]
      end
    end
  end

  describe '#count' do
    it 'répond' do
      expect(site.db).to respond_to :count
    end
    it 'retourne le nombre de rangées de la table spécifiée' do
      db_use(:hot)
      nb_rows = db_query("SELECT COUNT(*) FROM users;")
      nb_rows = nb_rows.first.values.first
      expect(site.db.count(:hot, 'users')).to eq nb_rows

      db_use(:cnarration)
      nb_rows = db_query("SELECT COUNT(*) FROM narration;")
      nb_rows = nb_rows.first.values.first
      expect(site.db.count(:cnarration, 'narration')).to eq nb_rows
    end
    it 'produit une erreur en cas de table inexistante' do
      expect{site.db.count(:hot, 'cenestpasunetable')}.to raise_error(Mysql2::Error)
    end
  end


  describe '#insert' do
    before(:all) do
      truncate_table_users
    end
    it 'répond' do
      expect(site.db).to respond_to :insert
    end
    it 'permet d’insérer une donnée' do
      nombre_init = site.db.count(:hot, 'tickets')
      site.db.insert(:hot, 'tickets', {id: "12f2ds1dff4f5dsqf", user_id: 12, code: "return true"})
      expect(site.db.count(:hot, 'tickets')).to eq nombre_init + 1
    end
    it 'ajoute toujours la date de création et d’update à la donnée' do
      start_time = Time.now.to_i
      sleep 2
      ticket_id = "a#{start_time}z"
      site.db.insert(:hot, 'tickets', {id: ticket_id, user_id: 1, code: "return false"})
      res = site.db.select(:hot, 'tickets', {id: ticket_id})
      expect(res).not_to be_empty
      res = res.first
      expect(res).to have_key(:created_at)
      expect(res[:created_at]).to be > start_time
      expect(res[:updated_at]).to be > start_time
    end
  end


  describe '#select' do
    it 'répond' do
      expect(site.db).to respond_to :select
    end
    it 'permet de récupérer une donnée particulière' do
      res = site.db.select(:hot, 'users', {id: 1})
      expect(res).not_to eq nil
      expect(res).to be_a(Array)
      res = res.first
      expect(res).to be_a(Hash)
      expect(res[:pseudo]).to eq 'Phil'
    end
    it 'permet de récupérer plusieurs données' do
      res = site.db.select(:hot, 'users')
      expect(res).not_to eq nil
      expect(res).to be_a(Array)
      expect(res).not_to be_empty
      expect(res.count).to be > 1
    end
    context 'sans clause where' do
      it 'retourne toutes les rangées' do
        db_use(:hot)
        nombre_rangees = db_query("SELECT COUNT(*) FROM users;")
        nombre_rangees = nombre_rangees.first.values.first
        res = site.db.select(:hot, 'users')
        expect(res.count).to eq nombre_rangees
        db_use(:cnarration)
        nb_rangees = db_query("SELECT COUNT(*) FROM narration;")
        nb_rangees = nb_rangees.first.values.first
        res = site.db.select(:cnarration, 'narration')
        expect(res.count).to eq nb_rangees
      end
    end
    context 'avec une clause where par string' do
      it 'retourne les rangées' do
        res = site.db.select(:cnarration, 'narration', 'ID = 12')
        expect(res.first[:id]).to eq 12
        res = site.db.select(:cnarration, 'narration', 'created_at > 1455812789')
        expect(res).to be_a(Array)
        expect(res.count).to be > 1
        res.each do |hdata|
          expect(hdata[:created_at]).to be > 1455812789
        end
      end
    end
    context 'avec une clause where par Hash' do
      it 'retourne les rangées voulues' do
        res = site.db.select(:cnarration, 'narration', {id: 12})
        expect(res.first[:id]).to eq 12
      end
    end

    context 'sans colonne précisée' do
      it 'retourne toutes les colonnes' do
        res = site.db.select(:hot, 'users', {id: 1})
        res = res.first
        [
          :id, :pseudo, :mail, :patronyme, :sexe,
          :options, :cpassword, :session_id,
          :created_at, :updated_at
        ].each do |col|
          expect(res).to have_key(col)
        end
      end
    end
    context 'avec des colonnes précisées par string' do
      it 'retourne les données trouvées' do
        res = site.db.select(:hot, 'users', {id: 1}, 'id, pseudo, mail')
        res = res.first
        [
          :id, :pseudo, :mail
        ].each do |col|
          expect(res).to have_key(col)
        end
        [
          :patronyme, :sexe,
          :options, :cpassword, :session_id,
          :created_at, :updated_at
        ].each do |col|
          expect(res).not_to have_key(col)
        end

      end
    end
    context 'avec une liste de colonnes par Array' do
      it 'retourne les données trouvées' do
        res = site.db.select(:hot, 'users', {id: 1}, [:id, :pseudo, :mail])
        res = res.first
        [
          :id, :pseudo, :mail
        ].each do |col|
          expect(res).to have_key(col)
        end
        [
          :patronyme, :sexe,
          :options, :cpassword, :session_id,
          :created_at, :updated_at
        ].each do |col|
          expect(res).not_to have_key(col)
        end
      end
    end
    context 'sans clause where et sans liste de colonnes' do
      it 'retourne toutes les colonnes de toutes les rangées' do
        db_use(:hot)
        nb_rows = db_query("SELECT COUNT(*) FROM users;")
        nb_rows = nb_rows.first.values.first
        res = site.db.select(:hot, 'users')
        expect(res.count).to eq nb_rows

        res.each do |hdata|
          [
            :id, :pseudo, :mail, :patronyme, :sexe,
            :options, :cpassword, :session_id,
            :created_at, :updated_at
          ].each do |col|
            expect(hdata).to have_key(col)
          end
        end

      end
    end
  end

  describe '#update' do
    before(:all) do
      truncate_table_users
      site.db.insert(:hot, 'users',
        {
          id: 100,
          pseudo: 'Pseudo100',
          patronyme: 'Patro100',
          mail: 'mail100@chez.lui',
          sexe: 'H',
          options: '0000000000',
          cpassword: 'dfd12f5d6d4dqsf', salt: '125fddsq45',
          created_at: Time.now.to_i,
          updated_at: Time.now.to_i
        })
    end
    it 'répond' do
      expect(site.db).to respond_to :update
    end
    it 'permet d’actualiser une donnée' do
      res = site.db.update(:hot, 'users', {pseudo: "Nouveau pseudo", mail:'new@mail.lui'}, {id: 100})
      newu = site.db.select(:hot, 'users', {id: 100}).first
      expect(newu[:pseudo]).to eq 'Nouveau pseudo'
      expect(newu[:mail]).to eq 'new@mail.lui'
    end
    it 'actualise toujours la donnée updated_at' do
      sleep 1
      starttime = Time.now.to_i
      sleep 1
      res = site.db.update(:hot, 'users', {pseudo: "Nouveau pseudo", mail:'new@mail.lui'}, {id: 100})
      newu = site.db.select(:hot, 'users', {id: 100}, 'updated_at').first
      expect(newu[:updated_at]).to be > starttime

    end
    context 'avec une where-clause définie par un string' do
      it 'actualise la donnée' do
        thispseudo = 'WhereParString'
        res = site.db.update(:hot, 'users', {pseudo: thispseudo, mail:"#{thispseudo}@mail.lui"}, "id = 100")
        newu = site.db.select(:hot, 'users', {id: 100}, 'pseudo, mail').first
        expect(newu[:pseudo]).to eq thispseudo
        expect(newu[:mail]).to eq "#{thispseudo}@mail.lui"
      end
    end
    context 'avec une where-clause définie par un hash' do
      it 'actualise la donnée' do
        thispseudo = 'WhereParHash'
        res = site.db.update(:hot, 'users', {pseudo: thispseudo, mail:"#{thispseudo}@mail.lui"}, {id: 100})
        newu = site.db.select(:hot, 'users', {id: 100}, 'pseudo, mail').first
        expect(newu[:pseudo]).to eq thispseudo
        expect(newu[:mail]).to eq "#{thispseudo}@mail.lui"
      end
    end
    context 'avec une where-clause définie par autre chose qu’un string ou un hash' do
      it 'produit une erreur' do
        [nil, true, [1,2,3]].each do |badwhere|
          expect{site.db.update(:hot, 'tickets', {code: "true"}, badwhere)}.to raise_error("Il faut fournir soit un String soit un Hash comme clause WHERE…")
        end
      end
    end
  end
end
