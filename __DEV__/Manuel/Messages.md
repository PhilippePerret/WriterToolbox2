# Messages



* `__notice(<message>)` permet d'afficher un message
* `__error(<message>)` permet d'afficher un message d'erreur dans la page

> Note : ces méthodes sont des raccourcs vers les méthodes de `site.flash` : `notice` et `error`.

## Messages d'erreurs (méthode `__error`) {#messages_erreurs}

Elle reçoit un argument qui peut être :

* Une simple message d'erreur,
* Une instance d'erreur (on écrira le message et on enverra le backtrace dans le débug — et donc un fichier),
* Une liste de messages (chacun fera l'objet d'un div).


## Messages de debug {#debug_messages}

On peut faire des messages de débug grâce à la méthode `debug`.

Elle reçoit un argument qui peut être :

* Une message simple
* Une erreur (on écrira le message et le backtrace)
* Une liste de messages (chacun fera l'objet d'une ligne)
