# Formatage du code

Par principe, on considère que tout est écrit en `markdown`, avec des textes dynamique en erb (consignés entre balises `<% ... %>`).

On utilise une seule méthode globale pour traiter tous les textes :

```ruby

formated = formate(<code>)

```

Note : cette méthode globale utilise `MD2Page` pour «transpiler» le code original en code HTML. C'est quand même assez coûteux, donc il vaut mieux écrire ce code en dur une fois qu'il est composé, comme pour les pages de la collection Narration.
