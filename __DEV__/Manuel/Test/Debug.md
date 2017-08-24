# Debug en mode test {#debug_mode_test}

La commande `debug`, dans le programme, permet d'afficher des messages administration en bas de la fenêtre. Mais elle enregistre aussi ces messages dans le fichier `./xtmp/debug.log` pour être consultés facilement.

Au cours des tests, on peut donc utiliser la commande `debug <something>` pour écrire des messages dans le fichier `./xtmp/debug.log`.

## Détruire le log débug {#debug_remove_file}

Utiliser la commande `remove_debug` dans les feuilles de test pour détruire le log debug.
