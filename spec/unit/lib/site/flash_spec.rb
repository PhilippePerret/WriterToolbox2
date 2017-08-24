describe 'Site::Flash' do

  describe '__notice et Site::Flash#notice' do
    it 'répond' do
      expect{__notice("mon message")}.not.to raise_error
    end
    it 'répond dans la class Flash' do
      expect(site.flash).to respond_to :notice
    end
    it 'enregistre le message à afficher' do
      pending
    end
  end

  describe '__error et Site::Flash#error' do
    it 'répond' do
      expect{__error("Une erreur")}.not.to raise_error
    end
    it 'répond dans la class Site::Flash' do
      expect(site.flash).to respond_to :error
    end
    context 'quand le premier argument est un simple message' do
      it 'affiche le message' do
        pending
      end
    end
    context 'quand le premier argument est une instance d’erreyr' do
      it 'affiche le message d’erreur et envoie le reste en debug' do
        pending
      end
    end
    context 'quand le premier argument est une liste de messages ou d’erreurs' do
      it 'traite chaque message ou erreur séparément' do
        pending
      end
    end
  end
end
