* [UNAN][QUIZ]
  Les traitements à faire sont :
  - affichage du quiz (la toute première fois)
  - ré-affichage du quiz (après soumission)
  - ré-affichage du quiz (historique)
  - affichage des résultats du quiz
  * On enregistre les résultats non pas dans une table des quiz mais dans
  une table de :users_tables ("quiz_<id user>")
  * On utilise le module général qui permet de gérer les quiz
  On va simplifier énormément la gestion des quiz :
    - une seule BASE `boite-a-outils_quiz` (ne pas oublier de la créer sur AlwaysData)
    - les questions appartiennent à chacun des quiz. Si je prends une table, elle contiendra
      trop de questions et ça complique la démarche inutilement.
      L'important est de trouver la manière de faire, d'enregistrer les questions.
      QUESTION
        RÉPONSE ID        CONTENU    NB_POINTS   PERTINENCE   RAISON
                                                  0: false
                                                  1: juste
                                                  2: ni l'un ni l'autre
      Quelle couleur aimez-vous ?
        1   Bleu    12    0     C'est une couleur comme les autres
        2   Rouge   12    0     idem

      Qu'est-ce qui est important pour parvenir à écrire ?
        ID  CONTENU                 NB_POINTS       PERTINENCE        RAISON
        1   De travailler           50              1                 Sans travail, on ne parvient rien.
        2   De prendre du recul     10              2                 Oui il faut, mais pas trop
        3   D'attendre d'être prêt  0               0                 Si on attend, on ne fait rien.


* [UNAN]
  - Traiter l'affichage d'un quiz. Tout se joue dans la méthode 'div_travail' de l'affichage de la carte. Peut-être faut-il charger un sous-module propre pour les quiz.
  - Traiter l'affichage de l'historique. Rappelle : une adresse conduisant à l'historique est très simple : unanunscript/history/<id travail relatif>. En fonction du travail relatif, on peut afficher le travail, renvoyer vers narration, vers une page de cours, un message de forum ou un quiz.

* [UNAN]
  - Implémenter et tester unanunscript/page_cours/ qui permet de lire une page de cours du programme. S'inspirer très exactement de narration.
  - Tester l'affichage d'une page de cours (en prenant sur les dix jours ou sur le premier)

* [NARRATION]
  - Abandonner l'utilisation des handler et enregistrer les fichiers dans le dossier de leur livre avec leur identifiant.
  Exemple : la page d'ID #12 du livre Structure (donc du livre d'identifiant #1) doit être enregistré dans `narration/_data/1/12.erb`
    - faire un script qui transforme les pages actuelles
    - modifier la façon d'enregistrer les pages
    - supprimer la donnée handler

* [UNAN] Tester, tester, tester le réglage des travaux.
  - la création correcte des travaux relatifs lorsque l'on crée un auteur directement au 10e jour
  - le réglage correct, surtout, de la valeur `status` (avec des travaux qui seront à 2 et à 4)
  - ensuite il faut démarrer des travaux en dépassement, en grand dépassement et sans dépassement pour voir si les status se règlent bien.
  - Faire le test de l'enregistrement des jours de dépassement dans les options (7e à 9e bits) quand on arrête le travail (mais le status se met toujours à 9, quels que soient les dépassements qu'il y a pu avoir).
  [OK] le bouton "Démarrer ce travail" doit être en rouge (class 'red') si le travail est déjà en dépassement avant d'être démarré.
  - Tester l'affichage d'un travail qui contient tout (exemples, pages de cours suggérées, illustrations si ça existe, etc.). Il suffit de faire une recherche dans la base avec "exemples IS NOT NULL AND pages_cours_ids IS NOT NULL...", etc. puis de trouver le jour-programme qui utilise ce travail, et de caler l'auteur dessus. Dans ce test, on vérifiera bien tout, même le contenu exact des textes.
  Appeler ce test "contenu_complet_tache_spec.rb"
  - Tester : quand on marque un travail fini, et qu'on recharge la page, il ne faut
    pas finir à nouveau le travail, ce qui ajouterait encore le nombre de points
    (donc il faut s'assurer de faire le test avec une tâche qui donne des points).
  - Tester le compte de points total, en sachant qu'il semble y avoir une erreur : lorsque je pars au 10e jours, que je marque fini les travaux en dépassement (qui ne rapportent rien), et que je marque fini un travail à 100 points, le total arrive à 150…
  - Tester que lorsqu'un quiz est en tâche récemment accompli, ce n'est plus la marque "suivant résultat" qui est marqué mais le nombre de points gagnés.
  - Tester l'indication précise de points : si c'est un dépassement et que le nombre de points est inférieur au nombre que l'auteur aurait pu gagner, on lui indique la différence : "Sans dépassement d'échéance, vous auriez pu marquer xxx points."
  - Tester les liens pour ouvrir une page narration
  - Tester les liens pour ouvrir une page de cours du programme
  - Tester les liens pour ouvrir un Quiz
  - Tester que le nombre de tâches dans l'onglet corresponde bien au nombre de tâches réel (ça ne fonctionnait pas avant mais ça a été réglé en traitant les opérations avant de construire les onglets).
  - Tester la marque d'une page lue depuis la page quand c'est une page de cours UAUS : on démarre le travail, on rejoint la page de cours, on doit trouver le bouton pour marquer lue, on clique dessus, on doit revenir dans le bureau avec le bon message et la tâche marquée faite.

* [NARRATION]
  Voir une page comme la page #530 du livre #1 (problème de titres, problèmes de schéma dans un PRE)

* [UNAN] Utiliser le faux-tests _POUR_ESSAIS_LIVE_spec.rb pour rejoindre le programme comme un auteur et laisser la page ouverte une demi-heure.

* [UNAN] Pour l'affichage des travaux, il faut tester le type de la tâche pour faire le distingo entre une page Narration et une tâche réelle.
* [UNAN] Pour l'indication de l'échéance, mettre le mois en valeur humaine

* [UNAN] Tester le démarrage d'un travail
* [UNAN] Tester le rechargement d'une page après un démarrage d'un travail (rien ne doit se passer)
* [UNAN] Tester l'arrêt d'un travail
* [UNAN] Tester le rechargement d'une page après un arrêt de travail (rien ne doit se passer)
* [UNAN] Tester la valeur du nombre de points attribué à l'arrêt du travail
  - si le travail est fini dans les temps, total des points
  - si le travail est fini 3 jours après l'échéance, 3 * 10 points en moins. (attention, la valeur ne sera jamais juste juste)

* Régler le pied de page pour qu'il corresponde au statut du visiteur (pour le moment, le bouton "s'identifier" s'affiche même lorsque le visiteur est identifié)

* [UNAN] Implémenter et tester l'onglet 'Tâches'
  - Tester indépendamment, en unitaire, les méthodes du fichier taches/helpers.rb
    (relève des listes d'ids, des listes de taches, construction des listes)
  - Mettre en place le nouveau fonctionnement :
    * Il reste à implémenter la méthode qui va regarder le dernier pday d'actualisation des works relatifs (dans program.options[7..9]) et va lancer la procédure d'actualisation si nécessaire (Unan::Work.update_table_works_auteur(auteur, from_pday, to_pday)) avant d'afficher la liste des tâches.
* [UNAN] Implémenter et tester l'onglet 'Cours' ("Pages")
  Utiliser les mêmes modules que `taches`, mais se servir du type pour savoir que c'est une page à lire.
* [UNAN] Implémenter et tester l'onglet 'Quiz'
* [UNAN] Implémenter et tester l'onglet 'Forum'
* [UNAN] Implémenter et tester l'onglet 'Aide'
* [UNAN] Dans la partie 'Programme', peut-être faire apparaitre l'état des lieux, c'est-à-dire avec les tâches faites et non faites.

* Implémenter la console et commencer par une commande qui permette de créer un auteur pour le programme UN AN UN SCRIPT, et qui renvoie le mail et le mot de passe pour se connecter. La méthode enregistre aussi un ticket pour détruire cet utilisateur (ou recharger tout simplement toutes les données de la base UAUS).
  Cette méthode doit tout simplement utiliser le support des tests pour unanunscript.

* Implémenter dans le profil le choix de la redirection après login (cf. le fichier `./__SITE__/user/signin/main.rb` où est défini la méthode `redirect_after_login` qui gère cette redirection)

* Pour le lien administration (pour administrateur), ajouter toujours la partie où on se trouve (site.route.objet) pour diriger le mieux possible.

* Reprendre la liste complète des outils (outils/main.erb)

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

* Implémenter "analyse/collector" (collecteur d'analyse)

* Implémenter le profil de l'utilisateur

* Implémenter l'édition d'une table des matières de livre narration
  Le lien est "admin/narration/<id livre>?op=edit_tdm"

* Écrire la partie charte du site (site/charte/main.erb)
* [BLOG] Implémenter et tester la rédaction/modification d'articles (admin/blog)
  (pour ça, il faut mettre en place la prise en compte de `op`, qui définit l'opération - par exemple "op=edit" pour éditer l'article spécifié dans `site.route.objet_id`)
  - S'assurer qu'un utilisateur lambda ne puisse pas atteindre cette partie
  - Faire des images (pas forcément en rapport avec l'article) pour le mettre entre le titre et l'article (soit de façon automatique soit en dur, à voir - de toute façon, si l'article est édité, on peut toujours le faire en l'enregistrant).

* Implémenter la variable session 'back_to_after_login' qui va permettre d'être redirigé vers la page voulue au départ après une redirection pour signin. En fait, cette variable peut être implémentée dans la méthode redirect_to à partir du moment où la route est "user/signin"

* [UNAUN] Ajouter "Par où commencer ?" dans la page de paiement OK et parler du bureau et de l'aide qu'on peut télécharger.

* On pourrait imaginer un module qui contienne/définisse toutes les opérations ticket, par exemple User#confirm_mail afin de ne pas avoir une méthode qui ne serve qu'une seule fois.
  * => Mettre en place la gestion des tickets

* Ajouter un lien "mot de passe oublié"

* Mettre en place et tester le FORUM
  * La première page doit expliquer que le forum fonctionnement commme les forums techniques.

* SCENODICO
  * ajouter la recherche d'un mot (dans les définitions)

* [UAUS] À la destruction ou à l'arrêt d'un programme UN AN UN SCRIPT, penser à supprimer la variable 'unan_program_id' de l'user (`user.var['unan_program_id'] = nil`)

* [UAUS] Implémenter la pastille pour le programme, indiquant les tâches en retard, etc. Il faut la mettre lorsque les options du programme contiennent 1 en 6e bit (donc option [5])
