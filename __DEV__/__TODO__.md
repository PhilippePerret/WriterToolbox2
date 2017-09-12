
* Poursuivre l'implémentation testé du bureau UN AN
  - Mettre en forme pour qu'il n'y ait pas autant de marge à gauche
  - Installer chaque dossier d'onglet et le faire travailler de façon autonome.

* Implémenter la console et commencer par une commande qui permette de créer un auteur pour le programme UN AN UN SCRIPT, et qui renvoie le mail et le mot de passe pour se connecter. La méthode enregistre aussi un ticket pour détruire cet utilisateur (ou recharger tout simplement toutes les données de la base UAUS).

* Implémenter dans le bureau le choix de la redirection après login (cf. le fichier `./__SITE__/user/signin/main.rb` où est défini la méthode `redirect_after_login` qui gère cette redirection)

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
