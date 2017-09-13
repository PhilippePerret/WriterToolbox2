# Un An Un Script


## ID du programme courant de l'user

Cet identifiant est défini dans sa variable `unan_program_id`, on l'obtient donc avec :

```ruby

pid = user.var['unan_program_id']

```


## Programmes {#unan_programmes}

### Options des programmes {#unan_programmes_options}

```

  bit offset      Signification
  - - - - - - - - - - - - - - - - - - - - - - -
  1   0         Actif si 1, 0 si non actif
  2   1         1 si le programme est en pause, 0 sinon
  3   2         1 si le programme a été abandonné, 0 dans le cas contraire
  4   3         1 si on doit envoyer un mail d'état quotidien
  5   4         Heure éventuelle à laquelle le mail quotidien doit être
                envoyé. Nombre en base 24 (0-'n'). Pour obtenir l'heure,
                on fait <valeur bit>.to_i(24) et pour le convertir :
                <heure>.to_s(24).
  6   5         Si 1, l'auteur veut une pastille tâches dans son bandeau
                supérieur.
  7   6         Partage du projet. cf. Unan::UUProjet::SHARINGS dans :
                  ./__SITE__/unanunscript/bureau/partial/prefs/main.rb


```

## Projets {#unan_projets}

### Options des projets {#unan_projets_options}

```

  bit   offset    Signification
  - - - - - - - - - - - - - - - - - - - - - - -
  1       0       Actif si 1, 0 sinon
                  Noter qu'un projet peut être actif et son programme non, si
                  c'est une autre programme avec le même projet
  2       1       Type du projet cf. Unan::UUProjet::TYPES
                  ./__SITE__/unanunscript/bureau/partial/projet/projet.rb

```
