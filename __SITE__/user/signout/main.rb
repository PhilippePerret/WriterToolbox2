# encoding: UTF-8
=begin

  Gestion de la déconnection de l'user

=end
class User

  # Cette méthode ne sert qu'ici
  def signout
    site.db.update(:hot, 'users', {session_id: ''}, {id: self.id})
    site.session['user_id']             = nil
    site.session['date_last_connexion'] = nil
    site.session['tentatives_login']    = 0
  end

end

if user.identified?
  dmessage = "À très bientôt j’espère, #{user.pseudo} !"
  user.signout
else
  dmessage = ["Vous n'êtes pas connecté ! Vous ne pouvez pas vous déconnecter, voyons !", :error]
end

redirect_to( 'home', dmessage )
