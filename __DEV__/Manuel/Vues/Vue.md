# Vues {#views}

Une « vue » est un code HTML complet qui permet l'affichage d'une page. Il commence toujours par `<DOCTYPE` et finit par `</html>`. En fait, on utilise `CGI` (`cgi.out`) pour le finaliser.

La page est construite dans `./lib/site/output` par la méthode `Site#output`.

## Construction de la vue {#building_view}

Selon les principes du site, on reconstruit toujours entièrement une page là où on se trouve. Donc, à la base, les pages `main.erb` des dossiers contiendront :

```html

<%= header %>            <!-- s'achève par <section id="contents"> -->

<%= lmargin %>

<!-- ICI LE CONTENU PROPRE DE LA PAGE -->

<%= footer %>            <!-- commence par </section> -->

```

> Noter que `header` se finit par l'ouverture de la section `#contents` et `footer` début par la fermeture de cette section. Il est donc inutile d'ajouter ces balises.

> Noter aussi, en conséquence, que la marge gauche est contenu dans la section `#contents`.

> Noter également que c'est le site (`site`) qui est **toujours** "bindé" aux vues, donc il est inutile d'utiliser `site.header`. `header` suffit.

On peut définir d'utiliser la version courte de chaque élément, ou même la version de la page d'accueil en ajoutant un argument à l'appel :

```erb

<%= header(:small) %>

```

Charge la version réduite de l'entête.

```erb

<%= header(:home) %>

```

Le code précédent charge la version pour l'accueil de l'entête.

> Noter que tous ces éléments se définissent dans le dossier `./__SITE__/xTemplate` (dossiers `header`, `footer`, etc.).

## Méthode de déserbage (sic) {#vues_deserbage}

On peut utiliser la méthode globale `deserb(path)` pour déserber une vue (ou un mail, etc.).

Astuce : pour faire facilement appel à un fichier qui se trouverait au même niveau que le fichier utilisant la méthode `deserb` (ou à proximité), on peut utiliser `File.dirname(__FILE__)` qui retourne le dossier du fichier courant.

Par exemple :

```ruby

code_html = deserb(File.join(this_folder, 'fichier_meme_niveau.erb'))

autre_html = deserb(File.join(this_folder, 'dossier/file.erb'))

fichier_autre = deserb(File.join(this_folder, '../autre_dossier/fichier.erb'))

def this_folder
  @this_folder ||= File.dirname(__FILE__)
end

```

## Méthode d'helper {#helpers_de_vues}

Puisque c'est le site (`site`) qui est "bindé" aux vues, lorsque l'on veut faire des méthodes d'helper, il suffit de les créer dans une instance site, par exemple dans un fichier `helpers.rb` se trouvant à la racine du dossier section.

Par exemple, dans la section `./__SITE__/user/signup` pour l'inscription de l'user,
on trouve un fichier `helpers.rb` contenant :

```ruby

class Site

  def menu_sexe
    ... construction du menu ...
    return code_html
  end

end

```

> Noter que ce fichier est chargé automatiquement.

Dans la page contenant le formulaire, on trouve simplement :

```html

  ...

  <div>
    <label>Vous êtes…</label>
    <span class="field"><%= menu_sexe %></span>
  </div>

  ...

```
