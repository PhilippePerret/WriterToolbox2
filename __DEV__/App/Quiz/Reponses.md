# Réponses aux quiz {#quiz_reponses}

Les réponses aux quiz sont enregistrées dans une table propre à l'user dans la base `:users_tables`.

La table pour un user donné est :

    users_tables.quiz_<id user>

Par exemple :

    users_tables.quiz_236

## Propriété `@resultats`

La propriété `Quiz@resultats` contient les résultats qui peuvent être réaffichés.

Cette propriété existe :

* lorsqu'on procède à la soumission d'un formulaire, qu'il soit valide ou non (toutes les questions répondues ou non),
* lorsqu'on recharge les résultats à un quiz enregistré.

Format de cette table :

```ruby

  {
    quiz_id:    <id du quiz>,
    owner_id:   <id du propriétaire du quiz>,
    reponses: {
      <id question>: [valeurs choisies], # (*)
      <id question>: [valeurs choisies],
      ...
      <id question>: [valeurs choisies]
    }
  }

```

(*) C'est-à-dire les index des réponses choisies, qu'elles soient dans le désordre ou non.


## Format des données de résultat {#quiz_reponses_format}

Chaque ligne des résultats concerne une question.

```

    <question id>:<liste réponses>:<nombre points>:<nombre points max>

```

Avec :

```

    <question id>

        Identifiant unique de la question dans la table `quiz.questions`.

    <liste réponses>

        La liste des réponses choisies. C'est une liste même lorsqu'un seul choix
        est possible (pour ne pas avoir à checker chaque fois). C'est une liste
        d'index de réponse séparés par des espaces.

    <nombre points>

        Nombre de points marqués par l'user sur cette question.

    <nombre points max>

        Nombre de points maximum qu'on pouvait marquer sur cette question.
        Ça n'est pas seulement pour mémoire, c'est aussi parce que les questions
        peuvent être éditées et ce nombre peut changer avec le temps.

```



## Table SQL des résultats {#quiz_reponses_table}

Par défaut, on suppose qu'un même utilisateur peut répondre plusieurs fois au même formulaire. Donc, l'identifiant est unique et ne correspond pas à l'identifiant du Quiz. C'est la propriété `quiz_id` qui définit le quiz.

Format réduit de la table MySQL des résultats :

```

CREATE TABLE quiz___USER_ID__
  (
    id INTEGER AUTO_INCREMENT,
    user_id INTEGER,
    quiz_id INTEGER NOT NULL,
    reponses BLOB NOT NULL,
    note INTEGER(3) NOT NULL,
    points INTEGER(4) NOT NULL,
    options VARCHAR(8) DEFAULT '00000000',
    updated_at INTEGER(10),
    created_at INTEGER(10),
    PRIMARY KEY (id)
  );


```

Format complet explicité :

```

CREATE TABLE quiz_<id user>
  (
    id INTEGER AUTO_INCREMENT,

    # USER_ID
    # -------
    # User, si identifié, qui a rempli ce questionnaire
    # On pourrait aussi le retrouver par le nom de la table.
    user_id INTEGER,

    #  QUIZ_ID
    # ---------
    # Identifiant du quiz
    quiz_id INTEGER NOT NULL,

    # REPONSES
    # --------
    # Réponses du visiteur, c'est un hash en string contenant
    # les réponses (format JSON).
    reponses BLOB NOT NULL,

    #  NOTE
    # ------
    # La note obtenue (sur 20)
    # NOTE : on la multiplie par 10 pour l'enregistrer, c'est une note
    # qui contient une décimale.
    note INTEGER(3) NOT NULL,

    # POINTS
    # ------
    # Nombre de points marqué pour ce questionnaire, pour éviter
    # d'avoir à les recalculer.
    points INTEGER(4) NOT NULL,

    # OPTIONS
    # -------
    # Options
    # Inutilisées pour le moment. Ça pourra servir par exemple
    # pour savoir si on peut afficher ou annoncer le résultat de
    # ce test.
    options VARCHAR(8) DEFAULT '00000000',

    # UPDATED_AT
    # ----------
    # Pour pouvoir être compatible avec les méthodes PropsAndDbMethods
    updated_at INTEGER(10),

    # CREATED_AT
    # ----------
    # Timestamp de la création du projet
    created_at INTEGER(10),

    PRIMARY KEY (id)
  );


```
