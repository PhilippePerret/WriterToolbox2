# Principes directeurs de la nouvelle mouture {#principes_directeurs}


* Le [minimum de méthodes](#principe_minimum_methods)
* Le [minimum de « globalisation »](#principe_minimum_globalisation)


## On crée le minimum de méthodes possible {#principe_minimum_methods}

On ne crée une méthode que si elle est absolument indispensable. Par exemple, il existait une méthode `User.get_by_pseudo` avant, mais son usage est tellement insignifiant qu'on ne doit pas la créer.

En revanche, la méthode `User.get(<user id>)` est utilisé intensivement partout sur les sites.

## Principe du minimum de globalisation {#principe_minimum_globalisation}

Au lieu de faire des méthodes qu'on n'utilise qu'une seule fois (p.e. la déconnexion) qui sont chargées à chaque fois, on ne met dans les méthodes chargées chaque fois seulement celles qui sont indispensables et utilisées fréquemment.

Exit les méthodes `as_div` et autre `as_select` qui étaient bien pratiques mais étaient chargés chaque fois. On les trouve maintenant dans des modules qu'il faut charger seulement quand on en a besoin, c'est-à-dire quand on doit faire une usage intensif de l'HTML.

## Les choses doivent se situer là où on les attend {#principe_de_moindre_surprise_place}

Même si ça parait évident, les choses (modules, opérations) doivent se trouver là où on les attend. Dans la réalité, je les dispatche toujours un peu partout, et une opération fait appel à d'autres opérations situer ailleurs. Je ne sais plus où sont les choses.

Au maximum, une opération quelconque doit être autonome et rassembler tout ce dont elle a besoin. À partir du moment où une méthode/opération est récurrente à plusieurs méta-opération, il faut en faire une méthode générale.
