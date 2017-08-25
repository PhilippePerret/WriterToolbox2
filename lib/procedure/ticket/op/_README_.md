# Dossier des procédures

Ce dossier contient toutes les méthodes qui peuvent être employées comme `code` dans la définition des tickets.

Selon le principe d'usage minimum, on place ici toutes les méthodes qui ne sont utilisées que rarement. Elles ne seront chargées que lorsqu'un ticket sera utilisé.

## Utilisation autre {#ticket_procedure_autre_utilisation}

Noter que puisque ces modules définissent des opération « de toutes pièces », il est possible de les charger pour les exécuter ailleurs.

Imaginons par exemple qu'on veuille valider le mail d'un user sans ticket. Il suffit de faire :

```ruby

require './lib/procedure/ticket/op/user.rb'
User.get(12).confirm_mail


```

> Noter quand même que le code ci-dessus serait plus simple directement :

```ruby

u = User.get(12)
u.set(options: u.options.set_bit(2,1))

```

Pour les opérations complexes, il serait possible d'imaginer un dossier `_op_` dans lib (`./lib/_op_`) qui définirait toutes ces opérations et qui sera chargé au besoin par le ticket. Ici, il serait donc suffisant de charger l'opération voulue et de la jouer. Mais attention, ça contredit le principe selon lequel les choses doivent être situées là où on les attend.
