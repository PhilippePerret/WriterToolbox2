# encoding: utf-8

def sujet
  @sujet ||= Forum::Sujet.new(site.route.objet_id)
end
