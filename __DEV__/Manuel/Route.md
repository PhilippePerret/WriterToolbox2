# Routes

Les routes sont calculées dans le module `./lib/site/route.rb`.


## Redirection {#route_redirection}

La redirection est gérée par la méthode global `redirect_to` qui reçoit deux arguments :

```ruby

redirect_to <cible>[, <data message>]

```

* La cible de la redirection. Cf. [Définition de la redirection](#route_redirect_definition),
* Le message optionnel de redirection. Cf. [Définition du message de redirection](#route_redirect_message).

> Note : il s'agit d'une *vraie* redirection, avec rechargement de page.

### Définition de la redirection {#route_redirect_definition}

Il y a deux moyens de définir la redirection (le premier est le meilleur) :

* Par un **Simple string**, avec le path à la section. Par exemple :
  ```
    'home'          Pour rediriger vers l'accueil
    'user/signin'   Pour rediriger vers le formulaire d'identification
    'user/profil/12'  Rediriger vers le profil de l'user #12
  ```
* Par un **Array** comprenant `[objet, method, objet_id]` (à la manière REST). Par exemple :
  ```
    ['home', nil, nil]      # ou simplement ['home']
    # => rejoint l'accueil
    ['user', 'signin', nil] # ou simplement['user', 'signin']
    # => redirige vers le formulaire d'identification (signin)
    ['user', 'profil', 12]
    # => redirige vers le profil de l'user #12
  ```

### Redirection vers dernière page {#route_redirect_last_page}

On peut rediriger vers la dernière page à l'aide de la formule :

```
redirect_to :last_page
```

Ou :

```
redirect_to :last_route
```


> Noter que cette dernière page sera vraiment la page avec tous ses paramètres. Elle est obtenue en appelant la méthode `site.uri` ou son alias `site.full_route`.

### Définition du message de redirection {#route_redirect_message}

Il s'agit du message qui apparaitra sur la page vers laquelle on se redirige. Puisqu'il a rechargement, ce message est mis dans les propriétés de session.

À présent, il suffit d'utiliser les `__notice` et `__error` habituel pour que ces messages soient conservés. On peut tout de même ajouter un message directement en argument de la méthode `redirect_to`

Ce message peut être :

* Un **simple String**. Dans ce cas, c'est considéré comme un message `notice`.
* Un **Array** contenant `[message, type du message]`. Le type peut être `:error` ou `:notice` en fonction du type de message.
  Donc, pour afficher un message d'erreur à l'user après une redirection, il faut faire :

  ```
    redirect_to 'home', ["Mauvais choix, je redirige !", :error]
  ```

Parfois, le message ne peut pas être donné au moment de la redirection.
