# Utilisateur

## Identification {#user_identification}

On sait simplement si un user est identifié si son `id` est défini.

Rappel : qu'il soit identifié ou non, le visiteur possède une instance `User` qui permet de simplifier le travail avec lui.

La propriété interrogative `identified?` renvoie le statut du visiteur courant.

```ruby

  user.identified?
  # => Return true si l'user est identifié
  #    False dans le cas contraire.
  
```
