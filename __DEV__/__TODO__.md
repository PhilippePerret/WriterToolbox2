
* Mettre en place la gestion des mails - poursuivre les tests
* Poursuivre le test de l'inscription

* RÉFLÉCHIR À ÇA :

  En général, le résultat d'une opération amène sur une autre page. Par exemple, lorsqu'on s'inscrit, on aboutit sur la page de confirmation de l'inscription.
  Pour le moment, c'est une fois que l'opération a réussi qu'on est redirigé vers la page.
  Or, il pourrait être plus simple de rediriger directement vers l'autre page où serait effectuée l'opération
  Par exemple pour l'instant l'inscription se passe ainsi :
    - l'user arrive sur le formulaire (user/signup)
    - il soumet le formulaire qui est traité dans user/signup
    - si son inscription est valide, il est redirigé vers user/confirm_signup
  Au lieu de ça, on pourrait avoir :
    - l'user arrive sur le formulaire (user/signup)
    - lorsqu'il soumet le formulaire, il est dirigé vers user/create
    - Si ça réussit, on affiche la page en question (user/create/main.erb)
    - Si ça échoue, on le redirige vers user/signup
  OUAIS… Mais pour ce cas précis, c'est dans user/signup qu'il faut afficher
  la confirmation de l'inscription, selon le principe que toutes les choses qui
  concernent la même chose se trouvent au même endroit.


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
