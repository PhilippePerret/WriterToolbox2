# Users dans les tests


## Récupérer le mot de passe

Si un user a été créé à l'aide de la méthode `created_new_user` (support de db), alors on peut récupérer n'importe quand ses données et son mot de passe par :

```ruby

huser = get_data_user(user_id)

```

Cela est possible car la méthode `created_new_user` enregistre le mot de passe dans la table des variables de l'user (`var['password']`).
