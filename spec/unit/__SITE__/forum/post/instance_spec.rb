require_lib_site

describe 'Instance Forum::Post' do
  before(:all) do
    require_folder('./__SITE__/forum/_lib/_required')
    expect(defined?(Forum)).to eq 'constant'
    expect(defined?(Forum::Post)).to eq 'constant'

    @hpost = site.db.select(:forum,'posts',"user_id = 1 LIMIT 1").first

  end

  let(:hpost) { @hpost }
  let(:post) { @post ||= Forum::Post.get(hpost[:id]) }

  describe 'Méthodes' do
    describe '#data_mini' do
      it 'répond' do
        expect(post).to respond_to :data_mini
      end
      it '=> retourne les données minimales' do
        d = post.data_mini
        expect(d).to have_key :id
        expect(d[:id]).to eq hpost[:id]
        expect(d).to have_key :sujet_id
        expect(d).to have_key :user_id
        expect(d[:user_id]).to eq 1
        expect(d).to have_key :created_at
        expect(d).to have_key :updated_at
        expect(d).not_to have_key :auteur_id
        expect(d).not_to have_key :auteur_pseudo
        expect(d).not_to have_key :vote
        expect(d).not_to have_key :upvotes
        expect(d).not_to have_key :downvotes
      end
    end

    describe '#data' do
      it 'répond' do
        expect(post).to respond_to :data
      end
      it '=> retourne toutes les données du message (par jointure)' do
        success_tab('      ')
        d = post.data
        success 'retourne les données…'
        expect(d).to have_key :id
        expect(d[:id]).to eq hpost[:id]
        success  '  - ID du post (:id)'
        expect(d).to have_key :sujet_id
        success '  - ID du sujet du post (:sujet_id)'
        expect(d).to have_key :user_id
        expect(d[:user_id]).to eq 1
        expect(d).to have_key :auteur_id
        expect(d[:auteur_id]).to eq 1
        success '  - ID de l’auteur du post (:user_id et :auteur_id)'
        expect(d).to have_key :auteur_pseudo
        expect(d[:auteur_pseudo]).to eq 'Phil'
        success '  - le pseudo de l’auteur du message (:auteur_pseudo)'
        expect(d).to have_key :content
        expect(d[:content]).to be_a(String)
        success '  - Le contenu du post (:content)'
        expect(d).to have_key :parent_id
        success '  - l’ID éventuel du parent (:parent_id)'
        expect(d).to have_key :created_at
        expect(d[:created_at]).not_to eq nil
        success '  - la date de création du post (:created_at)'
        expect(d).to have_key :updated_at
        success '  - la date de dernière modification du post (:updated_at)'
        expect(d).to have_key :vote
        expect(d[:vote]).not_to eq nil
        success '  - la valeur de vote du post (:vote)'
        expect(d).to have_key :upvotes
        success '  - les ID des lecteurs ayant voté pour le message'
        expect(d).to have_key :downvotes
        success '  - les ID des lecteurs ayant voté contre le message'
      end
    end
    describe '#id' do
      it 'répond' do
        expect(post).to respond_to :id
      end
      it 'retourne l’ID du message' do
        expect(post.id).to eq @hpost[:id]
      end
    end

    describe '#sujet_id' do
      it 'répond' do
        expect(post).to respond_to :sujet_id
      end
      it 'retourne l’ID du sujet du message' do
        expect(post.sujet_id).to eq @hpost[:sujet_id]
      end
    end

    describe '#auteur_id' do
      it 'répond' do
        expect(post).to respond_to :auteur_id
      end
      it 'retourne l’ID de l’auteur' do
        expect(post.auteur_id).to eq 1
      end
    end

    describe '#auteur' do
      it 'répond' do
        expect(post).to respond_to :auteur
      end
      it 'retourne l’auteur du message' do
        a = post.auteur
        expect(a).not_to eq nil
        expect(a).to be_a User
        expect(a.id).to eq 1
      end
    end

    describe '#sujet' do
      it 'répond' do
        expect(post).to respond_to :sujet
      end
      it 'retourne une instance du suejt' do
        expect(post.sujet).to be_a(Forum::Sujet)
        expect(post.sujet.id).to eq hpost[:sujet_id]
      end
    end

    describe '#route' do
      it 'répond' do
        expect(post).to respond_to :route
      end
      it 'retourne la route pour atteindre le message' do
        res = post.route
        expect(res).to eq "forum/post/#{post.id}"
      end
    end

    describe '#route_in_sujet' do
      it 'répond' do
        expect(post).to respond_to :route_in_sujet
      end
      it 'retourne la route pour atteindre le message' do
        res = post.route_in_sujet
        expect(res).to eq "forum/sujet/#{post.sujet_id}?pid=#{post.id}"
      end
    end
  end
end
