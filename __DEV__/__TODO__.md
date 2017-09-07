* Empêcher d'utiliser le retour chariot sur le formulaire data narration
  * Ajouter un bouton à côté du champ ID pour éditer une page
  
* Régler les tabindex pour qu'on arrive tout de suite sur le formulaire d'identification (dans signin)

* Poursuivre l'élaboration du formulaire de données de page Narration
  - mettre en place les tests pour la tester.

* Une page dyn.erb doit être actualisée (i.e. détruite) :
  - lorsque sa page .md est modifiée
  - lorsqu'elle change de sous-chapitre
  - lorsqu'elle change de chapitre
  - lorsque le titre de son sous-chapitre change (toutes les pages doivent être actualisées)
  - lorsque le titre de son chapitre change (toutes les pages doivent être actualisées)
  - lorsque son chapitre est déplacé (toutes les pages doivent être actualisées)
  - lorsque son sous-chapitre est déplacé (toutes les pages doivent être actualisées)
  * À la modification d'un chapitre/sous-chapitre, il faut détruire son fichier
    dyn préparé, dans narration/_data/xdyn/ + "#{type}_#{id}.dyn.erb"

* Quand la page dynamique (.dyn.erb) de Narration est vide, il faut la réactualiser.

* Il faut soit :
  - mettre les pages narration dans une section spéciale pour pouvoir définir les H3 (premier niveau de titre) différemment
  - soit augmenter d'un le niveau de titre au traitement, mais il faudrait alors pouvoir le définir dans les options, pour que ça ne perturbe pas tous les textes.
  => Je pense que la première solution est la meilleure. Voir quels autres textes (analyse ?) il faut traiter de la même manière.

* [NARRATION - gros morceau] Implémenter et tester l'affichage d'une page de Narration (#138)

* Implémenter "analyse/collector" (collecteur d'analyse)

* Implémenter l'édition des textes quelconque par "admin/edit_text?path=..." (c'est ce qui est utilisé pour les exemples, par exemple)
* Implémenter l'édition d'une table des matières de livre narration
  Le lien est "admin/narration/<id livre>?op=edit_tdm"

* Écrire la partie charte du site (site/charte/main.erb)
* [BLOG] Implémenter et tester la rédaction/modification d'articles (admin/blog)
  (pour ça, il faut mettre en place la prise en compte de `op`, qui définit l'opération - par exemple "op=edit" pour éditer l'article spécifié dans `site.route.objet_id`)
  - S'assurer qu'un utilisateur lambda ne puisse pas atteindre cette partie
  - Faire des images (pas forcément en rapport avec l'article) pour le mettre entre le titre et l'article (soit de façon automatique soit en dur, à voir - de toute façon, si l'article est édité, on peut toujours le faire en l'enregistrant).

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
