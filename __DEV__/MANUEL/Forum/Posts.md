# Messages {#forum_posts}

## Pour trouver les messages {#forum_posts_trouver}

Deux façons de trouver les messages :

* par le décalage depuis le début (avec `from`, par exemple `from=-1` va afficher le dernier message de la liste)
* Par l'identifiant du message (`pid`), avec possibilité d'indiquer `dir=next` ou `dir=prev` pour indiquer qu'il faut les messages DU PANNEAU avant ou après (donc PAS les messages avant pid).


```
  post_id     Permet à lui seul de déterminer la liste.
  Si l'url pour les suivants est :
    forum/sujet/<id sujet>?pid=<post_id>&dir=next&nombre=<nb>
    => On veut les <nb> messages après post_id
  et l'url pour les précédents est :
    forum/sujet/<id sujet>?pid=<post_id>&dir=prev&nombre=<nb>
    => On veut les <nb> message avant post_id
  Reste à déterminer si post_id est au début de la liste ou à la fin.
  Supposons que post_id est toujours au début, ce qui évite de scroller jusqu'au
  message, alors =
    pid=post_id&dir=next => on veut les <nb> après les <nb> messages
    pid=post_id&dir=prev => on veut les <nb> avant.

  Imaginons des messages qui soient tous dans l'ordre, de 1 à 1000
  Le nombre de message affichés est 20

  On veut le message 50
  => les messages de 50 à 69 sont affichés.
      Pour avoir les messages suivants : pid=50&dir=next
      => on relève les 2 x nb messages >= created_at du post#50
          (donc les messages de 50 à 90)
         Et on prend les 20 derniers de cette liste, donc 70 à 90
         On met à pid la valeur du premier message de la liste (#70)

      Pour avoir les messages précédents : pid=50&dir=prev
      => On relève les nb message < created_at du post#50
          (donc les messages de 30 à 49)
         On met à pid la valeur du message premier message de la liste (#30)

  Note : quand on ne connait pas post_id, on prend toujours l'identifiant
         du premier message de la liste.
```

## Options {#forum_post_options}

```

  BIT     OFFSET        DESCRIPTION
  1       0             1= post validé, 0= post non validé ou détruit
  2       1             1= post détruit (le bit 1 doit être à 0)

```
