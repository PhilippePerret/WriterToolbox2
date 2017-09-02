

def phil
  @phil ||= begin
    defined?(User) || require_lib_site
    User.get(1)
  end
end

def marion
  @marion ||= begin
    defined?(User) || require_lib_site
    User.get(3)
  end
end


def data_phil
  @data_phil ||= begin
    require './__SITE__/_config/data/secret/data_phil'
    DATA_PHIL
  end
end
