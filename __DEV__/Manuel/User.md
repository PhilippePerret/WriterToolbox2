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
1     0         1 si administrateur
2     1         Grade sur le forum. Cf. ci-dessous "Grade sur le forum"
3     2         1 si le mail a été confirmé
4     3         1 si l'user a été détruit (mais je crois que pour le
                moment l'user est vraiment détruit)
5     4         Définit comment l'user veut être contacté. Cf. ci-dessous
                la rubrique "Contact de l’user"
32    31        1: C'est un icarien
                2: C'est un icarien actif
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
