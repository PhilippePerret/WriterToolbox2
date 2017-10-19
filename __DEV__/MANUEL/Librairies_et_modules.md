# Librairies & Modules {#libmod}

* Les librairies permettent de rassembler des méthodes utilisées ponctuellement à différents endroits du site.
* Elles sont propres à un élément particulier de l'application, le site, les users, etc.

## Librairies

On peut charger très facilement des librairies par :

```ruby

  require_lib 'objet:affixe'

```

> Note : `require_lib` (ou `require_library`) est une méthode globale donc rien à faire pour l'utiliser.

Les librairies permettent d'avoir des ensembles de méthodes (en général peu nombreuses) qui doivent être utilisés par plusieurs modules, afin d'être quand même le plus DRY possible.

### Qu'est-ce qu'une librairie ? {#libmod_whatisit}

Pour être une librairie, un fichier doit impérativement respecter deux règles :

1. être un fichier ruby unique ou un dossier contenant des fichiers ruby,
2. se trouver dans le dossier `_lib/library/` de l'objet.

Ce fonctionnement a été inauguré par la librarie `contact.rb` qui permet de savoir comment un user accepte d'être contacté. Comme ces méthodes servent aussi bien pour le profil de l'user (`user/profil`) que pour son formulaire de contact (`user/contact`), on les met dans une librairie unique qui se trouve dans :

```
./__SITE__/user/_lib/library/contact.rb
```

… et qui est appelé par :

```ruby
require_lib('user:contact')
```
