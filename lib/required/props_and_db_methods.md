

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


## NOTES {#notes}

### N0001

On serait tenté, dans la méthode `insert`, de faire `@id = site.db.insert(...)`, mais le problème est que pour certaines tables (`tickets` par exemple), l'identifiant n'est pas l'auto-incrément habituel.

Moralité, il faut explicitement spécifier la définition de l'id après l'insertion de la donnée dans la base de données ou mettre le second argument de `insert` à true : `insert(hash_data, true)`.
