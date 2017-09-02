# Messages



* `__notice(<message>)` permet d'afficher un message
* `__error(<message>)` permet d'afficher un message d'erreur dans la page
* [Messages d'annonce sur la page d'accueil](#messages_on_home_page)

> Note : ces méthodes sont des raccourcs vers les méthodes de `site.flash` : `notice` et `error`.

## Messages d'erreurs (méthode `__error`) {#messages_erreurs}

Elle reçoit un argument qui peut être :

* Une simple message d'erreur,
* Une instance d'erreur (on écrira le message et on enverra le backtrace dans le débug — et donc un fichier),
* Une liste de messages (chacun fera l'objet d'un div).


## Messages de debug {#debug_messages}

On peut faire des messages de débug grâce à la méthode `debug`.

Elle reçoit un argument qui peut être :

* Une message simple
* Une erreur (on écrira le message et le backtrace)
* Une liste de messages (chacun fera l'objet d'une ligne)


## Messages d'annonce sur la page d'accueil {#messages_on_home_page}

Pour laisser un message d'annonce sur la page d'accueil, il suffit de faire un message d'actualité avec les options bien réglées.

```ruby

require './lib/utils/updates'
Updates.add({
  message: "<le message>",
  route: 'la/route/eventuelle',
  type: '<le type>', # {String} cf. ./lib/utils/updates.rb
  options: '10000000'
})

```

Pour les options, pour le moment, seul le premier bit est utilisé. S'il est > à 0, l'update est annoncée en page d'accueil.

```

    BIT 1
      0     Pas d'annonce
      1     Annonce aux inscrits
      2     Annonce aux abonnés
      3     Annonce aux auteurs UNAN
      4     Annonce aux analystes

```
