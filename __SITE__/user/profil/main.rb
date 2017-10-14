# encoding: utf-8
class User
end


def u
  @u ||= User.get(site.route.objet_id || user.id)
end
