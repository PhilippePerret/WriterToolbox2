=begin

  Test d'une bonne création d'user

=end

require_lib_site
require_support_integration
require_support_db_for_test
require_support_mails_for_test

feature 'Inscription d’un utilisateur' do
  before(:all) do
    truncate_table_users
    remove_mails
    remove_debug
  end
  scenario 'L’utilisateur peut rejoindre le formulaire' do
    visit signup_page
    expect(page).to have_tag('form#signup_form')
  end
  context 'avec des données valides' do
    before(:all) do
      @start_time = now = Time.now.to_i
      @mail  = "marcelle.#{now}@chez.lui"
      @duser = {
        pseudo:     "Marcelle#{now}",
        patronyme:  "Marcelle The#{now}",
        mail:       @mail,
        sexe:       'F',
        password:   now,
        captcha:    '366'
      }
      simule_inscription_with @duser
    end
    scenario '=> crée l’utilisateur avec succès' do
      tab = '    '
      expect(page).to have_content "Vous vous êtes inscrite avec succès"
      success tab+'conduit l’utilisateur à la bonne page'

      db_use(:hot)
      statement = db_prepare("SELECT * FROM users WHERE mail = ?")
      res = statement.execute(@mail).first
      @duser.each do |prop, value|
        case prop
        when :captcha
          # ne rien faire
        when :password
          # Voir si le mot de passe a bien été crypté
          salt = res[:salt]
          require 'digest/md5'
          expect(res[:cpassword]).to eq(Digest::MD5.hexdigest("#{value}#{@duser[:mail]}#{salt}"))
        else
          expect(res[prop]).to eq value
        end
      end
      # Données supplémentaires
      expect(res[:options]).to eq '0000000000'
      expect(res[:created_at]).to be > @start_time
      expect(res[:updated_at]).to be > @start_time
      success tab+'crée l’utilisateur dans la table hot.users avec les bonnes données'

      @duser.merge!(id: res[:id])

      newU = User.get(@duser[:id])

      success tab+"ID new user : #{newU.id}"
      success tab+"MAIL new user : #{newU.mail}"
      sta = db_prepare('SELECT * FROM tickets WHERE user_id = ? AND code = ?')
      res = db_exec_statement(sta, [newU.id, "User.get(#{newU.id}).confirm_mail"])
      expect(res).not_to be_empty
      res = res.first
      ticket_id   = res[:id]
      ticket_code = res[:code]
      success tab+'un ticket a été généré pour valider le mail'

      expect(newU).to have_mail({
        sent_after: @start_time,
        subject:    "Confirmation de votre inscription",
        message:    "#{newU.pseudo}, bienvenue sur #{site.configuration.titre}"
        })
      success tab+'un mail a été envoyé à l’user pour confirmer son inscription'

      expect(newU).to have_mail({
        sent_after: @start_time,
        subject:    "Confirmez votre adresse mail",
        message:    [
          "<a href=\"http://#{site.configuration.url_online}?tckid=#{ticket_id}\">Confirmer la validité du mail #{newU.mail}</a>"
          ]
        })
      success tab+'un mail a été envoyé à l’user pour qu’il confirme son mail (avec le bon lien)'

      expect(phil).to have_mail({
        sent_after: @start_time,
        subject:    "[BOA] Nouvelle inscription",
        message:    ["nouvelle inscription", newU.pseudo, newU.mail]
        })
      success tab+'un mail a été envoyé à l’administration avec les bonnes informations'

      sid = site.db.select(:hot, 'users', {id: newU.id}, [:session_id] )
      sid = sid.first[:session_id].nil_if_empty
      expect(sid).not_to be_nil
      success tab+'l’user est connecté (on le sait pas son session_id qui est défini)'
    end
  end
end
