require_lib_site

describe 'Forum::Post' do
  before(:all) do
    require_folder('./__SITE__/forum/_lib/_required')
    expect(defined?(Forum)).to eq 'constant'
    expect(defined?(Forum::Post)).to eq 'constant'
  end
  describe 'Méthodes' do
    describe '::get' do
      it 'répond' do
        expect(Forum::Post).to respond_to :get
      end
      it 'retourne l’instance Forum::Post du message voulu' do
        res = Forum::Post.get(1)
        expect(res).not_to eq nil
        expect(res).to be_a Forum::Post
        expect(res.id).to eq 1
      end
    end
  end
end
