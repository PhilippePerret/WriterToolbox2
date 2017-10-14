# Bulles {#vues_bulles}

Pour certains textes, comme des alertes qui doivent prendre toute la page, on peut utiliser des bulles grâce au code :

```ruby

bulle("<message>", '<type>'[, '<attribut style>'])

```

Par exemple :

```ruby
bulle("Bonjour à vous !", 'green')
```

## Types de la bulle

Pour le moment, le type (deuxième argument) peut être :

* 'warning' (bulle rouge et texte rouge),
* 'notice' (bulle noire et texte noir),
* 'green' (bulle verte et texte noir),
* 'blue' (bulle bleue et texte noir).

## Attribut style

Le troisième argument permet de définir l'attribut `style` du paragraphe (`p`) principal.

Essentiellement, cela permet de définir la taille de la bulle et son décalage, par exemple, pour faire une bulle qui occupe la moitié de la page et soit décalée de la marge gauche :

```erb
<%= bulle("Mon texte dans la bulle", 'notice', 'width:50%;margin-left:10em;') %>
```
