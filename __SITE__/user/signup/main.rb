# encoding: UTF-8

# Pour requêrir les éléments utiles aux formulaires
require_form_support

# On met ça dans une méthode, car sinon, le case-statement serait
# joué dès le chargement du dossier, avant même que la page erb soit
# construite et surtout avant que user.rb ne soit chargé, et donc la
# class User ne connaitrait pas encore la méthode `signup`
def operation_if_needed

  if param(:user)
    case param(:operation) # peut être défini en le forçant
    when 'signup'
      # Est-ce qu'il existe bien un FORMID
      if ! param(:FORMID)
        __error("Aucun formulaire n'est soumis…")
      elsif Form.form_already_submitted?(param(:FORMID))
        # C'est un formulaire re-soumis ou n'existant pas
        __error("Vous avez déjà soumis ce formulaire&nbsp;!")
      elsif user.identified?
        __error("Vous êtes déjà inscrit#{user.f_e} sur le site, #{user.pseudo}&nbsp;! ;-)")
      else
        # On peut procéder à l'inscription
        # Noter qu'ici on utilise tout à fait normalement l'instance
        # user créée systématiquement
        user.signup
      end

    end
  end

end
