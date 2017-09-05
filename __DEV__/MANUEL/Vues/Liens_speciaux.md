# Liens spéciaux

* [Les liens vers page avant et après](#link_to_next_prev_pages)
* [Span de lien pour éditer la page courante (admin)](#link_to_edit_current_page)
* [Lien pour éditer un fichier quelconque](#lien_edition_fichier_quelconque)
* [Lien vers les pages de la collection Narration](#links_to_narration)

## Liens vers pages avant et après {#link_to_next_prev_pages}

Pour obtenir une homogénéité dans le site, utiliser :

```html

<div class="liens_next_previous_pages top"> <!-- ou bottom pour en bas -->
  <span class="lien_prev_page">
    <a ... >
  </span>

  <span class="lien_main_page">
    <a ...>
  </span>

  <span class="lien_next_page">
    <a ...>
  </span>

  <div class="under_next_prev_links">
    <!-- Éventuellement, pour écrire à droite, small-caps -->
  </div>
</div>

```

> Note : dans Vim, pour utiliser les flèches spéciales, faire CTRL k puis "->" ou "<-".

> Note : pour que les flèches soient suffisamment grosses, on met un `font-size` assez important. S'il faut vraiment mettre du texte, le mettre dans un span avec, par exemple, la class `tiny`.

> Note : les styles sont définis dans `./__SITE__/xTemplate/css/contents_section.sass`.


## Span de lien pour éditer la page courante (article, etc.) {#link_to_edit_current_page}

Pour mettre un lien d'édition de la page dans le document, placer en haut :
```html

  <span class="span_edit_link">
    <a ... le lien >
  </span>

```

> Note : les styles sont définis dans `./__SITE__/xTemplate/css/contents_section.sass`.

> Note : mettre de préférence ce lien dans le `h2` du titre de la page.

Par exemple, pour les articles :

```html

<span class="span_edit_link">
  <a href="admin/blog/12?op=edit">Éditer l'article</a>
</span>

```


## Lien pour éditer un fichier quelconque {#lien_edition_fichier_quelconque}

```ruby

site.lien.edit_text("path/to/file.md", {
  titre: "autre titre que 'éditer'",  # le titre, si autre que "éditer"
  in_span: true                       # pour renvoyer un code dans un span
                                      # span_edit_link
  })

```


## Lien vers les pages de la collection Narration {#links_to_narration}

```

REF[<ID page>[|titre forcé ou réel|ancre]]

```

> Si le lien est demandé depuis un autre livre que le livre de la page contenant l'appel, alors on précise le titre du livre et on ajoute un lien vers sa table des matières. Dans le cas contraire, on n'indique pas le livre.
