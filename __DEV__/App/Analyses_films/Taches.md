# Tâches dans les analyses {#analyses_taches}

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
