# Utilisation de Markdown

* [Le module `md_to_page`](#module_md_to_page)
  * [Options de `MD2Page#transpile`](#md2page_options)

## Le module `md_to_page` {#module_md_to_page}

Le module `md_to_page` permet de prendre un fichier markdown (kramdown, en vérité) et de le transformer en un fichier `ERB` dynamique qu'on peut renvoyer à l'utilisateur.

Ce module procède à toutes les opérations possibles sur le texte, correction des balises spéciales, exécution des codes embarqués, formatages spéciaux, etc.

Il produit un fichier `.erb` dynamique qu'il suffira de déserber pour l'afficher dans le navigateur. Ce fichier `.erb` est placé au même niveau que le fichier original mais se termine par `.dyn.erb`.

### Options qu'on peut passer {#md2page_options}

```

    dest            Le path du fichier de destination
                    Si non fourni, MD2Page.transpile retournera le code

    no_leading_p    Si true (false par défaut), on supprime du code les
                    <p> et </p> qui entourent le code, et que Kramdown
                    ajoute chaque fois.

    pre_code        Le code (à traiter) à ajouter avant le code du fichier.
    post_code       Le code (à traiter) à ajouter après le code du fichier.

    raw_pre_code    Code à ajouter avant, à la fin, sans le traiter
    raw_post_code   Code à ajouter après, à la fin du traitement, sans le
                    traiter

    narration_current_book_id

                    Si c'est une page narration qui est traitée, on indique
                    son livre, pour traitement des liens vers d'autres pages,
                    les liens REF.

```
