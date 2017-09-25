# Questions de quiz {#quiz_questions}


## Table des questions {#quiz_questions_table}

Version raccourcie pour création effective :

```

CREATE TABLE questions
  (
    id INTEGER AUTO_INCREMENT,
    question VARCHAR(255) NOT NULL,
    reponses BLOB NOT NULL,
    indication TEXT DEFAULT NULL,
    specs VARCHAR(16) DEFAULT '00000000',
    created_at INTEGER(10),
    updated_at INTEGER(10),
    PRIMARY KEY (id)
  );

```


Version complète explicitée :

```

CREATE TABLE questions
  (
    id INTEGER AUTO_INCREMENT,

    question VARCHAR(255) NOT NULL,

    #  GROUPE
    # --------
    # Supprimé : remplacé par le bit 3 du type

    # REPONSES
    # ----------------------
    # Puisqu'il s'agit toujours que de QCM, les réponses sont toujours
    # définies et strictes. La donnée est maintenant une ligne à parser
    # Voir le format dans le programme.
    # Chaque réponse définit sa valeur en points.
    reponses BLOB NOT NULL,


    # INDICATION
    # -----------
    # Une indication optionnelle à ajouter sous la question,
    # en petit, pour aider à faire le choix.
    # Remarquer qu'une indication automatique existe lorsque la question
    # comporte plusieurs choix à cocher (checkbox au lieu de radion).
    indication TEXT,

    #  SPECS
    # -------
    # Spécifications de la question
    # Note : avant, c'était `type`
    #   BIT   OFFSET  DESCRIPTION
    #   1       0     r: un seul choix possible, c: choix multiple
    #                 => donne `type_c` dans le programme
    #   2       1     Type d'affichage l: en ligne, c: en colonne, m: menu
    #                 => produit `type_a` dans le programme
    #   3       2     Groupe de la question, en base 36
    #                 0  non défini
    #                 1  Scénodico
    #                 2  Filmodico
    #                 3  Un an un script
    #                 4  Narration
    specs VARCHAR(16) DEFAULT '00000000',

    #  RAISON
    # --------
    # Pour expliquer la bonne réponse si nécessaire
    # OBSOLÈTE : ça se trouve dans la description des réponses.

    # CREATED_AT
    # ----------
    # Timestamp de la création du projet
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Timestamp de la modification de cette donnée
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );

```
