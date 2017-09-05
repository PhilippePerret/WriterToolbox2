
# Pour "charger" une route, c'est-à-dire, en test unitaire, pour
# charger tous les éléments qui seraient chargés si on appelait
# cette route sur le site.
# Notamment, charge tout le dossier "<objet>/_lib/_required/" s'il
# existe.
def load_route route
  objet,method,objet_id = route.split('/')
  param({__o: objet, __m: method, __i: objet_id})
  site.route.load
end
