* Créer la table `variables_0` dans `boite-a-outils_users_tables` (pour les variables site, comme le coup de projecteur) (LE CODE SE TROUVE DANS LA DÉFINITION DE LA TABLE DANS WRITERTOOLBOX v1)— en se connectant par ssh et en injectant le code

* Altérer toutes les tables `variables_xxx` de :cold.users_tables pour ajouter la colonne `created_at` avec le code : `ALTER TABLE variables_1 ADD COLUMN created_at INTEGER(10);`.

# COLD

* Updates :
  * Supprimer la colonne `annonce`.
    ALTER TABLE updates DROP COLUMN annonce;
  * Mettre la taille de la colonne `options` de la table :cold.updates à 16 (elle est à 32).
    ALTER TABLE updates MODIFY COLUMN options VARCHAR(16) DEFAULT '000000';

* Définir le coup de projecteur (rejoindre la section administration prévue à cet effet).

# BIBLIO

* Ajouter la colonne CREATED_AT aux tables scenodico, filmodico (peut-être que c'est déjà fait) :

      use `boite-a-outils_bilbio`
      ALTER TABLE scenodico ADD COLUMN created_at INT(10);
      ALTER TABLE filmodico ADD COLUMN created_at INT(10);

# ANALYSE

VOIR DANS LE FICHIER __TODO__/analyse_seed.sql les données à injecter

* Détruire les colonnes, titre, titre_fr, annee, film_id, sym dans la table `boite-a-outils_biblio`.films_analyses
    ALTER TABLE films_analyses DROP COLUMN titre;
    ALTER TABLE films_analyses DROP COLUMN titre_fr;
    ALTER TABLE films_analyses DROP COLUMN annee;
    ALTER TABLE films_analyses DROP COLUMN film_id;
    ALTER TABLE films_analyses DROP COLUMN sym;
* Changer la colonne 'options' pour 'specs'
    ALTER TABLE films_analyses CHANGE COLUMN options specs VARCHAR(16);
* Réduire la longueur de la colonne `realisateur`
  ALTER TABLE films_analyses CHANGE COLUMN realisateur realisateur VARCHAR(100);

* Créer la table qui va contenir l'indication des analystes qui font les analyses :
  CREATE TABLE user_per_analyse (
    user_id INTEGER,
    film_id INTEGER,
    role    VARCHAR(3),
    created_at INTEGER(10),
    updated_at INTEGER(10),
    PRIMARY KEY (user_id, film_id)
    );

# NARRATION

* Supprimer la colonne `handler` dans la table cnarration.narration
  ALTER TABLE narration DROP COLUMN handler


# PROGRAMME UN AN UN SCRIPT

> Note : *on pourrait faire ces modifications en créant un script dans ./lib/procedure/scripts/ qui serait lancé depuis _required.rb.*

* Ajouter la colonne `started_at` dans les tables `users_tables.unan_works_<id auteur>` (INT(10)) et y mettre la valeur du démarrage du travail, qui correspond au `created_at` (en tout cas dans la version du site 1.0 car pour la version 2.0, la données work est créée avant son démarrage).

* Ajouter la colonne `expected_at` et lancer son calcul avec un script qui reprendra les calculs de :
`./__SITE__/unanunscript/_lib/_not_required/module/update_table_works_auteur.rb`

```

Pour ajouter les colonnes :

  ALTER TABLE unan_works_* ADD COLUMN expected_at INT(10)
  ALTER TABLE unan_works_* ADD COLUMN started_at INT(10)

```

* Actualiser les données ONLINE avec les données OFFLINE de la table `absolute_work` dont un grand nombre de titres et de données ont été modifiées.

* Peut-être détruire la colonne `handler` dans la table `pages_cours` (voir avant comment on s'en sert).
  ALTER TABLE pages_cours DROP COLUMN handler;

* Détruire la colonne `source` dans la table 'exemples' (voir avant comment on s'en sert).
  ALTER TABLE exemples DROP COLUMN source;


# QUIZ

* Créer la base `boite-a-outils_quiz` sur AlwaysData.
* Copier le contenu de la base locale vers la base distante.
* Transformer les données résultats en données dans les tables des users.

# FORUM

* Détruire la colonne CATEGORIE dans la table sujets
  ALTER TABLE sujets DROP COLUMN categorie;

* Remplacer la colonne 'options' par la colonne 'specs' :
      use `boite-a-outils_forum`
      ALTER TABLE sujets CHANGE COLUMN options specs VARCHAR(16);

* Ajouter la colonne 'created_at' à la table `posts_content` et à la table `posts_votes`
     use `boite-a-outils_forum`
     ALTER TABLE posts_content ADD COLUMN created_at INTEGER(10), modified_by INTEGER;
     ALTER TABLE posts_votes ADD COLUMN created_at INTEGER(10);

* Détruire la table `users` du forum et la remplacer par la table avec le code dans le fichier `Forum/Tables.md` (qui permet de tout faire, détruire et remplacer).

* Détruire la table `follows` et la remplacer avec le code du fichier `Forum/Tables.md`

* Faire des inscrits pour animer le forum. Les utiliser pour poser des questions qui renverront aux différentes pages de Narration, à l'aide, aux différents outils, etc.

# Accueil

* Corriger le dernier article de blog (7) et le mettre en lecture.
