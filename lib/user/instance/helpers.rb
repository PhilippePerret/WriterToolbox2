# encoding: UTF-8
class User

  def f_e
    @f_e ||= (homme? ? '' : 'e')
  end

  def f_la
    @f_la ||= (homme? ? 'le' : 'la')
  end

  def f_elle
    @f_elle ||= (homme? ? 'il' : 'elle') 
  end
end #/User
