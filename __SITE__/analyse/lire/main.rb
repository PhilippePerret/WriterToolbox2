# encoding: utf-8
def film
  @film ||= Analyse::Film.new(site.route.objet_id)
end
