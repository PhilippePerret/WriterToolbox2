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

    7-9     6..8          Nombre de jours de dépassement.
                          Cette valeur est réglée à la terminaison du travail,
                          s'il est en dépassement.
                          
```


### Statut des tâches relatives {#unan_status_taches_relatives}

Le statut des tâches relatives est définie dans la propriété `status` de la tâche, enregistrée dans la table.

Ce statut fonctionne par bit sur un entier d'un seul chiffre :

```

  1     Bit de démarrage
  2     Bit de dépassement            2     Work non démarré en dépassement
                                      3     Work démarré en dépassement
  4     Bit de grand dépassement (*)  4     Work non démarré directement en
                                            grand dépassement
                                      5     Work démarré directement en grand
                                            dépassement
                                      6     Work non démarré en grand dép. après
                                            avoir été en dép.
                                      7     Work démarré en grand dép. après
                                            avoir été en dép.
  8     Bit de fin                    9     Work terminé.
                                            Noter qu'il n'y a plus d'indication
                                            de dépassement ici. Mais le nombre
                                            de jours de dépassement à la fin du
                                            travail est consigné dans les
                                            options.

```

(*) Le « grand dépassement » correspond à un dépassement supérieur à la durée du travail. Par exemple, si le travail dure 4 jours, le grand dépassement est atteint lorsque le travail est en retard de 4 jours.

Note : ce statut est calculé à l'arrivée de l'auteur sur son bureau la première fois que la date de dernière actualisation ne correspond pas au jour courant.
