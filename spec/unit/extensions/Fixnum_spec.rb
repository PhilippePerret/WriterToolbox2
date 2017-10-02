require_lib_site

describe Fixnum do
  describe '#as_human_date' do
    it 'répond' do
      expect(1).to respond_to :as_human_date
    end
    context 'sans argument' do
      it 'retourne la valeur au format par défaut' do
        x = Time.now.to_i
        f = Time.now.strftime('%d %m %Y - %H:%M')
        expect(x.as_human_date).to eq f
      end
    end

    context 'avec un argument définissant le format' do
      it 'retourne la valeur au format demandé' do
        fmt = '%d %m %Y'
        x = Time.now.to_i
        expect(x.as_human_date(fmt)).to eq Time.now.strftime(fmt)
      end
    end
  end

  describe '#ago' do
    it 'répond' do
      expect(12).to respond_to :ago
    end
    context 'sans argument' do
      it '=> retourne la bonne valeur' do
        success_tab('      ')
        now = Time.now.to_i
        [
          [0, 'maintenant'],
          [-1, "il y a 1 seconde"],
          [-12, "il y a 12 secondes"],
          [-3600, "il y a 1 heure"],
          [-3600*2, "il y a 2 heures"],
          [3600*2, "dans 2 heures"],
          [-(3600*2+2), "il y a 2 heures"],
          [-3*60, 'il y a 3 minutes'],
          [3*60, 'dans 3 minutes'],
          [-(3*60 + 12), 'il y a 3 minutes et 12 secondes'],
          [-12.jours, "il y a 12 jours"],
          [-(12.jours+4.heures), "il y a 12 jours et 4 heures"],
          # Pas les minutes quand il y a des jours
          [-(12.jours+4.heures+2.minutes), "il y a 12 jours et 4 heures", "[pas de minutes quand il y a des jours]"],
          # Pas de secondes quand il y a des jours
          [-(12.jours+4.heures+53), "il y a 12 jours et 4 heures", "[pas de secondes quand des jours]"],
          [-(12.jours+4.heures+3.minutes+53), "il y a 12 jours et 4 heures", "[ni minutes ni secondes quand il y des jours]"],
          [-2.mois, "il y a 2 mois"],
          [-(2.mois+12.jours), "il y a 2 mois et 12 jours"],
          [-(2.mois+4.heures), "il y a 2 mois", "[pas d'heures avec des mois]"],
          [-(2.mois+4.minutes), "il y a 2 mois", "[pas de minutes avec des mois]"],
          [-(2.mois+4), "il y a 2 mois", "[pas de secondes avec des mois]"],
          [-(2.mois+3.jours+4.heures+5.minutes+4), 'il y a 2 mois et 3 jours', "[rien en dessous des jours avec des mois]"],
          [-3.annees, 'il y a 3 ans'],
          [3.annees, 'dans 3 ans'],
          [-(3.annees+4.mois), 'il y a 3 ans et 4 mois'],
          [-(3.annees+4.mois+5.jours), 'il y a 3 ans et 4 mois', '[pas de jours avec des années]'],
          [3.annees+4.mois+5.jours, 'dans 3 ans et 4 mois', '[pas de jours avec des années]'],
          [-(3.annees+4.mois+6.heures), 'il y a 3 ans et 4 mois', '[pas de heures avec des années]'],
          [-(3.annees+4.mois+7.minutes), 'il y a 3 ans et 4 mois', '[pas de minutes avec des années]'],
          [-(3.annees+4.mois+8), 'il y a 3 ans et 4 mois', '[pas de secondes avec des années]'],
          [-(3.annees+4.mois+5.jours+6.heures+7.minutes+8), 'il y a 3 ans et 4 mois', '[rien en dessous des mois avec des années]']
        ].each do |laps, expected, precision|
          temps = Time.now.to_i + laps
          expect(temps.ago).to eq expected
          mess = "NOW#{laps}.ago retourne #{expected}"
          precision && mess << " (#{precision})"
          success mess
        end
      end
    end
  end
end
