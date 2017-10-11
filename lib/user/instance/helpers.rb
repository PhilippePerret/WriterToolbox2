# encoding: UTF-8
class User

  def f_e
    @f_e ||= (homme? ? '' : 'e')
  end

  def f_te # cet/cette
    @f_te ||= (homme? ? '' : 'te')
  end
  def f_la
    @f_la ||= (homme? ? 'le' : 'la')
  end

  def f_elle
    @f_elle ||= (homme? ? 'il' : 'elle')
  end

  def f_ve
    @f_ve ||= (homme? ? 'f' : 've')
  end

  def f_rice # p.e. rédact<eur|rice>
    @f_rice ||= (homme? ? 'eur' : 'rice')
  end

  def f_sse # p.e. maitre<sse>
    @f_sse ||= (homme? ? '' : 'sse')
  end

end #/User
