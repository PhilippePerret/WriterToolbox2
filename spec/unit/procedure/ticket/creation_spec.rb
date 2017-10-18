=begin

  Test de la création d'un ticket

=end

describe 'Création d’un ticket' do


  before(:all) do
    require_lib_site
    require_support_tickets
    remove_tickets
    require_folder('./lib/procedure/ticket')
  end

  describe '::create' do
    it 'répond' do
      expect(Ticket).to respond_to :create
    end

    context 'avec les bons arguments (par défaut)' do
      describe 'permet de générer un ticket' do
        before(:all) do
          remove_tickets
          expect(tickets_count).to eq 0
          # ============> TEST <===========
          Ticket.create({
            user_id: 1,
            code:    "__notice('Bonjour Phil !')"
          })
          # =========== VÉRIFICATIONS ==========
          @thelast = last_ticket
        end
        it 'dans la base de données avec les bonnes données' do
          expect(tickets_count).to eq 1
          expect(@thelast[:user_id]).to eq 1
          expect(@thelast[:code]).to eq "__notice('Bonjour Phil !')"
        end

        it 'a mis dans Ticket.id la bonne valeur' do
          expect(Ticket.id).to eq @thelast[:id]
        end

        it 'a mis dans Ticket.url la bonne valeur' do
          expect(Ticket.url).to eq "http://#{site.configuration.url_online}?tckid=#{@thelast[:id]}"
        end

        it 'a mis dans Ticket.link le lien vers le ticket' do
          expect(Ticket.link).to eq "<a href=\"http://#{site.configuration.url_online}?tckid=#{@thelast[:id]}\">Jouer ce ticket</a>"
        end
      end
    end

    context 'en définissant le titre du lien' do
      before(:all) do
        remove_tickets
        expect(tickets_count).to eq 0
        # ============> TEST <===========
        Ticket.create({
          user_id: 1,
          code:    "__notice('Bonjour Marion !')",
          a_title: 'Appeler Marion'
        })
        # =========== VÉRIFICATIONS ==========
        @thelast = last_ticket
      end
      it 'a créé le ticket' do
        expect(tickets_count).to eq 1
      end
      it 'utilise le titre donné pour le lien' do
        expect(Ticket.link).to eq "<a href=\"http://#{site.configuration.url_online}?tckid=#{@thelast[:id]}\">Appeler Marion</a>"
      end
    end

    context 'en définissant une class CSS pour le lien' do
      before(:all) do
        remove_tickets
        expect(tickets_count).to eq 0
        # ============> TEST <===========
        Ticket.create({
          user_id: 1,
          code:    "__notice('Bonjour Marion !')",
          a_class: 'saclasse'
        })
        # =========== VÉRIFICATIONS ==========
        @thelast = last_ticket
      end
      it 'a créé le ticket' do
        expect(tickets_count).to eq 1
      end
      it 'utilise la classe CSS dans le lien' do
        expect(Ticket.link).to eq "<a href=\"http://#{site.configuration.url_online}?tckid=#{@thelast[:id]}\" class=\"saclasse\">Jouer ce ticket</a>"
      end
    end

    context 'en définissant title et classe pour le lien' do
      before(:all) do
        remove_tickets
        expect(tickets_count).to eq 0
        # ============> TEST <===========
        Ticket.create({
          user_id: 1,
          code:    "__notice('Bonjour Marion !')",
          a_title:  'Son titre',
          a_class: 'saclasse'
        })
        # =========== VÉRIFICATIONS ==========
        @thelast = last_ticket
      end
      it 'a créé le ticket' do
        expect(tickets_count).to eq 1
      end
      it 'utilise le titre et la classe CSS dans le lien' do
        expect(Ticket.link).to eq "<a href=\"http://#{site.configuration.url_online}?tckid=#{@thelast[:id]}\" class=\"saclasse\">Son titre</a>"
      end
    end

    context 'en ne définissant pas l’user_id' do
      before(:all) do
        User.current = phil
        remove_tickets
        expect(tickets_count).to eq 0
        Ticket.create({
          code: '__notice("Un ticket sans user_id")'
          })
        @thelast = last_ticket
      end
      it 'crée bien le ticket' do
        expect(tickets_count).to eq 1
      end
      it 'met l’user_id de l’user courant' do
        expect(@thelast[:user_id]).to eq 1 # Phil
      end
    end

    context 'en ne définissant pas le code' do
      it 'génère une erreur' do
        expect{Ticket.create({user_id: 2})}.to raise_error(ArgumentError, "Il faut définir le code du ticket !")
      end
    end

    context 'sans Hash en premier argument' do
      it 'génère une erreur d’argument' do
        [true, 1, ['une','liste'], nil, phil].each do |bad|
          expect{Ticket.create(bad)}.to raise_error(ArgumentError, "Le premier argument doit être un Hash des données !")
        end
      end
    end

  end

end
