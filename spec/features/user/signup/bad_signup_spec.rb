
require_lib_site
require_support_integration

feature "Inscription d'un user" do

  before(:all) do
    success_tab '  '
  end

  let(:duser) { @duser ||= begin
    now = Time.now.to_i.to_s(36)
    {
      pseudo:     "Pseudo#{now}",
      patronyme:  "Pseudo #{now.titleize}",
      mail:       "pseudo#{now}@chez.lui",
      sexe:       'F',
      password:   now.ljust(12,'0'),
      captcha:    '366'
    }
  end }

  # Pour vérifier qu'aucun user n'a été créé
  let(:nombre_users_init) { @nombre_users_init ||= begin
    site.db.count(:hot, 'users')
  end }

  def signup_fail h, err_message
    simule_inscription_with duser.merge(h), {reload: false}
    expect(page).to have_tag('div.error', text: /#{Regexp.escape(err_message)}/)
    sleep 0.2 # ne précipitons pas les choses
  end

  # --- PSEUDO INVALIDE ----

  scenario '=> échoue avec un mauvais pseudo' do
    success_tab('  échoue si le pseudo ')

    signup_fail({pseudo: ''}, 'Il faut fournir votre pseudo.')
    success 'n’est pas fourni'

    signup_fail({pseudo: 'Marion'}, 'Ce pseudo existe déjà')
    success 'existe déjà'

    signup_fail({pseudo: 'pp'}, 'Ce pseudo est trop court')
    success 'fait moins de 3 signes'

    signup_fail({pseudo: 'p'*40}, 'Ce pseudo est trop long')
    success 'fait plus de 39 signes'

    signup_fail({pseudo: '! les étés mauvais ?'}, 'Ce pseudo est invalide')
    success 'contient des signes invalides'

    success_tab '  '
    expect(site.db.count(:hot, 'users')).to eq nombre_users_init
    success 'Aucun nouvel user n’a été créé'

  end

  # --- PATRONYME INVALIDE ---

  scenario '=> échoue avec un mauvais patronyme' do
    success_tab('  échoue si le patronyme ')

    signup_fail({patronyme: ''}, 'Il faut fournir votre patronyme')
    success 'n’est pas fourni'

    signup_fail({patronyme: 'Philippe Perret'}, 'Ce patronyme existe déjà')
    success 'existe déjà'

    signup_fail({patronyme: 'ppp'}, 'Ce patronyme est trop court')
    success 'fait moins de 4 lettres'

    signup_fail({patronyme: 'p'*256}, 'Ce patronyme est trop long')
    success 'fait plus de 255 lettres'

    success_tab '  '
    expect(site.db.count(:hot, 'users')).to eq nombre_users_init
    success 'Aucun nouvel user n’a été créé'

  end

  # --- MAIL INVALIDE ---

  scenario '=> échoue avec un mail invalide' do
    success_tab '  échoue si le mail '

    signup_fail({mail: ''}, 'Il faut fournir votre mail')
    success 'n’est pas fourni'

    signup_fail({mail: 'm'*200+'@'+'v'*52+'.com'}, 'Ce mail est trop long')
    success 'fait plus de 255 caractères'
    [
      'mauvaismail', 'mauvais mail',
      '@mauvaismail', 'mauvaismail@',
      '?mauvais@mail.com', 'mauvais@?mail.com', 'mauvais@mail.?com',
      'mauvais-mail@chez-com'
    ].each do |badmail|
      signup_fail({mail: badmail}, 'Ce mail n’a pas un format valide.')
    end
    success 'est d’un format invalide'

    signup_fail({mail_confirmation:'mauvaisconf'}, 'La confirmation du mail ne correspond pas')
    success 'n’a pas une bonne confirmation'

    success_tab '  '
    expect(site.db.count(:hot, 'users')).to eq nombre_users_init
    success 'Aucun nouvel user n’a été créé'

  end

  # --- MOT DE PASSE INVALIDE ---

  scenario '=> échoue si le mot de passe est invalide' do
    success_tab '  échoue si le mot de passe '

    signup_fail({password:''}, 'Il faut fournir un mot de passe')
    success 'n’est pas fourni'

    signup_fail({password:'p'*41}, 'Ce mot de passe est trop long')
    success 'fait plus de 40 signes'

    signup_fail({password:'p'*6}, 'Ce mot de passe est trop court')
    success 'fait moins de 8 signes'

    signup_fail({password_confirmation:'mauvaisconf'}, 'La confirmation du mot de passe ne correspond pas')
    success 'n’a pas une bonne confirmation'

    success_tab '  '
    expect(site.db.count(:hot, 'users')).to eq nombre_users_init
    success 'Aucun nouvel user n’a été créé'
  end

  # --- CAPTCHA INVALIDE ---

  scenario '=> échoue avec un mauvais captcha' do
    success_tab '  échoue si le captcha '

    signup_fail({captcha: ''}, 'Il faut fournir le captcha')
    success 'n’est pas fourni'

    ['365', 'captcha', 'pour voir'].each do |badcaptcha|
      signup_fail({captcha: badcaptcha}, 'Le captcha est mauvais, seriez-vous un robot')
    end
    success 'est invalide'

    success_tab '  '
    expect(site.db.count(:hot, 'users')).to eq nombre_users_init
    success 'Aucun nouvel user n’a été créé'

  end
end
