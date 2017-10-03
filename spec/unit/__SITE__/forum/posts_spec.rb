=begin

  Tests unitaires pour les méthodes post

=end

require_lib_site
require_support_forum

describe 'Posts' do
  before(:all) do
    site.load_folder 'forum'
    require_folder './__SITE__/forum/post/'
  end

  describe 'Méthode de Forum::Post' do
    describe 'add_post_to_user' do
      it 'répond' do
        expect(Forum::Post).to respond_to: :add_post_to_user
      end
      context 'sans arguments valides (user ou ID, ID post, post appartenant à User)' do
        it 'produit une erreur' do
          expect{Forum::Post.add_post_to_user}.to raise_error ArgumentError
          expect{Forum::Post.add_post_to_user(1)}.to raise_error ArgumentError
          expect{Forum::Post.add_post_to_user(10000000000,1000000000)}.to raise_error ArgumentError
          [true, {un:'hash'}, ['une','liste'], nil].each do |bad|
            expect{Forum::Post.add_post_to_user(1, bad)}.to raise_error ArgumentError
          end
          hpost = site.db.select(:forum,'posts', "user_id IS NOT 1 LIMIT 1", [:id]).first
          expect{Forum::Post.add_post_to_user(1,hpost[:id])}.to raise_error ArgumentError, 'Le message n’appartient pas à cet auteur.'
        end
      end

      context 'avec des arguments valides' do

        context 'avec un auteur qui ne possède encore aucun message' do
          before(:all) do
            @hnew_user    = create_new_user(validate_mail: true)
            @hnew_post    = create_new_post(auteur_id: @hnew_user[:id])
          end
          it 'définit un premier message pour l’auteur' do
            start_time = Time.now.to_i - 1
            # ============== PRÉ-VÉRIFICATIONS ============
            huser = site.db.select(:forum,'users',{id: @hnew_user[:id]}).first
            expect(huser).to eq nil
            # =============> TEST <=============
            Forum::Post.add_post_to_user(@hnew_user[:id], @hnew_post[:id])
            # =========> VÉRIFICATION <===========
            huser = site.db.select(:forum,'users',{id: @hnew_user[:id]}).first
            expect(huser).not_to eq nil
            expect(huser[:count]).to eq 1
            expect(huser[:last_post_id]).to eq @hnew_post[:id]
          end
        end

        context 'avec un auteur qui possède déjà des messages' do
          it 'ajoute ce message en actualisant la donnée' do
            start_time = Time.now.to_i - 1
            huser_init = site.db.select(:forum,'users',{id: user_id}).first
            # ==========> TEST <============
            Forum::Post.add_post_to_user(user_id, post_id)
            # ========== VÉRIFICATIONS ============
            huser2 = site.db.select(:forum,'users',{id: user_id}).first
            expect(huser[:count]).to eq huser_init[:count] + 1
            expect(huser[:last_post_id]).to eq post_id
            expect(huser[:updated_at]).to be > start_time
          end
        end
      end



    end
  end
end
