# Fonctionnement général

L'idée est d'isoler au maximum les choses.

## Synopsis d'une connexion

* Le fichier `index.rb` est appelé
* Il appelle `site.output` qui va construire la page à renvoyer
* `site.output` (dans `./lib/site/output.rb`) :
  * Charge la configuration définie dans `__SITE__/_config/main.rb`
  * Exécute certaines opération si nécessaire (par exemple transforme les fichiers SASS)
  * Définit la route pour savoir quelle page ou quelle opération exécuter. Par défaut, c'est la page `home`, située dans `./__SITE__/home/main.erb` qui est utilisée. Les autres routes sont définies dans `./lib/site/route.rb`
  * Charge tous les éléments de la page (cf. `site.load_route` dans `./lib/site/route.rb`), par exemple s'il y a un fichier `main.rb`, il est chargé avant la construction des pages. Idem pour les styles.
  * Appelle la méthode  `site.preload` qui, en appelant les méthodes `body`, `header`, `footer`, `head`, `left_margin` et `right_margin` permet de préparer les parties de la page.


## Fabrication d'une nouvelle partie

Bien la définir, en définissant notamment les `actions` qui y seront produite.

## Gabarit du site

Il est entièrement défini dans `./__SITE__/xTemplate`, que ce soit au niveau des fichiers entêtes, pieds de page, qu'au niveau des styles, dans le dossier `css`.
