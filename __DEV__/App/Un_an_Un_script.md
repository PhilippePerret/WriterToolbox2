# Un An Un Script


## ID du programme courant de l'user

Cet identifiant est défini dans sa variable `unan_program_id`, on l'obtient donc avec :

```ruby

pid = user.var['unan_program_id']

```


## Programmes {#unan_programmes}

### Options des programmes {#unan_programmes_options}

```

  bit       Signification
  - - - - - - - - - - - - - - - - - - - - - - -
  1         Actif si 1, 0 si non actif

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
  3       2       Partage du projet. cf. Unan::UUProjet::SHARINGS dans :
                  ./__SITE__/unanunscript/bureau/partial/projet/projet.rb

```
