# encoding: UTF-8
class User
class << self

  attr_accessor :_users

  def get user_id, forcer = nil
    @_users || @_users = Hash.new
    forcer && @_users[user_id] = nil
    @_users[user_id] ||= begin
      udata = site.db.select(:hot, 'users', {id: user_id}).first
      udata.nil? ? nil : User.new(udata)
    end
    @_users[user_id]
  end

end #/<< self
end #/User
