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

  end

end
