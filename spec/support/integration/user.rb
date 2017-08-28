
def identifier_phil
  visit signin_page
  within('form#signin_form') do
    fill_in 'user_mail', with: data_phil[:mail]
    fill_in 'user_password', with: data_phil[:password]
    click_button 'OK'
  end
end

# Simuler l'inscription complète d'un user avec les données +duser+
# Cette méthode :
#   - conduit l'utilisateur sur la page d'inscription
#   - remplit le formulaire
#   - soumet le formulaire
#
def simule_inscription_with duser, options = nil
  options ||= Hash.new
  options.key?(:reload) || options.merge!(reload: true)
  if options[:reload] || !page.has_selector?('form#signup_form')
    visit signup_page
  end
  within('form#signup_form') do
    duser.each do |prop, value|
      case prop
      when :sexe
        within("select#user_sexe") do
          find("option[value=\"#{value}\"]").click
        end
      when :password_confirmation
        # Quand fourni explicitement
        fill_in "user_#{prop}", with: value
      when :mail_confirmation
        # Quand fourni explicitement
        fill_in "user_#{prop}", with: value
      when :mail, :password
        fill_in "user_#{prop}", with: value
        fill_in "user_#{prop}_confirmation", with: value
      else
        fill_in "user_#{prop}", with: value
      end
    end
    click_button "S’inscrire"
  end
end
