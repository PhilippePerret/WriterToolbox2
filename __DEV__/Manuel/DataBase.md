# Bases de données {#databases}

## Méthode principales {#db_main_methodes}

Les deux méthodes principales à connaitre pour se servir des bases de données dans le site sont :

* `site.db.use_database(<db name>)`. Cette méthode permet de choisir une base de données à utiliser. On peut utiliser aussi `site.db.use_db(...)`.

* `site.db.execute(<requete(s)>)`. Pour exécuter la ou les requêtes spécifiées en argument.

* `site.db.insert(db_name, db_table, hash_data)`. Pour insérer des données. cf. [Insertion de données](#db_insertion_data)

* `site.db.select(<db_name>, <db_table>[, <where_clause>[, <colonnes>]])`. Retourne les rangées voulues. C'est **toujours** une liste qui est retournée, même lorsqu'on ne demande qu'une seule valeur. Cf. [Sélection de données (`site.db.select`)](#db_select_data).

* `site.db.update(db_name, db_table, hash_data, where_clause)`. Pour actualiser une donnée. cf. [Actualisation de données](#db_update_data)

* `site.db.count(db_name, db_table)`. Retourne le nombre de rangée dans `<db_name>.<db_table`.

## Toutes les formes de requêtes possible (pour rappel rapide) {#db_quick_help}

```ruby

  site.db.use_database 'ma_base'
  site.db.use_db 'ma_base'

  # Requête non préparée
  site.db.execute(<request unique avec valeurs>)

  # Requêtes préparées
  site.db.execute(<request avec ?>, [valeurs])

  site.db.execute(<request avec ?>, [[valeurs],[valeurs2]...])

  # Liste de requêtes
  site.db.execute([ request1, request2, ... ])
  # Note : request1, request2 peuvent être des requêtes simples (String)
  #        ou des requêtes préparées (Array de deux éléments : la requête
  #        et les valeurs)

```


## Détail des requêtes envoyées à `site.db.execute`

La méthode `site.db.execute` peut recevoir une simple requête :

```ruby

site.db.execute("SELECT * FROM tickets WHERE id = '1245ffd4d5s7q'")

```

… ou une liste de requêtes :

```ruby

site.db.execute([
  "INSERT INTO table SET col=valeur, col2=valeur2;", # (1)
  ["SELECT FROM table2 WHERE id = ?", [12]]          # (2)
  ])

```

La requête précédente présente les deux formes possibles de requête :

* **(1)** Forme simple, avec les valeurs dans la requête. Il vaut mieux utiliser la forme suivante.
* **(2)** Forme préparée, avec en premier argument de la liste la requête et en second argument la liste des valeurs qui doivent être utilisées. Cette forme est à privilégier, elle est plus sécurisée et elle simplifie les opérations.

On peut même utiliser la seconde forme pour traiter plusieurs valeurs en même temps :

```ruby

  request = "INSERT INTO TABLE SET col1 = ?, col2 = ?, col3 = ?, created_at = ?"
  values  = [
    ["Marc", "Bretonneau",  12, Time.now],
    ["Marion", "Michel",    25, Time.now],
    ["Phil", "Perret",      53, Time.now]
  ]
  site.db.execute(request, values)

```

> Note : cf. aussi [la méthode `site.db.insert`](#db_insertion_data)
Les trois champs seront créés avec la même requête préparée.

## Insertion de données {#db_insertion_data}

```ruby

site.db.insert( db_name, db_table, hash_data )

```

Par exemple :

```ruby

  site.db.insert(:hot, 'tickets', {
    id:       "12fd3s2q1df2dsq",
    user_id:  12,
    code:     "User.get(12).accept"
  })

```

Noter que `hash_data` n'a pas besoin de définir `created_at` puisque cette colonne sera toujours créée, ainsi que la colonne `updated_at`.

> Note : moralité, toutes les tables doivent définir ces deux colonnes.

Pour obtenir l'ID de la rangée créée, on peut faire :

```ruby

  last_id = site.db.last_id_of(:hot[, <nom de la table>])

```

## Sélection de données (`site.db.select`) {#db_select_data}

Syntaxe :

```ruby

site.db.select(<db name>, <db table name>, <where clause>[, <colonnes>])

```

Par exemples :

```ruby

admins = site.db.select(:hot, 'users', "SUBSTRING(options,1,1) = 7 ", '*')

user12 = site.db.select(:hot, 'users', {id: 12}, ['pseudo','mail'])

users = site.db.select(:hot, 'users')
# <= Pas de clause where et pas de colonnes
# => Pas de clause where et toutes les colonnes retournées

```

* `<db name>` correspond au suffixe, auquel sera ajouté le préfixe défini dans la configuration du site. Si le préfixe est `boite-a-outil` et que db_name est `:hot`, alors la base atteinte sera `boite-a-outils_hot`.
* La **clause where** peut être définie de deux façons : soit par un string explicite, soit par un hash. Cf. [ci-dessous](#db_clause_where_definition).
* La liste des colonnes peut être donnée en String de façon explicite (`"*"` ou `"col1, col2"`) ou par `Array` (`[col1, col2, col3]`).
* La méthode retourne la liste des `Hash` des données de chaque rangée trouvée.


## Actualisation de données (`site.db.update`) {#db_update_data}

Syntaxe :

```ruby

site.db.update(<db name>, <db table name>, <new data>, <where clause>)

```

Exemple :

```ruby

site.db.update(:hot, 'users', {options: '0001000'}, {id: 12})
# => Actualise la rangée #12 en mettant :
#         options       à  0001000
#         created_at    à  Maintenant

```

Noter que :

* `<db name>` correspond au suffixe, auquel sera ajouté le préfixe défini dans la configuration du site. Si le préfixe est `boite-a-outil` et que db_name est `:hot`, alors la base atteinte sera `boite-a-outils_hot`.
* La méthode ajoute automatiquement la propriété `created_at`. Il est donc inutile de la préciser et il faut qu'elle existe.
* La **clause where** peut être définie de deux façons : soit par un string explicite, soit par un hash. Cf. [ci-dessous](#db_clause_where_definition).


## Définition d'une clause WHERE {#db_clause_where_definition}

Que ce soit pour la méthode `update` ou `select` (et toutes les méthodes utilisant la clause WHERE), cette clause where peut être définie de deux façons :

* Par un string explicite. Par exemple `id = 12` ou `id = 12 OR id = 15`.
* Par un hash de données. Par exemple `{mail: 'mon-mail', text: '%ça%'}`. Dans le cas d'un hash, c'est `AND` qui sera utilisé, jamais `OR`.

## Retour des requêtes {#retour_db_requests}

Si un résultat est produit par mySQL, il est renvoyé dans un `Array`.
