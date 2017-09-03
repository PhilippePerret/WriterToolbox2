# Utilisation de Markdown

* [Le module `md_to_page`](#module_md_to_page)

## Le module `md_to_page` {#module_md_to_page}

Le module `md_to_page` permet de prendre un fichier markdown (kramdown, en vérité) et de le transformer en un fichier `ERB` dynamique qu'on peut renvoyer à l'utilisateur.

Ce module procède à toutes les opérations possibles sur le texte, correction des balises spéciales, exécution des codes embarqués, formatages spéciaux, etc.

Il produit un fichier `.erb` dynamique qu'il suffira de déserber pour l'afficher dans le navigateur. Ce fichier `.erb` est placé au même niveau que le fichier original mais se termine par `.dyn.erb`.
