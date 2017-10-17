# Tickets {#tickets}

Les tickets permettent d'enregistrer des opérations, parfois complexes, qui peuvent être appelées depuis un simple mail.

## Créer un ticket

Pour créer un ticket, utiliser le code :

```ruby
require_folder('./lib/procedure/ticket')
Ticket.create({
  user_id:      <ID du user concerné>,
  code:         <code ruby à exécuter>,
  # Données optionnelles
  a_title:   "<titre à donner au lien pour jouer le ticket>",
  a_class:   'classCss' # pour le lien (Ticket.link)
  })
```

Les informations se récupèrent ensuite dans :

* **`Ticket.id`**. L'ID du ticket généré (à mettre dans `tckid` de l'URL),
* **`Ticket.url`**. L'URL du ticket généré, avec l'adresse complète, par exemple `http://www.atelier-icare.net?tckid=DGFH67DUJD..DFH778`,
* **`Ticket.link`**. Un lien `<a>` complet, avec le titre `a_title` s'il a été fourni ou le titrep ar défaut “Jouer ce ticket”.

> Noter qu'il faut bien entendu récupérer ces valeurs avant qu'un autre ticket ne soit généré.

Par exemple, pour obtenir l'ID du ticket :

```ruby
require_folder('./lib/procedure/ticket')
Ticket.create({
  user_id: 1,
  code:    "__notice(\"Dire bonjour à #{User.get(1).pseudo})",
  return: :ticket_id
  })

__notice("L'ID du ticket est #{Ticket.id}")

```

> Note : si `user_id` n'est pas spécifié, on prend l'ID de l'user courant.

Pour obtenir un lien à glisser dans un mail :

```ruby
require_folder('./lib/procedure/ticket')
Ticket.create({
  user_id: 3,
  code:    "User.get(3).send_mail({subject:'Hello',message:'Hello Marion'})",
  return: :full_link,
  link_title: "Lui dire bonjour"
  })

__notice("Cliquez ici pour #{Ticket.link}.")

```

Affiche le message “Cliquez ici pour Lui dire bonjour”. Et quand on clique sur “Lui dire bonjour”, une URL est appelée qui exécute le code.


Pour obtenir seulement l'URL, utiliser `Ticket.url`, par exemple, dans :

```ruby

simple_link(Ticker.url, "Cliquez sur ce bouton", 'btn main')

```

… qui va générer :

```html

<a href="http://wwww.monsite.org?tckid=FHDGFS67DHFJK" class="btn main">Cliquez sur ce bouton</a>

```
