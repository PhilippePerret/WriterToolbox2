require_lib_site


describe 'Forum::Sujet' do
  before(:all) do
    require_folder('./__SITE__/forum/_lib/_required')
    expect(defined?(Forum)).to eq 'constant'
    expect(defined?(Forum::Sujet)).to eq 'constant'

    @hsujet = site.db.select(:forum,'sujets',"creator_id = 1 LIMIT 1").first

  end

  let(:hsujet) { @hsujet }


end
