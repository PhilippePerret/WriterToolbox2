# Protection {#protection}

Ce document traite de tout ce qui concerne la protection du site, pour empêcher d'aller dans certaines parties, etc.

## Identification nécessaire

Lorsqu'une page nécessite l'identification du visiteur (par exemple pour savoir s'il est administrateur), on utilise cette simple méthode.

```ruby
user.identified? || identification_required[(<message>)]
```

> Noter que le programme n'ira pas plus loin puisque la méthode procède à une redirection réelle du visiteur vers le formulaire d'identification, avec mémorisation de l'URL demandée.

Le message est facultatif. S'il est absent un message type sera affiché, demandant à l'user de s'identifier pour rejoindre la page demandée.

### Protéger un module de vue {#protection_module_vue}

Pour protéger un module qui se charge automatiquement lors de l'appel d'une vue (par exemple avec la méthode `partial`), on utilise la même erreur que pour [protéger une vue](#protection_vue) :

```ruby

<condition> && raise(NotAccessibleViewError.new(<raison>))


```

### Protéger une vue {#protection_vue}

On peut protéger les fichiers `.erb` en utilisant l'erreur `NotAccessibleViewError`.

Par exemple, sur le forum, on ne peut pas forcer l'adresse `forum/sujet/new` pour atteindre le formulaire de création d'un sujet si on n'est pas au moins inscrit sur le site. Pour le faire, on trouve en haut de la vue :

```ruby

  if user.grade < 1
    raise NotAccessibleViewError.new("Vous ne pouvez pas atteindre cette vue.")
  end

```

Cette erreur est gérée par le module.
