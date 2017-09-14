# Module `MainSectionMethods`

Emplacement : `./lib/required/main_section_methods.rb`

Chargement : par défaut

Inclusion dans une class : `include MainSectionMethods`

Ce module contient un minimum de méthode qui peuvent être utiles pour les sections principales.

Les exemples ci-dessous sont donnés par rapport à une section qui se trouverait à :

```

./__SITE__/ma_section/

```

… et qui définirait la classe `MaSection`.

## Inclusion des méthodes {#msm_inclusion}

On inclut ses méthodes par :

```ruby

class MaSection

  extend MainSectionMethods

end

```

> Noter que ce module est toujours inclus donc on a juste besoin de l'étendre dans la classe pour pouvoir l'utiliser.

## Liste des méthodes {#msm_liste_methodes}

* [`require_module(<module>)`](#msm_require_module)


### `require_module(<module>)` {#msm_require_module}

Permet de requérir un module qui doit obligatoirement se trouver dans le dossier :

```

  ./__SITE__/ma_section/_lib/_not_required/module/

```

**Noter que pour le moment, on ne peut utiliser cette méthode que lorsque la route principale (et notamment `objet`) est celle de l'objet. Car pour trouver le path du module, la méthode se sert de `site.route.objet`.**

Noter également que cette méthode utilise `site.load_folder` qui permet de charger tous les éléments, même les fichiers CSS et Javascript.
