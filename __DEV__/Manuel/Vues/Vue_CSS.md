# Vues - stylisation avec CSS

Les vues sont stylisées avec `CSS` et le code est produit en `SASS`.

Il y a deux types de fichier CSS :

* **Les fichiers communs** à toute l'application. Ce sont tous les fichiers `SASS` qui sont définis dans tous les dossiers du dossier `./__SITE__/xTemplate/`. Tous ces fichiers sont assemblés en un seul fichier css : `./css/all.css`.
* **Les fichiers propres aux sections**. Ce sont les fichiers particuliers qui ne sont chargés que si la section est chargé.

## Chargement des fichiers particuliers {#css_load_custom_files}

En fait, le chargement des fichiers particuliers fonctionne avec le chargement des dossiers dans `site#load_folder` (fichier `./lib/site/utils.rb`).

```

- Imaginons la route demandée : `user/profil`

- Le programme charge le dossier `./__SITE__/user/profil/`

- Si le dossier `user` contient des fichiers SASS (en racine), ces fichiers
  sont chargés.
  Ces fichiers se trouveront dans `./css/user`
- Si le dossier `user/profil` contient des fichiers SASS (en racine), ces
  fichiers sont chargés.
  Ces fichiers se trouveront dans `./css/user/profil`

```

## Ajout forcé d'une feuille de styles {#force_add_stylesheet}

Pour ajouter une feuille de style de façon forcée dans une page, il suffit d'utiliser :

```ruby

  site.all_css << './css/path/to/file.css'

```

Si ce fichier vient d'un fichier `.sass`, il faut peut-être prévoir de l'actualiser avant, si la configuration surveille les SASS.

## Définitions générales (charte) {#define_valeurs_charte}

Tous les fichiers contenus dans `./__SITE__/xTemplate/css` et commençant par un `_` sont des fichiers de définition qui sont ajoutés à chaque début de code de fichier SASS. Donc on peut les utiliser dans n'importe quel fichier `SASS`, qu'il se trouve dans le dossier `xTemplate` ou dans le dossier d'une section.


## Actualisation automatique des fichiers CSS {#automatic_update_css}

L'actualisation des fichiers se fait automatiquement si `watch_css` est réglé à true dans les configurations de l'application. Noter qu'on ne peut « surveiller » les fichiers que si l'on se trouve en offline.
