# Images {#images}

Les images peuvent être définies grâce à la balise `IMAGE`.

```
  IMAGE[relative/path.ext|type|Legend|style|folder]

  Le path relatif peut être absolu
  Sinon, il sera recherché dans :
    ./img/relative_path
    ./img/narration/relative_path
    ./img/analyse/relative_path
    ./<folder>/relative_path
    ./img/<folder>/relative_path

  L'image doit porter son extension.

  type [OPTIONNEL]

      plain     L'image occupera toute la largeur de la page
      inline    Image en ligne, comme une touche clavier par exemple
      fleft     Flottante à gauche
      fright    Flottante à droite

      Laisser vide si aucune valeur.

  legend [OPTIONNEL]

      La légende à placer sous le texte.

      Laisser vide si aucune valeur.

  style [OPTIONNEL]

      Le code de l'attribut `style`. Par exemple `width:50px;`
      Ne pas oublier de terminer par ';'

      Laisser vide si aucune valeur.

```

Les balises `IMAGE` sont traitées dans le module `./lib/utils/md_to_page/balises_speciales.rb`
