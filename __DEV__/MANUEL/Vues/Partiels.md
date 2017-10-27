# Partiels

## Utilisation de partiels {#working_with_partials}

On peut travailler avec des partiels placés à l'intérieur du dossier courant.

Noter que l'avantage de travailler à l'aide d'un dossier `partial` dans l'objet est le fait que les fichiers qu'il contient ne seront chargés que si le partiel est chargé.

Par exemple, si on a :

```

  ./__SITE__/mon_objet/main.erb
                      /another_folder/another_file.rb
                      /athird_folder/athird_file.rb
                                   /athird_file.js
                      /partial/a_partial.rb


```

… alors, ci-dessus, les dossiers `another_folder` et `athird_folder` seront intégralement chargés (même les `.js` et `.css`) chaque fois que `mon_objet/main.erb` sera appelé tandis que `a_partial.rb` ne sera chargé que s'il est explicitement invoqué (cf. ci-dessous).



Ces partiels s'appellent à l'aide de :

```erb

  <%= partial('path/rel/to/partiel/from/current/folder') %>

```

Par exemple, si on se trouve dans le dossier `./__SITE__/user/profil/`, on trouve dans ce dossier le fichier `elements/no-profil.erb`. On le charge à l'aide de :

```erb

  <%= partial('elements/no-profil') %>

```

> Noter que l'extension peut être omise, mais que ce partial doit toujours être un fichier `ERB`.

Si ce dossier s'appelle `partial`, on peut même omettre le dossier et faire simplement :

```erb

  <%= partial('no-profil') %>

```
