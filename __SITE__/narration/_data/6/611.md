<!-- Page: #611 Gestion des versions du projet -->

Savoir gérer les versions d'un projet est important pour suivre au mieux son développement,  toujours savoir là où l'on en est, et transmettre aux différents intervenants des documents à jour.

Dans l'idéal, chaque version de développement devrait posséder son propre objectif, sa propre ligne directrice, mais on constate que le développement d'un projet se fait de façon très empirique, chaque auteur se faisant sa propre idée du *versionnage* de son histoire. Nous essayerons cependant de dégager ici quelques grands axes qui pourront permettre de versionner son travail le plus efficacement et le plus judicieusement possible.

### Suite arithmétique

En matière de projet d'écriture, les versions sont en général désignées par un seul entier. On parle de version 1, de version 2, de version 3, etc. 

On verra qu'il peut être parfois intéressant d'utiliser des subdivisions (version 1.6.4, version 5.4, etc.) ou même des noms plus “humains”.

### Le premier jet

Le tout premier jet du projet, son tout premier développement, peut porter l'indice 0. C'est la “version 0” du projet, celle qui permet d'en établir les prémices, d'en rédiger la première *mouture*, sous forme de synopsis par exemple. Cette version 0 est censée ne jamais sortir de l'ordinateur de son auteur.


### Quand changer de version ?

Il n'est pas forcément aisé de dire à partir de quel moment exact on doit changer de numéro de version. On change normalement de version lorsque :

* on est arrivé au bout d'un traitement particulier. C'est ce que nous appellerons ci-dessous la “fin du traitement”,
* un nouveau traitement s'impose, même avant la fin d'un traitement.

La première fin de traitement qu'on peut rencontrer consiste en la première version complète du scénario ou du manuscrit. Lorsque le premier jet est établi, on peut encore procéder à de petits ajustements, quelques petites corrections, puis on peut passer à la version 1.

Cette *fin du traitement*, ça peut être aussi une révision complète, une refonte entière de la structure. Elle commence alors avec un nouveau numéro de version et lorsque cette refonte est achevée, lorsque tous les éléments ont été modifiés pour tenir compte des modifications préconisées, on peut passer à une nouvelle version.

Un *nouveau traitement*, lui, peut s'amorcer avant même la fin d'un traitement. Il peut survenir, par exemple, lorsqu'un producteur a été trouvé, intéressé par le projet. On entre alors dans une nouvelle phase du développement qu'il faut inaugurer par un tout nouveau numéro de version. Si l'on en était à la version 4, même inachevée, on passe à la version 5 qu'on initie avec un nouveau dossier :

`MON_PROJET/VERSIONS/Version_5/`

On peut même, pour plus de clarté, ajouter à ce nom de version un suffixe abrégé indiquant la production avec laquelle cette version a été établie :

`MON_PROJET/VERSIONS/Version_5-RocFilm/`

Noter cependant que ce nom de version ne doit pas apparaitre dans les noms des fichiers à usage externe. Il doit être exclusivement réservé à l'usage interne, c'est-à-dire seulement avec les coauteurs.

Un changement de production, évidemment, inaugurera de la même manière une nouvelle version.


### Les documents transmis “à l'extérieur”

Lorsque le projet en arrive à des versions *lisibles*, c'est-à-dire des versions qui peuvent être présentées aux producteurs ou aux éditeurs, aux organismes de subvention, on commence à produire des `PDF` (les documents au format PDF — Portable Document File — ont cet avantage de conserver la mise en forme d'un système d'exploitation à un autre et de ne pas pouvoir être modifiés avec les outils d'édition habituels).

Nous avons déjà parlé de la façon de nommer ces fichiers, qui doivent avoir impérativement un autre nom que celui employé au sein du développement. Si, dans le dossier du développement, un fichier peut s'appeler `Rectif_personnages.odt`, il ne peut pas s'appeler de cette façon si on l'envoie “à l'extérieur”. Il doit porter au minimum le titre du projet — abrégé si nécessaire — et la nature du document.

Pour l'envoyer, on enregistrera le document PDF dans le dossier “Envois” que nous avons créé à la racine du *dossier du projet*. Si l'on est particulièrement organisé et que l'on a envie de toujours se souvenir de ce que l'on a fait, on peut indiquer dans un fichier séparé le document original qui a permis de produire ce document PDF.

Imaginons que nous ayons un synopsis qui se trouve à cet endroit dans notre dossier de projet :

`MON_PROJET/VERSIONS/Version_6-Duralex/161125/Synopsis.odt`

Je crée le fichier `PDF` et je le place dans le dossier `Envois` :

`MON_PROJET/Envois/Version_6/Synopsis.pdf`

Noter que j'ai créé un dossier pour la version 6 dans mon dossier d'envois, pour plus de clarté.

Il faut maintenant que je renomme ce fichier car il est impossible d'envoyer “à l'extérieur” un document qui se nommerait `Synopsis.pdf`. Selon les conventions proposées ici, il s'appellera :

`MON_PROJET_Synopsis_v6-nov-2016.pdf`

Afin, plus tard, de pouvoir savoir à quel fichier se rapporte ce PDF, je vais créer un petit fichier en texte simple qui va :

* porter le même nom que le fichier PDF mais avec l'extension `txt` (un fichier en texte simple),
* contenir dans son texte le chemin d'accès au fichier dont est issu le PDF,
* contenir le nom des personnes à qui il a été transmis.

On va donc créer le fichier :

`MON_PROJET/Envois/Version_6/MON_PROJET_Synopsis_v6-nov-2016.txt`

… et copier à l'intérieur :


DOC/brut

Le PDF de même nom a été établi d'après le fichier : 

    VERSIONS/Version_6/161125/Synopsis.odt

Il a été transmis à :

    Henriette Vallemin (productrice)
    Son assistant
    Bernard C. (pour avis général)

/DOC


De cette manière, on pourra toujours savoir de quel original a été issu un document et à qui il a été transmis. Si le même document est envoyé à une autre personne, elle sera ajoutée à la liste ci-dessus.

Croyez-le : sans ces mesures de prudence, vous ne vous souviendrez bientôt plus à qui vous avez envoyé tel ou tel fichier. Et faites-le dès le tout premier document, même quand vous donneriez votre main à couper que vous n'enverrez ce document à personne d'autre. Vous pouvez vous couper la main dès à présent (c'est une métaphore, bien entendu).


### Les documents de sous-version

Il est fréquent — pour ne pas dire systématique — qu'un document qu'on envoie ait à subir des modifications mineures, à commencer par des corrections orthographiques ou de mise en forme.

Il est vivement conseillé d'incrémenter toujours la version d'un document lorsqu'il est corrigé, même pour une simple virgule, et ce à partir du moment où ce document a été envoyé (tant que le document n'a pas été transmis, il serait idiot de changer de version).

> Toujours incrémenter la version d'un document, même pour une simple virgule.

Imaginons par exemple que nous ayons déjà envoyé à la production notre document `MON_PROJET_Synopsis_v6-nov-2016.pdf` ci-dessus et que l'on s'aperçoive que l'on a oublié le pied de page contenant les numéros de page, le nom des auteurs et le numéro de version.

Puisque nous avons déjà transmis ce document, nous devons en créer un nouveau qui portera un nouveau numéro de version. Mais il serait idiot de passer à la version 7 simplement parce que nous avons ajouté un pied de page. Nous allons plutôt utiliser une subdivision.

Nous nommerons donc cette nouvelle version : 

`MON_PROJET_Synopsis_v6-1-2-dec-2016.pdf`. 

En d'autres termes, il s'agira de la version `6.1.2`.

### Trois niveaux de chiffrage

Pour établir ce numéro, nous avons utilisé trois niveaux de chiffrage :

* l'indice de la version,
* l'indice de la sous-version,
* l'indice de la correction.

Ici, puisque nous avons effectué une correction somme toute mineure, une simple *correction*, nous modifions logiquement l'*indice de correction*.

### Numéro par défaut

Ci-dessus, nous avons vu que nous étions passés d'une version `6` à une version suivante numérotée `6.1.2`.

Il faut comprendre que par défaut, l'indice de sous-version et l'indice de correction valent toujours `1`. Si l'on parle de la version `6`, il s'agit de la version `6.1.1`. Si l'on parle de la version `5.2`, il s'agit en réalité de la version `5.2.1`. Le numéro *absent* vaut toujours `1`. 

### Numérotation des corrections

En relisant le document, nous relevons des fautes d'orthographe. Le premier auteur en corrige certaines, produisant le document :

`MON_PROJET_Synopsis_v6-1-3-dec-2016.pdf`

Détail : la version précédente était la `6.1.2`, nous passons à la `6.1.3`.

La coauteure en corrige d'autres ensuite, produisant finalement le document :

`MON_PROJET_Synopsis_v6-1-4-dec-2016.pdf`.

Détail : la version précédente était la `6.1.3`, nous passons à la `6.1.4`.

Quelques temps plus tard, le producteur demande de supprimer toute une partie du document. On peut alors considérer qu'il s'agit d'une nouvelle sous-version. La version précédente étant la `6.1.4`, nous passons à la `6.2`. Le document portera donc le nom :

`MON_PROJET_Synopsis_v6-2-jan-2017.pdf`.

Une majuscule a été oubliée dans ce document, il s'appellera maintenant :

`MON_PROJET_Synopsis_v6-2-2-jan-2017.pdf`.

Détail : la version précédente était la  `6.2` (sous-entendu : `6.2.1`), nous passons avec cette correction à la version  `6.2.2`.

Et ainsi de suite, la moindre correction entrainant toujours une nouvelle version, nouvelle version qui ne manquera pas, bien sûr, d'être transmise à tous les coauteurs pour qu'ils aient toujours la dernière version. 

Cette façon de procéder est la seule manière d'être certain de connaitre le document le plus à jour et de savoir quel fichier a été envoyé à quelle personne.

Dans le cas contraire, nous pouvons vous assurer beaucoup de déconvenues et de pertes de temps en recherches et relectures inutiles de vos documents. Sans parler de l'incertitude que vous développerez quant à la validité de ces mêmes documents.