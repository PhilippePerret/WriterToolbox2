# Formatage du code

Par principe, on considère que tout est écrit en `markdown`, avec des textes dynamique en erb (consignés entre balises `<% ... %>`).

On utilise une seule méthode globale pour traiter tous les textes :

```ruby

formated = formate(<code>)

```

Les balises `ERB` ne sont pas évaluées (c'est le principe et la force de `MD2Page` de produire du code dynamique) sauf si l'on ajoute l'option `deserb: true` :

```ruby
formated = formate(<code>, deserb: true)
```

On peut définir si nécessaire ce qui doit être bindé à l'aide de la propriété `:bind` (par défaut, c'est le site) :

```ruby
formated = formate(<code>, deserb: true, bind: user)
```

Note : cette méthode globale utilise `MD2Page` pour «transpiler» le code original en code HTML. C'est quand même assez coûteux, donc il vaut mieux écrire ce code en dur une fois qu'il est composé, comme pour les pages de la collection Narration.
