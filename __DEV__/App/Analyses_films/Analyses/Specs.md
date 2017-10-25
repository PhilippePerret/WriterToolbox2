# Specs des analyses {#analyses_options_analyses}

Dans sa nouvelle version, la propriété `:specs` des analyses dans la table `films_analyses` doit définir le maximum de choses, en reprenant les informations des options précédentes.


## Signification des bits dans la propriété `:specs` des films de la table `films_analyses` (`boite-a-outils_biblio`).

```

  BITS     OFFSETS        DESCRIPTION
--------------------------------------------------------------------

  1         0             1=Le film est analysé (rappel : tous les films
                          peuvent avoir leur enregistrement dans la table)

  2         1             Si 1, cette analyse possède une "leçon tirée du film"

  3         2             OBSOLÈTE

  4         3             Type de l'analyse
                          -----------------
                          1: Analyse seulement TM (TextMate, des fichiers)
                          2: Analyse seulement MYE
                          3: Analyse mixte, TM et MYE

  5         4             Visibilité de l'analyse
                          -----------------------
                          1: L'analyse peut être lue par le visiteur quelconque.
                          0: L'analyse n'est consultable que par les admins et
                             les analystes.

  6         5             Analyse en cours
                          -----------------
                          0: Cette analyse n'est plus en cours
                          1: Cette analyse est en cours, c'est-à-dire qu'un
                          analyste au moins s'en occupe.

  7         6             1: Analyse en cours de relecture
  8         7             1: L'analyse est complètement achevée
  9         8             1: Ce n'est pas une analyse complète, c'est seulement
                             quelques notes. Mais cette spécifications pourrait
                             disparaitre au profit de traitements qui tiendraient
                             compte des fichiers, etc.
                             => OBSOLÈTE

 12-16      11-15         Présence des documents dans l'analyse. Cf. ci-dessous
                          les "documents contenus".

```

## Les documents contenus

Les bits 12 à 16 (index 11-15) des analyses permettent de définir les documents que l'analyse contient (en base 36 donc valeur max : 15 548 445)

```

  Rappel : pour connaitre le total, il suffit d'enlever 1 à la valeur suivante.
           Par exemple, pour savoir combien ça fait jusqu'au document 64, on
           prend la valeur suivante, 128, et on obtient 127

        1   Le document de collecte
        2   Le document .persos qui fonctionne avec le document de collecte
        4   Le document .brins qui fonctionne avec le document de collecte
        8
       16
       32   Une table des matières
       64   Une introduction (au moins une page)
      128   Un document de commentaires généraux, assez étoffé, synthèse
      256   Une leçon tirée du film
      512   Une timeline dynamique (par défaut si fichier de collecte)
    1 024
    2 048
    4 096   Un ou des documents étoffés sur les personnages
    8 192    Un ou des documents étoffés sur la structure (par défaut si fichier de collecte)
   16 384   Un ou des documents étoffés sur la dynamique narrative (triade OOC)
   32 768   Des ou des documents étoffé sur les procédés
   65 536   Des évènemenciers
  131 072   Des notes suffisamment importantes
  262 144
  524 288   Des statistiques (par défaut si fichier de collecte)
1 048 576
2 097 152
4 194 304
8 388 608   NE PAS UTILISER (TOTAL SI TOUS LES DOCUMENTS)

```

## Analystes

On peut connaitre les analystes (créateur et autre) de l'analyse en recoupant avec la table `user_per_analyse`. On prend l'ID fixnum du film avec l'ID de l'user.

Par exemple on obtient les analystes sur un film — et toutes, absolument toutes les autres informations — par :

```sql

SELECT u.*, f.*, fa.*
  FROM user_per_analyse ua
  INNER JOIN `boite-a-outils_hot`.users u ON ua.user_id = u.id
  INNER JOIN films_analyses fa ON ua.film_id = fa.id
  INNER JOIN filmodico f ON ua.film_id = f.id
  WHERE film_id = ua.film_id

```
