# Les Mails {#mails}


Tout ce qui concerne les mails est contenu dans le dossier `./lib/procedure/user/send_mail/`.

Il n'existe que deux éléments externes :

* La méthode `User#send_mail` (dans `./lib/user/instance/methods.rb`) qui permet de charger ce dossier et d'appeler la méthode principale.
* Les données d'envoi, dans le dossier `./__SITE__/_config/data/secret/data_mail.rb`. **Ajuster les données à la création du site**.

Si l'on veut customiser les éléments pour l'application, c'est donc dans le dossier `./lib/procedure/user/send_mail/` qu'on doit aller.

## Envoi simple d'un mail {#mails_envoi_simple}

La procédure est la suivante :

```ruby

destinataire = User.get(user_id)

destinataire.send_mail({
  subject:        "Le sujet du mail",
  message:        "<p>Le message du mail</p>",
  formated:       true, # S'il est déjà au format HTML
  force_offline:  true  # Pour forcer l'envoi même en online
  })

```

## Lien dans un mail

On peut utiliser la méthode pratique `full_link` pour ajouter un lien dans un mail. Cette méthode fonctionne comme `simple_link` mais retourne une URL complète.

Par exemple :

```ruby
"Vous pouvez vous rendre à #{full_link('site/home?next=aide%2Fsite', 'l’accueil du site', 'exergue')} pour trouver ces informations."
```

Si `site.configuration.online` est égal à "www.laboiteaoutilsdelauteur.fr", alors le code précédent produira :

```html
a<p>Vous pouvez vous rendre à <a href="http://www.laboiteaoutilsdelauteur.fr?next=aide%2Fsite" class="exergue">l’accueil du site</a> pour trouver ces informations.</p>
```


> Rappel : remplacer les "/" par des "%2F" dans les adresses en paramètres.

## Toutes les options possibles {#mail_all_options}

Résumé de toutes les options possibles (voir le détail plus bas dans le document) :

```ruby

destinataire.send_mail(
  formated:               false #/true Si true le message est au format HTML
  no_header:              false #/true Si true, aucun entête de message
  admin_header:           false #/true Si true, on utilise l'entête pour les
                                # administrateurs
  force_offline:          false #/true Si true, le message est envoyé, même en
                                # mode OFFLINE
  short_subject:          "..." # Si défini au lieu de `subject`, on utilise
                                # le préfixe réduit aussi.
)

```


## Entête de mail {#mail_custom_message_header}

L'entête du message se définit dans le fichier `./lib/procedure/user/send_mail/custom_header.erb`.

## Entête de mail simplifié pour l'administration {#mail_admin_message_header}

L'entête simplifié pour l'administrateur se définit dans le fichier `./lib/procedure/user/send_mail/custom_admin_header.erb`.

Il suffit ensuite d'ajouter `admin_header: true` aux données du mail.

## Mail sans entête customisé

On peut également se passer de tout entête en ajoutant `no_header: true` aux données du mail.

## Définir les valeurs customisées {#mail_define_customs_texts}

La plupart des valeurs se trouvent dans `./lib/procedure/user/send_mail/site_customisation.rb`

## Utilisation d'un entête de sujet réduit {#mail_short_header_subject}

Dans le message, si l'on définit `short_subject` au lieu de `subject`, c'est l'entête `short_header_subject` (valeur customisée) qui sera utilisée plutôt que `header_subject` (valeur customisée).


## En offline {#mails_en_offline}

En offline, les mails sont tous enregistrés dans le dossier `xtmp/mails`.

Pour forcer l'envoi d'un message en offline, il faut lui ajouter la propriété `force_offline: true`.


## Test des  mails

Pour pouvoir tester les mails dans la feuille de test, il faut au préalable charger le dossier support en ajoutant :

```ruby

# Haut de la feuille de test
require_support_mails_for_test

```

On utilise ensuite les méthodes :

```ruby

expect(<User>).to have_mail(<data du mail>)

```

### Tester la date d'envoi d'un mail {#mails_test_date_envoi}

Dans `<data du mail>`, on peut préciser quand a été fait l'envoi grâce au propriété `sent_after` et `sent_before`. Par exemple :

```ruby

describe "Test avec date" do
  start_time = Time.now.to_i - 1
  ... Ici une opération qui envoie un mail ...
  expect(lui).to have_mail(
    sent_after: start_time,
  )
  # => succès si le mail a été envoyé
end

```

### Récupérer un mail pour le tester {#mails_get_mail_to_test}

On utilise la méthode :

```ruby

expect(lui).to have_mails(... data du mail ...) # ou have_mail au singulier
premier_mail = get_mails_found[0]

```

### Récupérer tous les mails {#mails_get_all_mails}

```ruby

mails = get_all_mails

```

### Détruire tous les mails {#mails_erase_all}

```ruby

reset_mails

ou

remove_mails

```
