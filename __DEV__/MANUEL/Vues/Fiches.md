# Fiches {#les_fiches}

Pour les mots du scénodico ou les fiches d'identité des films, le site utilise la classe `fiche` qui peut être généralisée à tout affichage de fiche.

La schéma d'implémentation est le suivant :

```

  .fiche
    div
      label
      div.value

```

## Les classes de `.fiche` {#fiches_class_css_fiche}

Les classes du div `.fiche` peuvent être :

```

  = La fiche =
    .cadre            Un cadre entoure la fiche

  = Labels =
    .label-medium     Les labels sont de tailles médium
    .label-large      Les labels sont de taille large
    .label-small      Les labels sont courts

```

## Les classes CSS des lignes `div` de `.fiche` {#fiches_class_css_rangees}


```

  .main       Pour indiquer la rangée principale, qui sera mise en exergue
  .mg2/4/6    Pour indiquer une marge, de 2, 4 ou 6
  .small      Pour indiquer une petite rangée
  .nodeco     Dans cette rangée, le `text-decorator` des liens sera supprimé,
              les liens apparaitront comme le texte normal.

```
