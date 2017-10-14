# Configuration du site {#site_configuration}

La configuration du site est définie dans `./__SITE__/_config/main.rb`.

## Propriétés configurées

Toutes ces propriétés peuvent s'obtenir en faisant `site.configuration.<propriété>`

```
  titre

      Le titre du site, en texte plein.

  url_offline

      URL offline du site, sans "http://"

  url_online

      URL ONLINE du site, sans "http://"

  db_bases_prefix

      Le préfix qui sera ajouté aux noms des bases, ce qui simplifie
      leur écriture.

  watch_sass

      Si true, les fichiers CSS seront actualisés à la volée en offline.      

  cookie_session_name

      Le nom de cookie pour la session de l'user, propre au site.

```

## Contenu du fichier de configuration {#config_file_content}

```ruby

site.configure do |s|

  # <description>
  s.<property> = <value>

end

```

## Ajout de proprités {#add_a_configuration}

Rien n'est à faire d'autre qu'ajouter une ligne `s.<propriété> = <valeur>` dans le fichier de configuration pour ajouter une propriété de configuration, puisque c'est une `method_missing` qui gère la fabrication des propriétés de configuration.

## Utilisation de la configuration dans les tests {#configuration_for_test}

On peut obtenir n'impore quelle valeur de configuration dans les tests grâce à la méthode `configuration_site` (qui n'existe que pour les tests). Par exemple :

```ruby

prefix = configuration_site.db_bases_prefix
# => return le préfix utilisé pour le nom des bases

```

C'est ce qui est utilisé pour pouvoir utiliser la tournure `db_use(:hot)` dans les tests.
