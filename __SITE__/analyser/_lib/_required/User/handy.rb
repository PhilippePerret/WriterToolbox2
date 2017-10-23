# encoding: utf-8

# Méthode à invoquer avant la plupart des méthodes (mais pas toutes) pour
# s'assurer que c'est un analyste qui tente de faire l'opération.
# Ou pour le dire autrement : dès qu'il s'agit d'une opération que seul un analyste
# peut faire, il faut commencer par invoquer cette méthode.
def analyste_only
  user.admin?      && return 
  user.identified? || require_identification
  user.analyste?   || raise("Seul un analyste peut effectuer cette opération.")
end
