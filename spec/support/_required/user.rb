

def phil
  @phil ||= User.get(1)
end

def marion
  @marion ||= User.get(3)
end


def data_phil
  @data_phil ||= begin
    require './__SITE__/_config/data/secret/data_phil'
    DATA_PHIL
  end
end
