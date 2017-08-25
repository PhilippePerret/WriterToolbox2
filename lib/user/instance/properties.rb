# encoding: UTF-8
class User

  include PropsAndDbMethods
  
  attr_reader :id, :mail
  attr_reader :session_id
  # attr_reader :options # dans options.rb

  def pseudo
    @pseudo ||= "Ernest"
  end
  def patronyme
    @patronyme ||= "Ernest Dupont"
  end

  def base_n_table
    @base_n_table ||= [:hot, 'users']
  end

end
