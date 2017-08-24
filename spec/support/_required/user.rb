

def phil
  @phil ||= User.get(1)
end

def marion
  @marion ||= User.get(3)
end
