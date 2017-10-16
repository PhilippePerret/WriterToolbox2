# Analystes

## Films analysés par l'analyste

On peut savoir qui fait les analyses grâce à la table `user_per_analyse` :

```sql

CREATE TABLE user_per_analyse (
    user_id     INTEGER,
    film_id     INTEGER,
    role        INTEGER(3),
    created_at  INTEGER(10),
    updated_at  INTEGER(10),
    PRIMARY KEY (user_id, film_id)
    );

```


Version explicitée :

```sql

CREATE TABLE user_per_analyse (

    #  USER_ID
    # ---------
    # Identifiant de l’user qui procède à l’analyse. Ce doit être
    # un analyste accepté, donc qui a déposé une demande.
    # Ensuite, il s’engage dans une analyse ou la crée.
    user_id     INTEGER,

    #  FILM_ID
    # ---------
    # Identifiant du film dans la table films_analyses et la table filmodico
    # Film dont s’occupe l’user user_id
    film_id     INTEGER,

    #  ROLE
    # ------
    # Rôle que joue l’user dans ce film. C’est une valeur décimale sur 3 entiers
    # de 0 à 511 donc avec 9 bits possibles
    # 1:    L’user est le créateur de l’analyste, l’initiateur
    # 2:    L’user est le co-créateur
    # 4:    L’user n’est plus actif sur cette analyse, mais il y a participé.
    # 8:
    # 16:   L’user peut modifier des fichiers de cette analyse dont il n’est
    #       pas l’auteur.
    # 32:
    # 64:   L’user peut détruire n’importe quel fichier de cette analyse
    # 128:  L’user peut modifier les données générales de l’analyse.
    # 256:  L’user peut détruire l’analyse
    role        INTEGER(3),

    #  CREATED_AT
    # ------------
    # Date à laquelle l’user s’est investie dans cette analyse
    #
    created_at  INTEGER(10),

    #  UPDATED_AT
    # ------------
    # Date de dernière modification, normalement, seulement le rôle peut être
    # modifié.
    updated_at  INTEGER(10),

    PRIMARY KEY (user_id, film_id)
    );

```


## Fichiers produits par l'analyste

Cf. le fichier App > Analyses_films > Fichiers > Database.md
