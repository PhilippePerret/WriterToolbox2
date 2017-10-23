# Analystes

## Donnée générale

Rappel : avant tout, un user est considéré comme “analyste” lorsque le 17ème bit de son `options` (`options[16]`) général est au moins 3 (analyste accepté). C'est la première donnée qui est vérifiée pour s'assurer qu'un user est analyste.

## Administrateurs du site

Par défaut, tous les administrateurs du site sont des analystes et ont tout pouvoir sur les analystes.

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

    --  ROLE
    -- ------
    -- Rôle que joue l’user dans ce film. C’est une valeur décimale sur 3 entiers
    -- Le créateur a le rôle 1|32|64|128|256
    -- Un co-créateur :      1|16|64|128
    -- Un contributeur :     1|8
    -- Un correcteur  :      1|4
    -- Un administrateur, par exemple lorsqu'il soumet un fichier, devient :
    -- 1|64|128|256
    -- de 0 à 511 donc avec 9 bits possibles
    -- Noter qu’on peut modifier à l'occasion un user, par exemple pour lui
    -- donner le droit de détruire l'analyse.
    -- 1:    L’user est actif (si 0: inactif mais a participé)
    -- 2:    

    -- 4:    L’user est CORRECTEUR (si 4 ou 1|4 => seulement correcteur)
    -- 8:    L’user est RÉDACTEUR OCCASIONNEL
    -- 16:   L’user est CO-CREATEUR
    -- 32:   L’user est le CRÉATEUR de l’analyste, l’initiateur

    -- 64:   L’user peut détruire n’importe quel fichier de cette analyse
    -- 128:  L’user peut modifier les données générales de l’analyse.
    -- 256:  L’user peut détruire l’analyse ou supprimer des analystes
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
