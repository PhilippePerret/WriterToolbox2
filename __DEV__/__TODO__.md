* Pour le lien administration (pour administrateur), ajouter toujours la partie où on se trouve (site.route.objet) pour diriger le mieux possible.

* régler le problème du <auteur>...</auteur> qui passe à la ligne.
  * essayer de le régler en soi, ou
  * au lieu de corriger "auteur:|l'auteur|" par "<auteur>l'auteur</auteur>", utiliser un span :
  "<span class='auteur'>l'auteur</span>"
    Faire quand même une recherche pour voir s'il y a des <auteur> (et autres <personnages>, je suis sûr qu'il y en a)

* SCENODICO
  * ajouter le listing des mots
  * ajouter la recherche d'un mot
  * ajouter l'édition d'un mot (admin/scenodico/xxx?op=edit_mot, admin/scenodico/xxx?op=edit_categorie)

* Documenter la classe .fiche
  fiche.cadre.label-medium/label-large/label-small
  div     .main .mg2/4/6 .small .nodeco (supprimer la déco des liens)
    label
    div.value
* Mettre un lien pour voir le mot suivant/précédent ?

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

* Implémenter l'édition d'une table des matières de livre narration
  Le lien est "admin/narration/<id livre>?op=edit_tdm"

* Écrire la partie charte du site (site/charte/main.erb)
* [BLOG] Implémenter et tester la rédaction/modification d'articles (admin/blog)
  (pour ça, il faut mettre en place la prise en compte de `op`, qui définit l'opération - par exemple "op=edit" pour éditer l'article spécifié dans `site.route.objet_id`)
  - S'assurer qu'un utilisateur lambda ne puisse pas atteindre cette partie
  - Faire des images (pas forcément en rapport avec l'article) pour le mettre entre le titre et l'article (soit de façon automatique soit en dur, à voir - de toute façon, si l'article est édité, on peut toujours le faire en l'enregistrant).


* [UNAUN] Ajouter "Par où commencer ?" dans la page de paiement OK et parler du bureau et de l'aide qu'on peut télécharger.

* On pourrait imaginer un module qui contienne/définisse toutes les opérations ticket, par exemple User#confirm_mail afin de ne pas avoir une méthode qui ne serve qu'une seule fois.
  * => Mettre en place la gestion des tickets

* Ajouter un lien "mot de passe oublié"

* Mettre en place et tester le FORUM
  * La première page doit expliquer que le forum fonctionnement commme les forums techniques.
