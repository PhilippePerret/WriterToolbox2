# Tables

Ce fichier détaille le contenu de toutes les tables utiles au programme.

## Tables `users_tables.unan_works_<id auteur>`

```

(
  # ID
  # --
  # IDentifiant unique et universel d'un travail d'un
  # auteur du programme ÉCRIRE UN FILM/ROMAN EN UN AN
  # Noter que cet identifiant n'est plus le même que l'id
  # du travail absolu auquel il est associé (le même travail
  # absolu peut avoir plusieurs works auteur)
  id INTEGER AUTO_INCREMENT,

  # PROGRAM_ID
  # ----------
  # Le programme dans lequel est travaillé ce work
  # Noter que si l'auteur suit plusieurs programmes, tous
  # ses works seront enregistrés dans cette table, donc
  # cet identifiant doit être utilisé dans la recherche
  # select
  program_id INTEGER NOT NULL,

  # ABS_WORK_ID
  # -----------
  # Identifiant absolu du work associé à ce travail
  abs_work_id INTEGER NOT NULL,

  # ABS_PDAY
  # --------
  # Indice du jour-programme de ce travail. Car le
  # même travail absolu peut donner lieu à plusieurs
  # travaux dans plusieurs jours-programme différents.
  # C'est le PDay du jour où ce travail aurait dû être
  # commencé, même s'il a été "démarré" le lendemain.
  abs_pday INTEGER(4) NOT NULL,

  #  ITEM_ID
  # ---------
  # Identifiant d'un élément quelconque qui peut être associé
  # à ce travail. Inauguré par exemple pour les quiz, pour mémoriser
  # l'identifiant de la rangée des résultats du quiz dans la table
  # des quiz de l'auteur.
  item_id INTEGER,

  # STATUS
  # ------
  # État du travail
  # Nombre de 0 à 9.
  status INTEGER(1) DEFAULT 0,

  # OPTIONS
  # -------
  # Cf. le document Program > Works.md du RefBook
  # BIT 1-2 Type du travail
  #         Pour ne pas avoir à charger le travail absolu
  #         pour connaitre le type du travail.
  options VARCHAR(32) DEFAULT '',

  # POINTS
  # ------
  # Nombre de points gagnés sur ce travail, en sachant qu'il
  # peut fluctuer, comme dans les quiz
  points INTEGER(3) DEFAULT 0,

  # ENDED_AT
  # --------
  # Date de fin du travail courant
  ended_at INTEGER(10),

  # UPDATED_AT
  # ----------
  updated_at INTEGER(10),

  # CREATED_AT
  # ----------
  # Date de création de la donnée
  # C'est sur cette date qu'on peut jouer pour programme un
  # travail pour l'avenir.
  created_at INTEGER(10) NOT NULL,

  PRIMARY KEY (id)
);


```
