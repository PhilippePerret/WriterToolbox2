# Fichiers d'analyse

Dans la nouvelle version du site (2.0), chaque fichier d'analyse fait maintenant l'objet d'un enregistrement dans la base de données.

Plus exactement, il y a deux enregistrements :

* Un enregistrement dans la table `files_analyses`, avec les informations sur le fichier,
* Un enregistrement dans la table `user_per_file_analyse` avec les informations sur le créateur du fichier. Cette table tient à jour les relations « many-many » entre les fichiers et les utilisateurs, en définissant leur rôle.

## Spécifications du fichiers

Ces spécifications sont renseignées dans la propriété `specs` du fichier dans la table `files_analyses`. C'est un varchar de 16 caractères.

```

  BITS      OFFSETS           DESCRIPTION
 -------------------------------------------------------------------------
  1         0                 1: Le fichier est lisible par tous, il est
                                 terminé et il a été dupliqué dans la partie
                                 "analyse" du site.

  2         1                 Le type du fichier
                              -------------------
                              0:  Simple texte (markdown)
                              1:  Fichier de collecte (.film)
                              2:  Fichier de personnages (.persos)
                              3:  Fichier de brins (.brins)
                              4:  Fichier de structure (.stt)
                              5:  Fichier évènemencier (.evc)
                              6:  Fichier de procédés (.prc)
                              9:  Autre fichier

  3         2                 État du fichier
                              ---------------
                              0:  Il vient d'être initié (il n'existe pas encore
                                  physiquement).
                              1:  En cours de rédaction/d'élaboration/réécriture
                              2:  En cours d'achèvement
                              3:  En attente de corrections
                              4:  En cours de correction
                              9 : achevé

  4         3                 Chantier visible
                              ----------------
                              1: Le fichier est visible bien qu'il soit encore
                              en chantier, par n'importe qui à partir du moment
                              ou ce n'importe qui est inscrit sur le site.
                              0: Seuls peuvent voir ce fichier les contributeurs
                              à l'analyse auquel il appartient.
```

## Définition des tables


```sql

CREATE TABLE files_analyses
(
  id          INTEGER AUTO_INCREMENT,
  film_id     INTEGER NOT NULL, # ID fixnum
  titre       VARCHAR(200) NOT NULL,
  specs       VARCHAR(16),
  created_at  INTEGER(10),
  updated_at  INTEGER(10),
  PRIMARY KEY (id, film_id)
);
```

La table qui lie les users aux fichiers

```sql
CREATE TABLE user_per_file_analyse
(
  file_id     INTEGER,
  user_id     INTEGER,
  role        INTEGER(2),
  created_at  INTEGER(10), # date où l’user s’est occupé de ce fichier
  updated_at  INTEGER(10), # changement de rôle
  PRIMARY KEY (file_id, user_id)
);
```

## Rôle de l'analyste (propriété `:role` dans `user_per_file_analyse`)

La valeur peut être de 0 à 63.

```

1     créateur du fichier
2     co-rédacteur
4     correcteur
8
16
32

```

Donc, par exemple, si l'user a un rôle de `5`, il est créateur et correcteur (ce qui va un peu de soi, mais pas forcément, puisqu'il faut qu'il ait entrepris réellement une correction pour qu'il soit enregistré comme correcteur pour le fichier).