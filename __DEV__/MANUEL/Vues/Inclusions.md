# Inclusions

* [Inclusion de fichiers quelconques](#inclusion_fichier_quelconque)
* [Inclusion des exemples](#inclusion_exemples)

Pour des informations sur les partiels de page, voir plutôt le fichier `partiels.md`.

## Inclusion de fichiers quelconques {#inclusion_fichier_quelconque}

On peut inclure un fichier dans un autre fichier à l'aide de la balise `INCLUDE`.

```

INCLUDE[./path/to/file.txt]

```

Le chemin d'accès doit être un chemin relatif depuis la racine, existant et complet.

Noter que le code sera injecté avant le traitement markdown et que donc le code inclus peut très bien contenir du code à formater.

> Noter que contrairement aux balises `EXEMPLE` (cf. ci-dessous), aucun lien (pour le moment) ne permet d'éditer le fichier inclus de cette manière (l'inclusion est "transparente").


# Inclusion des exemples {#inclusion_exemples}

On inclut des exemples avec la balise :

```

EXEMPLE[path/relatif/to/exemple.md]

```

La différence avec les fichiers inclus par `INCLUDE`, c'est :

* le fichier se trouve dans `./__SITE__/narration/_data/exemples`,
* il est spécifié seulement par son chemin relatif depuis ce dossier,
* quand on est administrateur, il possède un lien qui permet de l'éditer directement sur le site.
