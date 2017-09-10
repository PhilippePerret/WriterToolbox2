# Javascript {#javascript}

## Les méthodes communes

Ces méthodes sont chargées automatiquement, il n'y a donc rien à faire.

* [`DOM(<id>)`](#js_get_dom)
* [Méthode d'attente `isReady`](#js_is_ready)
* [`__notice(<notification>)`](#js_notice)
* [`__error(<message erreur>)`](#js_error)

## `DOM` {#js_get_dom}

Retourne un élément du DOM récupéré par son identifiant.

```js

let elDom = DOM('id_element');

```

> Null si l'élément n'existe pas.


## Méthode d'attente `isReady` {#js_is_ready}

Cette méthode correspond au `$(document).ready()` de jQuery.

```js

isReady(function(){
  ... à faire quand le document est prêt ...
})

```

## `__notice` {#js_notice}

Pour affiche un simple message `Flash`.

```js

__notice("<le message à afficher>");

```


## `__error` {#js_error}

Pour affiche un message d'erreur `Flash`.

```js

__error("<le message d'erreur à afficher>");

```
