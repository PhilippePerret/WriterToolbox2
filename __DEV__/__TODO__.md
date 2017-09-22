* [UNAN][TACHES]
  - Bien mettre en exergue le nombre de jours restants, quand on n'est pas en dépassement (dans un  
    cadre noir avec lettres blanches)- pour le moment, l'indication est entre parenthèses.
  - [BUG] Voir pourquoi le bouton "Marquer ce travail fini" est en rouge, même lorsque c'est un travail qui n'est pas en dépassement.

* [UNAN] Reprendre les calculs de dépassement en se servant de la données `expected_at` ajouté aux travaux relatifs.

* [UNAN] Tenir compte du fait que le statut (status) peut être à 2 ou 4 quand le travail n'est pas démarré.
* [UNAN] Quand on démarre un travail, il faut ajouter 1 au statut (status), ne pas le mettre à 1, car il peut y avoir déjà des dépassements.
* [UNAN] Pour l'affichage du travail, tenir compte du fait que le travail peut être en dépassement même lorsqu'il n'est pas démarré. L'indiquer visuellement, peut-être en ajoutant le cadre de dépassement.
* [UNAN] À la terminaison du travail, penser à régler les options pour qu'elles conserve le nombre de jours de dépassement s'il y en a.

* [UNAN] Tester, tester, tester le réglage des travaux.
  - la création correcte des travaux relatifs lorsque l'on crée un auteur directement au 10e jour
  - le réglage correct, surtout, de la valeur `status` (avec des travaux qui seront à 2 et à 4)
  - ensuite il faut démarrer des travaux en dépassement, en grand dépassement et sans dépassement pour voir si les status se règlent bien.
  - Faire le test de l'enregistrement des jours de dépassement dans les options (7e à 9e bits) quand on arrête le travail (mais le status se met toujours à 9, quels que soient les dépassements qu'il y a pu avoir).
  [OK] le bouton "Démarrer ce travail" doit être en rouge (class 'red') si le travail est déjà en dépassement avant d'être démarré.
  - Tester l'affichage d'un travail qui contient tout (exemples, pages de cours suggérées, illustrations si ça existe, etc.). Il suffit de faire une recherche dans la base avec "exemples IS NOT NULL AND pages_cours_ids IS NOT NULL...", etc. puis de trouver le jour-programme qui utilise ce travail, et de caler l'auteur dessus. Dans ce test, on vérifiera bien tout, même le contenu exact des textes.
  Appeler ce test "contenu_complet_tache_spec.rb"

* [UNAN] Pour l'indication des points pour les quiz, il faudrait mettre "en fonction du résultat".

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
