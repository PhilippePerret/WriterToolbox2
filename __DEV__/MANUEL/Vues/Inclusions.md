# Inclusions

On peut inclure un fichier dans un autre fichier à l'aide de la balise `INCLUDE`.

```

INCLUDE[./path/to/file.txt]

```

Le chemin d'accès doit être un chemin relatif existant et complet.

Noter que le code sera injecté avant le traitement markdown et que donc le code inclus peut très bien contenir du code à formater.
