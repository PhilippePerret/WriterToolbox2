# Tâches dans les analyses {#analyses_taches}

## Spécifications de la tâche

`specs`, sur 32 caractères

```

  BITS   OFFSETS    DESCRIPTION
 ------------------------------------------------------------------
  1      0          ÉTAT (STATE) DE LA TACHE
                    ========================
                    0: Non prise en main
                    1: Prise en main par l'user_id
                    ...
                    9: Tâche terminée

  2      1          TYPES DE LA TÂCHE
                    =================
                    Non encore définie, mais pourra concerner une tâche sur un
                    fichier, une annonce à faire, un travail dans un fichier,
                    un mail à envoyer, etc.

```


## Table MySQL

```SQL

CREATE TABLE taches_analyses
(
  id          INTEGER AUTO_INCREMENT,
  film_id     INTEGER NOT NULL,
  action      VARCHAR(255) NOT NULL,
  echeance    INT(10),
  user_id     INTEGER,
  file_id     INTEGER,
  specs       VARCHAR(32) DEFAULT '00000000',
  created_at  INTEGER(10) NOT NULL,
  updated_at  INTEGER(10) NOT NULL,
  PRIMARY KEY (id),
  INDEX     (film_id)
);
```
