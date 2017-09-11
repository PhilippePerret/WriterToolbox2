# Sections spéciales


## Cadres

Quand un texte est assez court et seul dans la page, on le présente plutôt dans un cadre réduit.

Cf. par exemple la page de profil sans être identifié.

Cet aspect s'obtient avec un `DIV` de class `.cadre.air`.

```html

<div class="cadre air">
  <p>Un texte court</p>
  <p>Une autre ligne de texte court.</p>
</div>

```

Noter qu'il est réduit à 50% de largeur par défaut. Pour qu'il soit large, ajouter… `.large` à la classe.

```html

<div class="cadre air large">
  <p>Un texte court mais dans un cadre large, qui va faire toute la page.</p>
  <p>Une autre ligne de texte court qui va prendre toute la page.</p>
</div>

```
