# encoding: UTF-8

class Site

  # Crée un ticket de validation de l'adresse mail
  # @return {String}
  #         L'ID du ticket créé pour la validation du mail
  #
  def create_ticket_validation_mail user_id
    require 'securerandom'
    ticket_id = SecureRandom.hex
    site.db.insert(:hot, 'tickets', {
      id:       ticket_id,
      user_id:  user_id,
      code:     "User.get(#{user_id}).confirm_mail"
      })
    return ticket_id
  end

  # ---------------------------------------------------------------------
  #   HELPERS
  # ---------------------------------------------------------------------
  def menu_sexe
    Form.select_field({
      name:     'user[sexe]', id: 'user_sexe',
      class:    'medium',
      options:  [['F', 'Femme'],['H', 'Homme'],['X', 'Autre…']],
      selected: param(:user)[:sexe]
      })
  end

end #/Site
