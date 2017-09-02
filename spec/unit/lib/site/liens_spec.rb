require_lib_site


describe 'Liens' do
  describe '#def_params' do
    it 'répond' do
      expect(site.lien).to respond_to :def_params
    end
    it 'produit une erreur sans les deux arguments' do
      expect{site.lien.def_params}.to raise_error ArgumentError
      expect{site.lien.def_params(nil)}.to raise_error ArgumentError
    end
    context 'avec deux arguments nil' do
      it 'produit une erreur d’argument' do
        expect{site.lien.def_params(nil,nil)}.to raise_error("Il faut au moins fournir le titre par défaut du lien.")
      end
    end
    context 'avec (nil, hash définissant le titre)' do
      it 'retourne un hash définissant le titre par défaut' do
        expect(site.lien.def_params(nil,{titre: "Mon titre test"})).to eq( {titre: "Mon titre test"})
      end
    end
    context 'avec (titre, hash définissant le titre)' do
      it 'retourne un hash définissant le titre du première argument' do
        expect(site.lien.def_params('Un autre test', {titre: "Mon titre test"})).to eq( {titre: "Un autre test"})
      end
    end
    context 'avec (hash définissant le titre, hash définissant le titre par défaut)' do
      it 'retourne un hash définissant le titre du premier hash' do
        expect(site.lien.def_params({titre: 'Un troisième'}, {titre: "Titre par défaut"})).to eq( {titre: 'Un troisième'})
      end
    end
    context 'avec (hash définissant autre variables, hash de titre par défaut)' do
      it 'retourne un hash avec le bon titre et les variables' do
        hash1 = {titre: "Titre customisé", class: "sa classe"}
        hash2 = {titre: "Le titre par défaut"}
        expect(site.lien.def_params(hash1, hash2)).to eq( {titre: "Titre customisé", class: "sa classe"})
      end
    end
  end

  describe 'site.lien.signup' do
    context 'sans argument' do
      it 'retourne le lien par défaut' do
        expect(site.lien.signup).to eq "<a href='user/signup' class=\"\">S’inscrire</a>"
      end
    end
    context 'avec un titre string en premier argument' do
      it 'le met comme titre' do
        expect(site.lien.signup("Venez")).to eq "<a href='user/signup' class=\"\">Venez</a>"
      end
    end
    context 'avec un hash définissant le titre' do
      it 'met le titre en titre' do
        expect(site.lien.signup({titre: "Ou revenez"})).to eq "<a href='user/signup' class=\"\">Ou revenez</a>"
      end
    end
    context 'avec un hash définissant la class seulement' do
      it 'met le titre par défaut et ajoute la classe' do
        expect(site.lien.signup({class:"hiscss"})).to eq "<a href='user/signup' class=\"hiscss\">S’inscrire</a>"
      end
    end
    context 'avec un hash définissant class et titre' do
      it 'met le titre et la classe' do
        expect(site.lien.signup({titre: "Titre custom", class:"sacss"})).to eq "<a href='user/signup' class=\"sacss\">Titre custom</a>"
      end
    end
  end

  describe '#signin' do
    it 'retourne le bon lien' do
      expect(site.lien.signin).to eq "<a href=\"user/signin\" class=\"\">S’identifier</a>"
    end
  end
  describe '#profil' do
    it 'retourne le lien vers le profil' do
      expect(site.lien.profil).to eq "<a href=\"user/profil\" class=\"\">profil</a>"
    end
  end
  describe '#outils' do
    it 'retourne le lien vers les outils' do
      expect(site.lien.outils).to eq "<a href=\"outils\" class=\"\">outils</a>"
    end
  end
  describe '#narration' do
    it 'retourne le lien vers la collection' do
      expect(site.lien.narration).to eq "<a href=\"narration\" class=\"\">collection Narration</a>"
    end
  end
end
