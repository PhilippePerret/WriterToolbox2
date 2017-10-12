# encoding: utf-8
class User

  # --------------------------------------------------------------------------------
  #
  #   MÉTHODES FONCTIONNELLES POUR LES PRÉFÉRENCES
  #
  # --------------------------------------------------------------------------------

  # Enregistrement des préférences
  def save_preferences

    save_options = false
    
    prefs = param(:prefs)

    # Préférence de contact

    if prefs[:contact] != data[:options][4]
      data[:options][4] = prefs[:contact]
      save_options = true
    end

    # Page à rejoindre après l'identification
    
    pref_after_login = prefs[:after_login].to_i
    if var['goto_after_login'] != pref_after_login
      var['goto_after_login'] = pref_after_login
    end
    if pref_after_login == 3
      page_after_login = prefs[:page_after_login].nil_if_empty
      if page_after_login.nil?
        return __error('Vous devez définir la page à atteindre après l’identification.')
      end
      var['page_after_login'] = prefs[:page_after_login]
    elsif var['page_after_login'] != nil
      var['page_after_login'] = nil
    end

    # Notification

    if prefs[:notification] != data[:options][5]
      data[:options][5] = prefs[:notification]
      save_options = true
    end

    if save_options
      site.db.update(:hot,'users',{options: data[:options]},{id: self.id})
    end
    
    __notice('Vos préférences sont enregistrées.')
  end


  # --------------------------------------------------------------------------------
  #
  #   CONSTRUCTION DES RANGÉES
  #
  # --------------------------------------------------------------------------------

  # Rangée pour définir comment et par qui être contacté
  def row_preference_contact
   row('Contact', menu_contacts)
  end

  def row_preference_after_login
    row('Après l’identification…', menu_after_login)+
      row('Rejoindre cette page après l’identification <span>(copier-coller son URL)</span>', 
          "<input type=\"text\" name=\"prefs[page_after_login]\" id=\"prefs_page_after_login\" value=\"#{self.var['page_after_login']}\" />")
  end

  def row_preference_notification
    row('Notification', menu_notification)
  end


  # --------------------------------------------------------------------------------
  #
  #   CONSTRUCTION DES ÉLÉMENTS
  #
  # --------------------------------------------------------------------------------

  # Menu pour définir le contact
  def menu_contacts
    <<-HTML
    <select name="prefs[contact]" id="prefs_contact">
      <option value="0">personne ne peut vous contacter</option>
      <option value="6">Administrateurs et inscrits peuvent vous contacter</option>
      <option value="2">Seuls les administrateurs peuvent vous contacter</option>
      <option value="4">Seuls les inscrits au site peuvent vous contacter</option>
      <option value="8">Tout le monde peut vous contacter</option>
    </select>
    <script type="text/javascript">
    document.querySelector('select#prefs_contact').value = "#{data[:options][4]||6}";
    </script>
    HTML
  end


  # Menu pour définir ce qu'il faut faire après l'identification
  def menu_after_login
    <<-HTML
    <select id="prefs_after_login" name="prefs[after_login]">
      <option value="0">rejoindre l’accueil du site</option>
      <option value="1">rejoindre votre profil</option>
      <option value="2">rejoindre la dernière page visitée</option>
      <option value="9">rejoindre votre bureau UN AN UN SCRIPT (si programme)</option>
      <option value="3">rejoindre la page spécifiée ci-dessous</option>
    </select>
    <script type="text/javascript">
      document.querySelector('select#prefs_after_login').value = '#{self.var['goto_after_login']}';
    </script>
    HTML
  end

  def menu_notification
    <<-HTML
    <select id="prefs_notification" name="prefs[notification]">
      <option value="0">Ne recevoir aucune notification</option>
      <option value="1">Recevoir les notifications quotidiennement</option>
      <option value="2">Recevoir une seule notification hebdomadaire</option>
    </select>
    <script type="text/javascript">
    document.querySelector('select#prefs_notification').value = '#{data[:options][5]||1}';
    </script>
    HTML
  end
end #/User
