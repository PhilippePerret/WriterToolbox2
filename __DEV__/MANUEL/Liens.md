# Liens {#liens}


## Produire un lien interne {#lien_interne}

```ruby
simple_link(<route>, <titre>, <classe>)
```

Par exemple :

```ruby
simple_link("forum/home", 'accueil du forum', 'exergue')
```

… produit :

```html
<a href="forum/home" class="exergue">accueil du forum</a>
```

## Produire un lien externe {#lien_externe}

Par exemple dans un message de mail. La méthode fonctionne comme `simple_link` mais en ajoutant `http://<url du site>` devant la route.

```ruby
full_link(<route>, <titre>, <classe>)
```

Règle l'URL en fonction de la valeur de `site.configuration.url_online`.
