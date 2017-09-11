
* [Pré-requis](#prerequise)
* [Toutes les méthodes](#toutes_les_methodes)
  * [`data`](#data_method)
  * [`get`](#get_method)
  * [`set`](#set_method)
  * [`insert`]{#insert_db_method}
  * [`update`]{#update_db_method}


## Pré-requis {#prerequise}

Pour pouvoir fonctionner, la classe incluant ces méthodes doit définir la base et la table à l'aide de :

```ruby

def base_n_table ; @base_n_table ||= [<base>, <table>] end

```

La plupart des tables doivent posséder les colonnes `created_at` et `updated_at` avec en type `INTEGER(10)`. Ces colonnes sont définies de façon automatique, il est inutile de les définir dans le code.

Si, cependant, des tables n'avaient pas ces colonnes, il suffit de le préciser en envoyant une propriété supplémentaire `__strict` à true.

Par exemple :

```ruby

site.db.insert(ma_base, ma_table, {
  colonne1: "valeur 1"
  colonne2: "valeur 2",
  colonne3: "valeur 3",
  __strict: true # empêche d'ajouter created_at et updated_at
  })
  
```



## Toutes les méthodes {#toutes_les_methodes}

### `data` method {#data_method}

Syntaxe :

```ruby

data[<key>]

```

Noter que pour faire appel à cette méthode, dans l'utilisation courante, il faut absolument que l'identifiant soit fourni, sinon, silencieusement, la méthode retourne toujours un `Hash` vide.


### `get` method {#get_method}

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

## `set <key>, <value>` {#set_method}


### `insert` {#insert_db_method}

Insert les données pour la première fois dans la table, retourne l'identifiant affecté et dispatche toute les données.

```ruby

insert(<hash data>[, <set_id>])

```

Mettre `set_id` à false si on ne veut pas que l'`@id` soit affecté (voir la [note 0001](#db_note_1)).


### `update` {#update_db_method}

Actualise les données de l'enregistrement et les dispatche dans l'instance.

```ruby

udpate(<hash data>)

```


## NOTES {#notes}

### N0001 {#db_note_1}

On serait tenté, dans la méthode `insert`, de faire `@id = site.db.insert(...)`, mais le problème est que pour certaines tables (`tickets` par exemple), l'identifiant n'est pas l'auto-incrément habituel.

Moralité, il faut explicitement spécifier la définition de l'id après l'insertion de la donnée dans la base de données ou mettre le second argument de `insert` à true : `insert(hash_data, true)`.
