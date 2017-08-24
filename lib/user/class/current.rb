# encoding: UTF-8


def user
  User.current
end


class User
class << self

  attr_writer :current

  def current
    @current ||= User.new
  end

  # Reconnect l'user s'il état connecté (on le sait grâce à la
  # variable session 'user_id', en vérifiant si sa session est la bonne)
  def reconnect
    site.session['user_id'] || return
    u = get(site.session['user_id'].to_i)
    sessid_in_db = site.db.select(:hot, 'users', {id: u.id}, ['session_id'])
    sessid_in_db = sessid_in_db[0][:session_id]
    sessid_in_db == site.session.session_id && u.login
  end

end # << self
end # User
