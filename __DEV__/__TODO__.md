
* Tester le message afficher dans le formulaire UN AN UN SCRIPT en fonction du fait que l'user est déjà abonné au site ou non (cela doit se faire dans signup/Suscriber_spec et signup/signup_spec)

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
