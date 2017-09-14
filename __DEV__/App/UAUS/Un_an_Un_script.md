# Un An Un Script

[pday]: #unan_jour_programme

## ID du programme courant de l'user {#unan_id_programme_courant_user}

Cet identifiant est défini dans sa variable `unan_program_id`, on l'obtient donc avec :

```ruby

pid = user.var['unan_program_id']

```


## Programmes {#unan_programmes}

### Options des programmes {#unan_programmes_options}

```

  bit offset      Signification
  - - - - - - - - - - - - - - - - - - - - - - -
  1     0         Actif si 1, 0 si non actif
  2     1         1 si le programme est en pause, 0 sinon
  3     2         1 si le programme a été abandonné, 0 dans le cas contraire
  4     3         1 si on doit envoyer un mail d'état quotidien
  5     4         Heure éventuelle à laquelle le mail quotidien doit être
                  envoyé. Nombre en base 24 (0-'n'). Pour obtenir l'heure,
                  on fait <valeur bit>.to_i(24) et pour le convertir :
                  <heure>.to_s(24).
  6     5         Si 1, l'auteur veut une pastille tâches dans son bandeau
                  supérieur.
  7     6         Partage du projet. cf. Unan::UUProjet::SHARINGS dans :
                  ./__SITE__/unanunscript/bureau/partial/prefs/main.rb

  8-10  7-9       Jour-programme de la dernière actualisation de la table
                  `unan_works_<id auteur>`


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


## Tâches {#unan_les_taches}

Les tâches, ce sont tout ce que l'auteur du programme doit accomplir, que ce soit un document à rédiger, une page de cours à lire ou un message de forum auquel il faut répondre.

Une tâche peut être dans un de ces états :

```

  description               diminutif     note
  ---------------------------------------------------------------------
  Une tâche future          future
  Une tâche à démarrer      ready
  Une tâche en cours        running       Elle a été démarrée
  Une tâche en dépassement  overtook      Si l'échéance est dépassée
  Une tâche accomplie       done

```

L'état de la tâche dépend de :

* son jour de départ

Chaque [pday] définit sa liste de tâches dans sa propriétés `works` donc pour un jour-programme donné on peut savoir tous les travaux qui ont été amorcé. En couplant avec la donnée `duree` du travail, on peut savoir les travaux qui doivent être en cours et ceux qui doivent être achevés.

```ruby

works_ids = Array.new
site.db.select(:unan,'absolute_pdays',"id < #{jourp_courant}",[:works]).each do |hpday|
  works_ids += hpday[:works].split(' ')
end

```

Travaux du jour :

```ruby

works_ids = Array.new
site.db.select(:unan,'absolute_pdays',"id = #{jourp_courant}",[:works]).each do |hpday|
  works_ids += hpday[:works].split(' ')
end

```

### Travaux démarrés {#unan_running_works}

Avant la version 2.0, un enregistrement dans la table `unan_works_<id auteur>` était créé seulement lorsque l'auteur démarrait le travail. À présent, cet enregistrement est créé dès qu'il le faut, c'est-à-dire par CRON ou par visite de l'auteur.

> Noter que l'identifiant du « work-relatif », dans cette table, ne peut être l'identifiant du travail absolu, car cette table va pouvoir contenir tous les travaux de l'auteur, même s'il travaille sur plusieurs programmes d'affilée.

> Donc, ce sont les propriétés `program_id` (qui détermine le programme), `abs_work_id` (qui détermine l'ID du travail) et `abs_pday` (jour-programme absolu) qui détermine le travail.

> Noter qu'on tient compte de `abs_work_id` et de `abs_pday` car un même travail (d'identifiant `abs_work_id`) peut être répété plusieurs jours différents. Donc il faut obligatoirement ces deux données pour savoir à quel travail on fait allusion.

### Fonctionnement de la tenue à jour de la table `unan_works_<id auteur>`

On peut savoir si la table est à jour grâce aux options du programme. Les bits 8, 9 et 10 (donc d'index 7 à 9, `options[7..9]`) définissent le jour-programme de la dernière actualisation. Par exemple, si la dernière actualisation s'est faite le 89e jour-programme, la valeur des bits 8 à 10 est "089".

À partir du moment où le jour-programme courant est supérieur à cette valeur, il faut actualiser la table des travaux relatifs (`users_tables.unan_works_<id auteur>`).

Cette actualisation se fait simplement en relevant tous les nouveaux travaux entre la date de dernière actualisation (ou le premier jour) et le jour-programme courant, et en ajoutant les travaux créés entre ces deux dates, seconde comprise.


### Obtenir les travaux démarrés

Pour obtenir tous les travaux démarrés pour le programme, jusqu'à aujourd'hui, on peut faire :

```ruby

=begin

  Avec
  ----
    PrgID   :   ID du programme de l’auteur
    CurPDAY :   Jour-programme courant

=end

WHERE program_id = PrgID AND abs_pday <= CurPDAY

```

Noter que la liste retournées contiendra aussi les travaux finis.

Le [statut du travail](#unan_statut_travail) (propriété `status` du work dans la table de l'auteur) permet de savoir où en est le travail.

Les [options](#unan_options_work), pour le moment, ne contient que le type du travail et la durée du travail.


### Statut du travail (`Work@status`) {#unan_statut_travail}

```

  0       Travail non démarré (utile dans la version 2.0 du site)
  1       Travail démarré
  9       Travail achevé

```

### Options du travail (`Work@options`) {#unan_options_work}

```

  Bits 0-1        Type du travail absolu.
  bits 2-4        Durée, en jours-programme, du travail absolu.


```

## Les P-Days, jours-programme {#unan_jour_programme}

Les “jours-programmes” correspondent aux journées de programme, en sachant qu'à un rythme normal (5), un jour-programme est équivalent à un jour normal. Mais plus on ralentit le rythme et plus ces jours-programme sont longs, et au contraire plus on accélère le rythme et plus ces jours-programme sont courts.

Un auteur en est toujours à un jour-programme précis consigné dans la propriété `current_pday` de son programme. On l'obtient donc partout par :

```ruby

jour_prog = user.program.current_pday

```

On connait la date de démarrage de ce jour-programme par la propriété `current_pday_start` du programme.

```ruby

demarrage = user.program.current_pday_start

```
