
* Écrire mon CV (site/phil/main.erb)
* Tester les méthodes liens
  - en envoyant rien en argument (=> titre par défaut)
  - en envoyant un string comme seul argument (=> titre)
  - en envoyant un hash définissant le titre
  - en envoyant un hash définissant d'autres argument
* Écrire la partie charte du site (site/charte/main.erb)
* [BLOG] Implémenter et tester la rédaction/modification d'articles (admin/blog)
  (pour ça, il faut mettre en place la lecture de `op`, qui définit l'opération - par exemple "op=edit" pour éditer l'article spécifié dans `site.route.objet_id`)
  - S'assurer qu'un utilisateur lambda ne puisse pas atteindre cette partie
  - Faire des images (pas forcément en rapport avec l'article) pour le mettre entre le titre et l'article (soit de façon automatique soit en dur, à voir - de toute façon, si l'article est édité, on peut toujours le faire en l'enregistrant).

* Style : mettre un repère comme --------v------- sous les liens "boite", "outils" et "auteur" pour qu'on comprenne mieux que ce sont des liens principaux
* Mettre en place et tester l'accueil

* Mettre en place (et tester) le traitement des fichiers
  - fichier ERB
  On passe par trois niveaux :
  1. Fichiers balisés original (ERB, Kramdown, Autre ?)
     Si pas à jour, le fichier dynamique doit être reproduit
  2. Fichier dynamique (ne contient plus que les <% %> ou #{...}, à voir) qui devront être remplacés par les valeurs courantes (et notamment le pseudo, ou les féminines).
  3. Code final, envoyé au navigateur pour l'utilisateur.

  Voir aussi qu'il y a les cas des textes qu'on ne peut pas encore lire, soit parce que l'user n'a pas le niveau suffisant soit parce que le texte n'est pas encore lisible, comme certaines pages de cours. Donc, avant la transformation, il y a peut-être une vérification à faire.
  1. On demande le fichier
  => Filtre en fonction du développement du fichier et du niveau de l'user
  Si OK suite, sinon, texte type pour dire lecture impossible.
  2. Production du fichier dynamique s'il n'est pas à jour.
  3. Production du code final en fonction de l'user.
  NON : c'est à gérer avant, dans l'application Narration.

* Tester le message affiché dans le formulaire UN AN UN SCRIPT en fonction du fait que l'user est déjà abonné au site ou non (cela doit se faire dans signup/Suscriber_spec et signup/signup_spec)

* Ajouter "Par où commencer ?" dans la page de paiement OK et parler du bureau et de l'aide qu'on peut télécharger.

* On pourrait imaginer un module qui contienne/définisse toutes les opérations ticket, par exemple User#confirm_mail afin de ne pas avoir une méthode qui ne serve qu'une seule fois.
  * => Mettre en place la gestion des tickets

* Ajouter un lien "mot de passe oublié"

* Dès que l'objet d'une route est 'admin', il faut rejeter la requête si ça n'est pas un administrateur.

L'idée de cette refonte du site du BOA est de modulariser au maximum les choses en les isolant. Plutôt que d'aller chercher les choses à droite et à gauche, au point de ne plus savoir ce qui est chargé, chaque page/section utilise ses propres outils, et chaque opération est isolée.

Par exemple, l'inscription n'est plus une sous-partie de la classe `User`, c'est une opération à part. C'est une *fonction*, au sens de la programmation *fonctionnelle*.

Puisqu'elle concerne l'user, on la trouve quand même dans un dossier user dans :

```

  fonction/user/inscription/

```

Tout ce qui concerne l'inscription se trouve dans ce dossier, rien ne se trouve à l'extérieur, que ce soit les CSS propres ou le code.

On trouve aussi :

```

  __fonction__/user/inscription / main.erb
                                  main.rb
                                  main.sass
                                  module / create.rb
                                  form.erb
                                  mail / user_confirmation.erb
                                         user_ask_for_conf_mail.erb
                                         admin_information.erb
                    validation_mail / main.erb
                                      main.rb
                                      module / validate.rb
                                      mail / user_confirmation.erb
                                             admin_annonce_conf.erb
                    abonnement/...          # Abonnement au site

              / unan/inscription/       # inscription au programme UN AN UN
                                        # SCRIPT
              / analyse / accueil / main...
                        / films /   main...
                        / lire  /   main...
                        / comments /
                        /
                        / inscription/    # Inscription aux analyses
                        / depot_analyse/  # dépot d'une analyse
             / narration / accueil / main...
                         / livres  / main...
                         / livre_tdm /
                         / lire /
                         / comments /
            / forum / sujets /
                    / voir_sujet /    main...
                    / voir_message /      main...
                    / creer_sujet /       main...
                    / repondre_message /  main...
                    / ecrire_message /    main...

            / admin / user
                    / forum
                    / unan
                    / analyse
                    / narration
```
