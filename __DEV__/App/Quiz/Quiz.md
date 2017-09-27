# Les quiz {#quiz_quiz}

## Réaffichage des résultats {#quiz_quiz_resultats}

Lorsque des résultats existent, soit parce que l'user vient de soumettre le quiz soit parce qu'ils ont été enregistrés, le questionnaire les affiche à nouveau.

Cela est possible grâce au code `ERB` qui est contenu dans le code `output` du quiz, et qui permet de définir dynamiquement la classe des réponses, questions, etc.

Pour ce faire, la méthode `Quiz#output` charge soit le module `unfilled` — qui laisse le quiz vierge — soit le module `filled` qui va renseigner les méthodes en fonction du résultat.

### Fonctionnement général

Par exemple, le `LI` d'une question est défini ainsi :

```html

<li id="question-12" class="question <%= quiz.li_class(12) %>">
  ...
</li>

```

Dans le module `filled_quiz`, la méthode `Quiz#li_class` reçoit l'identifiant de la question et vérifie les réponses dans `Quiz@resultats`. Si les réponses sont justes, elle retourne la classe `bonnequestion` (ou équivalent), si les réponses sont mauvaises, elle retourne la classe `badquestion`.

## Table de base de données {#quiz_quiz_table}

Version réduite (pour création effective) :

```

CREATE TABLE quiz
  (
    id INTEGER AUTO_INCREMENT,
    titre VARCHAR(200) NOT NULL,
    specs VARCHAR(32),
    questions_ids VARCHAR(255),
    output BLOB,
    description TEXT,
    created_at INTEGER(10),
    updated_at INTEGER(10),
    PRIMARY KEY (id)
  );

```

Version complète :

```

CREATE TABLE quiz
  (
    id INTEGER AUTO_INCREMENT,

    #  TITRE
    # -------
    # Le titre unique du questionnaire qui va le caractériser.
    titre VARCHAR(200) NOT NULL,

    #  GROUPE
    # --------
    # OBSOLÈTE - VOIR LE BIT 3 ([2]) DE `SPECS`

    #  SPECS
    # -------
    # Spécification du quiz. Remplace GROUPE et TYPE
    #   BIT     OFFSET        DESCRIPTION
    #   1       0             Type du quiz, simple quiz, sondage, etc.
    #                         Cf. la table Quiz::TYPES
    #   2       1             Inusité
    #   3       2             Ancien groupe.
    #                         Note : on le met en 3 pour que ça corresponde au
    #                         bit des questions
    #   9       8             1 si quiz courant
    #   10      9             1 : question dans un ordre aléatoire
    #   11-13   10-12         Nombre max de questions (0 si toutes). N'a de sens
    #                         que si les questions sont dans un ordre aléatoire.
    #   14      13            Obsolète
    #   15      14            Bit qui détermine la réusabilité et l'enregistrement
    #                         des résultats :
    #                         Bit 1     1 : réutilisable. Le user peut le faire
    #                                       autant de fois qu'il veut.
    #                                   0 : ce questionnaire ne se fait qu'une
    #                                       fois.
    #                         Bit 2     1 : Ne pas enregistrer les résultats
    #                                   0 : enregistrer les résultats
    #                         Bit 4     Non utilisé
    #                         Donc, si valeur égale… alors :
    #                           0   Une seule fois, résultats sauvés
    #                           1   Réutilisable, résultats sauvés
    #                           2   Une seule fois, pas de résultats sauvés
    #                           3   Réutilisable, résultats non sauvés
    #                         
    specs VARCHAR(32),

    #  TYPE
    # ------
    # OBSOLÈTE

    # QUESTIONS_IDS
    # -------------
    # IDS des questions telles que définies dans la table questions
    # Un QUIZ est un ensemble de questions
    questions_ids VARCHAR(255),

    #  OUTPUT
    # --------
    # Pour ne pas avoir à le reconstruire chaque fois, on enregistre le
    # code du questionnaire dans cette variable.
    # Dans la version 2.0 du BOA, on laisse des variables ERB qui permettent
    # de régler les valeurs, sans passer par javascript.
    output BLOB,

    #  OPTIONS
    # ---------
    # OBSOLÈTE : Voir SPECS

    # DESCRIPTION
    # -----------
    # Description pour l'utilisateur
    description TEXT,

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
