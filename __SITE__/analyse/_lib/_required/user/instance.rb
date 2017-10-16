# encoding: utf-8
class User

  def analyste?
    @is_analyste.nil? && @is_analyste = identified? && (data[:options][16].to_i > 2)
    @is_analyste
  end

end #/User
