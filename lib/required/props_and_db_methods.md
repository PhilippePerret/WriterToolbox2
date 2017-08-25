

### `get` method

Syntaxe :

```ruby

get <key or keys>

```

Récupère des données soit dans l'instance si elles sont déjà défines soit dans la base de données.

Si l'argument est une clé seule (en `String` ou `Symbol`) alors la méthode renvoie seulement sa valeur.

```ruby

  user.get(:pseudo) # => retourne seulement le pseudo

```

Si l'argument une liste de clés, alors la méthode renvoie un `Hash` contenant les clés en clés et les valeurs en valeurs.

```ruby

  data = user.get([:pseudo, :mail, :session_id])
  # => {pseudo: "Ernest", mail: 'mailernest@chez.lui', session_id: nil}

  __notice "Bonjour #{data[:pseudo]}"

```
