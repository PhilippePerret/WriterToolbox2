require_lib_site
require './lib/utils/updates'

describe Updates do
  let(:update) { @update ||= begin
    Updates.new(id: 12, message: "Une actualité", created_at: Time.now.to_i)
  end }
  describe '#as_li' do
    it 'répond' do
      expect(update).to respond_to :as_li
    end
    it 'retourne le code LI pour l’actualisation' do
      res = update.as_li
      expect(res).to have_tag('li', with: {id: 'update-12', class: 'update'}, text:/Une actualité/)
    end
    it 'contient un lien si contient une route' do
      date = Time.now
      u = Updates.new(message: "Actualité avec route", route: 'unan/home', created_at: date.to_i)
      res = u.as_li
      expect(res).to have_tag('a', with: {href: 'unan/home', class: 'update'})
      expect(res).to have_tag('span', with: {class: 'date'}, text: date.strftime('%d %m %Y'))
    end
  end
end
