# Specs des analyses {#analyses_options_analyses}

Dans sa nouvelle version, la propriété `:specs` des analyses dans la table `films_analyses` doit définir le maximum de choses, en reprenant les informations des options précédentes.


## Signification des bits dans la propriété `:specs` des films de la table `boite-a-outils_biblio.films_analyses`.

```

  BITS     OFFSETS        DESCRIPTION
--------------------------------------------------------------------

  1         0             1=Le film est analysé (rappel : tous les films
                          peuvent avoir leur enregistrement dans la table)

  2         1             OBSOLÈTE. Si était à 1, l'user devait être inscrit
  3         2             ou abonné, pour consulter ces analyses.

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
