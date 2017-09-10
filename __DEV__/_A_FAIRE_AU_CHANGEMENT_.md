* Créer la table `variables_0` dans `boite-a-outils_users_tables` (pour les variables site, comme le coup de projecteur) (LE CODE SE TROUVE DANS LA DÉFINITION DE LA TABLE DANS WRITERTOOLBOX v1)— en se connectant par ssh et en injectant le code

* Altérer toutes les tables `variables_xxx` de :cold.users_tables pour ajouter la colonne `created_at` avec le code : `ALTER TABLE variables_1 ADD COLUMN created_at INTEGER(10);`.

* Supprimer la colonne `annonce` dans la table :cold.updates (et la supprimer dans la définition de la table).

* Mettre la taille de la colonne `options` de la table :cold.updates à 16 (elle est à 32).

* Définir le coup de projecteur (rejoindre la section administration prévue à cet effet).

* Ajouter la colonne CREATED_AT aux tables scenodico, filmodico :

      use `boite-a-outils_bilbio`
      ALTER TABLE scenodico ADD COLUMN created_at INT(10);
      ALTER TABLE filmodico ADD COLUMN created_at INT(10);
