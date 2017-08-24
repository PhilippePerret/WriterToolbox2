# encoding: UTF-8
class Site

  def offline?
    true # pour le moment
  end
  def online? ; !offline? end

end
