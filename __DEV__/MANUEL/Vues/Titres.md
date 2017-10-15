# Titres

Les titres principaux de page sont à définir dans des `h2`. Mais il est préférable d'utiliser la méthode globale dédiée :

```erb
<%= titre_page("Titre de la page"[, 'classe css optionnelle']) %>
```

Qui produira :

```html
<h2>Titre principal de la page</h2>
```

La méthode `titre_page` permet également de définir le `TITLE` de la page HTML, pour un historique plus clair et un meilleur affichage. C'est la raison pour laquelle est est préférable au fait d'écrire le titre en dur.

Lorsque le contenu est limité, on peut augmenter l'espace entre le titre et ce contenu en ajoutant la class `air`. On peut utiliser alors le second argument de `titre_page` :

```erb
<%= titre_page("Mon titre sans contenu", 'air') %>
```

… qui produira :

```html
<h2 class="air">Mon titre sans contenu</h2>
```
