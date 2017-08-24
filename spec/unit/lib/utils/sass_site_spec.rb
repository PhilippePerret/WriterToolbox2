describe 'SassSite' do
  before(:all) do
    require './lib/utils/sass_all'
  end

  # SassSite::dest_file_of_src_file
  describe '::dest_file_of_src_file' do
    it 'répond' do
      expect(SassSite).to respond_to :dest_file_of_src_file
    end
    it 'retourne le path du fichier de destination (dans ./css) du fichier source fourni' do
      res = SassSite.dest_file_of_src_file('./__SITE__/objet/method/fichier.sass')
      expect(res).to eq './css/objet/method/fichier.css'
    end

  end
end
