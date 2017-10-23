# Utilisateur {#user}

## Identification {#user_identification}

On sait simplement si un user est identifié si son `id` est défini.

Rappel : qu'il soit identifié ou non, le visiteur possède une instance `User` qui permet de simplifier le travail avec lui.

La propriété interrogative `identified?` renvoie le statut du visiteur courant.

```ruby

  user.identified?
  # => Return true si l'user est identifié
  #    False dans le cas contraire.

```

## Options de l'user {#user_options}

```
BIT   OFFSET    DESCRIPTION
1     0         & 1 si administrateur
                & 2 ...? (Marion l'a)
                & 4 si super administrateur
2     1         Grade. Cf. ci-dessous "Grade sur le forum"
3     2         1 si le mail a été confirmé
4     3         1 si l'user a été détruit (mais je crois que pour le
                moment l'user est vraiment détruit)
5     4         Définit comment l'user veut être contacté. Cf. ci-dessous
                la rubrique "Contact de l’user"
6     5         Définit la fréquence de contact (notification)
                0: Aucune notification
                1: Notification quotidienne (défaut)
                2: Notification hebdomadaire
                -----------------
17    16        Niveau d'analyste
                =================
                0: pas analyste
                1: demande de participation non validée
                2: demande de participation refusée ou rejetée
                3: demande de participation acceptée, premier niveau
                # Les autres niveaux ne sont pas encore utilisés
                9: analyse confirmé, a tous les privilèges
                ------------
32    31        1: C'est un icarien
                2: C'est un icarien actif
```

## Variables de l'user {#user_variables}

On peut obtenir les variables de l'user (enregistrées dans `users_tables.variables_<id user>`) à l'aide de :

```ruby
<user>.var[<var name>]
```

On peut les définir par :

```ruby
<user>.var[<var name>] = <valeur>
```

On peut mettre toute valeur scalaire, `String`, `Fixnum`, `Array`, `Hash`, `TrueClass` etc.

> Note : le nom de la variable peut-être passé soit en string (`'variable_name'`) soit en symbol (`:variable_name`).

Par exemple :

```ruby
lecteur.var['derniere_route'] = site.uri
```

```ruby
redirect_to visiteur.var['derniere_route']
```


## Contact de l’user {#user_contact}

Ce contact est défini par le 5e bit d'option de l'user (options[4]).

C'est une valeur en base 26. Donc, pour l'obtenir, on doit faire :

```ruby
val = user.data[:options][4].to_i(26)
```

Valeurs possibles :

```
0     L'auteur ne veut aucun contact
2     L'auteur accepte d'être contacté par l'administration du site
4     L'auteur accepte d'être contacté par d'autres inscrits
8     L'auteur accepte d'être contacté par n'importe qui

  15 => Tout le monde peut le contacter (1+2+4+8)

```

> Note : utiliser `require_lib('user:contact')` pour avoir des méthodes pratiques pour ce niveau de contact.
