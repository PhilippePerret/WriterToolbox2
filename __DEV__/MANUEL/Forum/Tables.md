# Tables pour le forum

* [posts](#forum_table_posts)
* [posts_content](#forum_table_posts_content)
* [posts_votes](#forum_table_posts_vote)
* [users](#forum_table_users)
* [follows](#forum_table_follows)


## Table `posts` {#forum_table_posts}

Contient les informations générales des messages, c'est-à-dire tout sauf le texte lui-même et les votes sur le message.

Version courte de la table :

```

CREATE TABLE posts
(
  id          INTEGER     AUTO_INCREMENT,
  user_id     INTEGER     NOT NULL,
  sujet_id    INTEGER     NOT NULL,
  parent_id INTEGER,
  options VARCHAR(16) DEFAULT '00000000',
  valided_by  INTEGER,
  modified_by INTEGER,
  created_at  INTEGER(10) NOT NULL,
  updated_at  INTEGER(10),
  PRIMARY KEY (id)
);


```

Version détaillée de la table :

```

CREATE TABLE posts
(
  id          INTEGER     AUTO_INCREMENT,
  user_id     INTEGER     NOT NULL,
  sujet_id    INTEGER     NOT NULL,
  created_at  INTEGER(10) NOT NULL,
  updated_at  INTEGER(10),

  # PARENT_ID
  # ---------
  # Identifiant du message parent, si ce message est
  # une réponse à un message. Cette donnée est définie à partir
  # du moment où on choisit « Répondre ».
  parent_id INTEGER,

  # OPTIONS
  # -------
  # Cf. le fichier Posts.md
  options VARCHAR(16) DEFAULT '00000000',

  # VALIDED_BY
  # ----------
  # Identifiant du modérateur ayant validé le message. Nécessaire
  # seulement si l'auteur du message n'est pas abilité à écrire des
  # message non validé.
  valided_by INTEGER,

  # MODIFIED_BY
  # -----------
  # Identifiant du modérateur ayant modifié le
  # message s'il a eu besoin d'être modifié
  modified_by INTEGER,

  PRIMARY KEY (id)
);

```

## Table `users` {#forum_table_users}

Cette table contient toutes les informations concernant les users dans le forum. Elle permet notamment de connaitre le nombre de messages envoyés ou la réputation.

Version simplifiée (pour la création) :

```
DROP TABLE IF EXISTS users;
CREATE TABLE users
  (
    id INTEGER,
    options VARCHAR(16),
    count INTEGER(8),
    upvotes INTEGER(8) DEFAULT 0,
    downvotes INTEGER(8) DEFAULT 0,
    last_post_id INTEGER DEFAULT NULL,
    PRIMARY KEY (id)
  );
```


Version explicitée :

```

CREATE TABLE users
  (
    #  ID
    # ---
    # Identifiant de l'user, le même que celui dans la table users
    # générale.
    id INTEGER,

    #  OPTIONS
    # ---------
    # Options forum pour le user, détermine par exemple s'il
    # veut être averti de nouveaux messages.
    options VARCHAR(16) DEFAULT '00000000',

    #  LAST_POST_ID
    # --------------
    # ID du dernier message
    last_post_id INTEGER DEFAULT NULL,

    #  COUNT
    # -------
    # Nombre de messages sur le forum
    count INTEGER(8) DEFAULT 0,

    #  UPVOTES
    # ---------
    # Nombre de votes positifs en sa faveur.
    upvotes INTEGER (8) DEFAULT 0,

    #  DOWNVOTES
    # -----------
    # Nombre de votes négatifs en sa défaveur.
    downvotes INTEGER (8) DEFAULT 0,

    PRIMARY KEY (id)
  );

```

## Table des suivis `follows` {#forum_table_follows}

Permet de savoir qui suit quel sujet. La table a été simplifiée par rapport à l'autre version. Maintenant, on a juste besoin de connaitre l'association sujet<->user concernée et savoir depuis quand elle existe.

```
DROP TABLE IF EXISTS follows;
CREATE TABLE follows
(
  user_id INTEGER,
  sujet_id INTEGER,
  created_at INTEGER(10),
  INDEX idx_user  (user_id),
  INDEX idx_sujet (sujet_id)
);
```
