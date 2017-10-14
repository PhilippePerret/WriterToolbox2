# Temps et dates {#date}

## Date humaine {#date_humaine}

La méthode `Fixnum#as.human_date` retourne la date au format humain.

```ruby
  {Fixnum}.as_human_date # => JJ MM YYYY - H:MM
```

Pour utiliser un format particulier, il suffit d'envoyer ce format en argument.

```ruby
  {Fixnum}.as_human_date('%d %m %y') # => JJ MM YY
```

## Laps de temps depuis maintenant {#date_ago}

C'est la mode d'indiquer le temps depuis maintenant. On utilise pour ça la méthode `ago` de `Fixnum` :

```ruby
{Fixnum}.ago # => Laps de temps depuis maintenant
```

Ce laps est « intelligent », c'est-à-dire qu'il peut indiquer « 12 secondes » aussi bien que « 4 mois » ou « plus de 15 ans ».
