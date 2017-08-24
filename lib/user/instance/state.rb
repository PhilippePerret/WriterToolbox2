# encoding: UTF-8
class User

  def identified?
    id != nil
  end

  def admin?
    identified? && id < 10
  end

  def homme?
    @is_homme ||= !femme?
  end
  def femme?
    @is_femme ||= @sexe == 'F'
  end

end #/User
