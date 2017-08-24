# Principes directeurs de la nouvelle mouture {#principes_directeurs}


* Le [minimum de méthodes](#principe_minimum_methods)


## On crée le minimum de méthodes possible {#principe_minimum_methods}

On ne crée une méthode que si elle est absolument indispensable. Par exemple, il existait une méthode `User.get_by_pseudo` avant, mais son usage est tellement insignifiant qu'on ne doit pas la créer.

En revanche, la méthode `User.get(<user id>)` est utilisé intensivement partout sur les sites.
