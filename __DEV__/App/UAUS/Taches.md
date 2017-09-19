# Tâches {#unan_taches}

## Tâches relatives {#unan_taches_relatives}

Il y a d'un côté les `taches absolues`, qui sont les définitions de toutes les tâches du programme, pages de cours à lire, actions à accomplir, etc. et de l'autre les `tâches relatives`, qui sont des correspondants des tâches absolues mais pour l'auteur du programme.

À chaque tâche absolue, associée à un jour-programme, correspond une et une seule tâche relative.

### Option des tâches relatives {#unan_options_taches_relatives}

Les options doivent principalement permettre d'avoir des informations sur la tâche relatives qui permettront de relever plus vite les informations. Par exemple, le type de la tâche (`task`, `page`, `quiz` ou `forum`) sera enregistré pour connaitre rapidement toutes les tâches d'un type particulier.

```

    BIT     offset        Description
    -----------------------------------------------------------------------
    1-2     0..1          Type précis de tâche (dans Unan::Abswork::TYPES)
    3-5     2..4          Durée de la tâche, sur 3 chiffres
    6       5             Type général de la tâche :
                          0:  non défini (ne devrait pas arriver)
                          1:  task
                          2:  page
                          3:  quiz
                          4:  forum

```


### Statut des tâches relatives {#unan_status_taches_relatives}

Le statut des tâches relatives est définie dans la propriété `status` de la tâche, enregistrée dans la table.

Ce statut peut avoir les valeurs suivantes :

```

  0         Tâche non démarrée
  1         Tâche démarrée

  3         Tâche en dépassement

  5         Tâche en dépassement inacceptable (plus du double de la
            durée de la tâche elle-même)         

  9         Tâche achevée

```

Note : ce statut est calculé à l'arrivée de l'auteur sur son bureau la première fois que la date de dernière actualisation ne correspond pas au jour courant.
