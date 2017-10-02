# Forum {#forum}

## Sujets {#forum_sujets}

### Sujets : specs {#forum_sujets_specs}

```

  BIT   OFFSET      DESCRIPTION
  1     0           1= sujet validé, 0= sujet non validé
  2     1           Type du sujet. Cf. « Sujets : type S »
  3-4   2-3         Sujet plus précis (à définir)
  5     4           1= il faut annoncer ce nouveau sujet
                    0= le sujet a été annoncé
  6     5           0= Accessible à tout le monde
                    Autre valeur : correspond au grade que doit avoir l'user
                    pour consulter le sujet en question.

```

### Sujets : type S {#forum_sujets_type_s}

Le `type s` du sujet correspond au 2e bit de ses spécifications (`specs`).

les valeurs possibles sont :

```

  0     Pas de type S
  1     Sujet quelconque
  2     Question technique. Sujet de type Stackoverflow avec meilleures
        réponses présentées en premier.
  9     Non défini

```


## Posts (#forum_posts)

### Options des messages

```

 BIT      OFFSET        DESCRIPTION
 1        0             1= message validé, 0= message non validé

```
