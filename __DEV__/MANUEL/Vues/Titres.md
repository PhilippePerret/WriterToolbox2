# Titres

Les titres principaux de page sont à définir dans des `h2`. Mais il est préférable d'utiliser la méthode globale dédiée :

```erb
<%= titre_page("Titre de la page"[, <hash d'options>]) %>
```

Qui produira :

```html
<h2>Titre principal de la page</h2>
```

La méthode `titre_page` permet également de définir le `TITLE` de la page HTML, pour un historique plus clair et un meilleur affichage. C'est la raison pour laquelle est est préférable au fait d'écrire le titre en dur (il faut même le faire chaque fois).

Lorsque le contenu est limité, on peut augmenter l'espace entre le titre et ce contenu en ajoutant la class `air` dans le second paramètre :

```erb
<%= titre_page("Mon titre sans contenu", {class: 'air'}) %>
```

… qui produira :

```html
<h2 class="air">Mon titre sans contenu</h2>
```

## Boutons sous le titre

Par convention, cette version utilise un système de navigation en mettant les menus en petit sous le titre. Ils sont appelés des “under buttons”. On les définit dans la propriété `:under_buttons` en second argument :

```erb

<%= titre_page(
      'Le titre de la page',
      {
        under_buttons: [ link1, link2, link3 ]
      }
  )
%>

```

`link1` etc. doivent être des liens conformes, qu'on peut obtenir par exemple avec `simple_link` :


```erb

<%= titre_page(
      'Le titre de la page',
      {
        under_buttons: [
          simple_link('#monLien1', 'Lien 1'),
          simple_link('#monLien2', 'Lien 2'),
          simple_link('#monLien3', 'Lien 3')
        ]
      }
  )
%>

```

## Sous-titre ajouté (propriété `subtitle`)

On peut ajouter un sous-titre uniquement pour la balise TITLE (et donc aussi pour l'historique) en utilisant la propriété `subtitle` du second paramètre :

```erb

<%=
  site.titre_page(
    'Le titre sur la page',
    {
      subtitle: "avec cet ajout"
    }
  )
%>

```

Le titre dans la page sera alors :

```
Le titre sur la page
```

… tandis que le titre dans la fenêtre et dans l'historique :


```
Le titre sur la page avec cet ajout
```
