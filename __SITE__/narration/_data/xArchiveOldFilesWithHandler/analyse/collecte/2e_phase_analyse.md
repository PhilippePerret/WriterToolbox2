<!-- Page: #138 Deuxième phase de l'analyse : la collecte -->

### Introduction

La deuxième phase de l'analyse, peut-être la plus longue et la plus fastidieuse, va consister en une collecte rigoureuse, quasi *archéologique*, de tous les éléments narratifs du film.

Cette collecte doit permettre :

* d'établir la MOT[122|structure générale] et fonctionnelle du film,
* d'établir la MOT[279|dynamique narrative],
* d'établir les MOT[203|fondamentales],
* de procéder à l'analyse proprement dite.

Procéder à cette collecte nécessite du temps. Mais si vous voulez procéder à une analyse rigoureuse, ne pas approcher artificiellement le film, si vous espérez ne pas tirer de conclusions oisives et hâtives, il est indispensable de prendre ce temps et de procéder à une relève minutieuse des éléments.


### Éléments à collecter

Dans cette collecte, les éléments suivants doivent être impérativement collectés (nous reviendrons sur chacun d'eux dans la suite) :

* liste des scènes,
* liste des personnages,
* liste des objectifs, obstacles et conflits,
* liste des brins,
* liste des préparations/paiements,
* liste des procédés,
* liste des thèmes,
* liste des décors.


### Nota bene préliminaire

Il est entendu, ci-dessous, qu'on a effectué un premier visionnage du film avant d'amorcer la collecte. Ce premier visionnage doit rester un plaisir avant tout, ne pas être gâté par un travail d'analyse.


#### Liste des scènes

L'objectif ici est d'obtenir un MOT[243|scénier] complet du film, c'est-à-dire une liste chronologique et complète de toutes les scènes du film, même les plus courtes, en indiquant avec soin les temps de début de chacune d'elle. Note : vous pouvez retirer le temps du pré-générique — présentation des productions — s'il ne concerne pas le récit lui-même. Ce pré-générique dure en général autour d'une minute. Vous pouvez également indiquer le temps de la première scène et retirer plus tard ce temps à toutes les “horloges” que vous aurez relevées.

Nota bene : c'est au cours de l'établissement de ce scénier qu'on peut procéder à la relève de tous les autres éléments cités plus haut, mais il est également possible d'effectuer la collecte en plusieurs temps.

La collecte d'une scène peut ressembler à cela :


DOC/rapport

2:10:23 INT. BUREAU JOUR
<%= user.pseudo %> prend son sac pour partir, mais il aperçoit par la fenêtre une jeune femme qui s'approche de sa voiture.
OBS #15.4 : Il sait qu'il ne peut pas sortir et encore moins rejoindre son véhicule. “Ils” ont retrouvé sa trace.
PROC #16 : Ironie dramatique sur la jeune femme. Elle ne sait pas que <%= user.pseudo %> l'a vue.
BRINS : 12, 23, 54

2:13:45 EXT. PARKING NUIT
...
/Extrait d'un document de collecte de scène
/DOC


#### Liste des personnages

Avant la collecte des scènes ci-dessus, on peut établir une liste complète des personnages principaux en prenant soin de relever leur patronyme exact. Si ce patronyme n'est pas précisé dans le film, on peut aller chercher ces informations sur l'<a href="http://www.imdb.com" target="_new">International Movie DataBase (IMDB)</a> ou d'autres sources d'informations.

Ensuite, pendant la collecte, on pourra préciser pour chaque personnage :

* ses fonctions générales dans le récit (MOT[8|protagoniste], MOT[16|antagoniste], MOT[13|adjuvant], etc.),
* son MOT[64|idiosyncrasie] et, notamment, ce qu'il a en propre par rapport aux autres personnages du film,
* sa façon de s'exprimer,
* les éléments remarquables qu'on peut noter le concernant, s'il y en a — un pouvoir particulier, une marque physique, un passé étonnant, etc.,
* la façon dont il est présenté à sa toute première apparition.

Pour connaitre les personnages présents dans les scènes, on peut se faciliter les choses en partant du principe qu'on indique toujours en capitales, au moins une fois, un personnage présent dans une scène. Par exemple :


DOC/events,scenario,synopsis,brut plain,rapport,procedure

0:01:12
<%= user.pseudo.upcase %> rencontre MATHIEU pour lui parler de Juliette. <%= user.pseudo %> explique qu'il doit la protéger.

/DOC

Dans la scène ci-dessus, personnage:<%= user.pseudo %> et personnage:Mathieu sont présents, mais personnage:Juliette n'est pas présente. La deuxième fois qu'on mentionne <%= user.pseudo %>, il est inutile de le remettre en capitales (les capitales attirent l'œil, il est bon de ne pas en abuser).

#### Liste des objectifs, obstacles et conflits

Relever la liste complète des MOT[10|objectifs] de *chaque personnage* en précisant leur nature (conscient/inconscient, concret/abstrait). Relever les MOT[202|moyens] qui sont utilisés pour atteindre ces objectifs, les MOT[83|obstacles] auxquels se confronte le personnage et donc les MOT[118|conflits] qui en résultent. Au cours de cette relève, on peut également préciser les MOT[49|enjeux].

Pour procéder de façon efficiente à cette relève, il est bon de numéroter chaque objectif — de lui donner un identifiant unique — afin de pouvoir y faire référence par la suite et d'y rapporter les obstacles et autres conflits.

Par exemple, le troisième objectif pourrait être désigné par : `OBJ #3`.

Les obstacles se rapportant à cet objectif reprendraient cet identifiant :

* 1<sup>er</sup> obstacle : `OBS #3.1` (signifie : obstacle 1 de l'objectif `#3`),
* 2<sup>e</sup> obstacle  : `OBS #3.2`,
* 3<sup>e</sup> obstacle :  `OBS #3.3`,
etc.

Comme pour les éléments suivants, vous avez deux moyens (au moins) de relever ces objectifs et ces obstacles :

* les relever dans la collecte des scènes,
* les relever dans un fichier à part.

Dans la collecte des scènes :

DOC/rapport
2:13:45 EXT. PARKING NUIT
<%= user.pseudo.upcase %> sort de l'ascenseur et avance […]
OBJ #45 : <%= user.pseudo %> va devoir tenter de rejoindre sa voiture sans être pris.
OBS #45.1 : La lumière du parking ne fonctionne plus, <%= user.pseudo %> se trouve dans le noir.
...
/Extrait du document de collecte des scènes
/DOC

Ou on peut tenir un document qui liste ces objectifs et ces obstacles à part en précisant les scènes :

DOC/rapport
OBJECTIF #45
<strong><%= user.pseudo.upcase %> va devoir tenter de rejoindre sa voiture sans être pris.</strong>
Implantation : 2:13:45
OBSTACLES :
\#1 : 2:13:45 La lumière du parking ne fonctionne plus, <%= user.pseudo %> se trouve dans le noir.
\#2 : 2:15:25 Les hommes en noir sont autour de son véhicule.
...
/Extrait du document de thèmes
/DOC


#### Liste des brins

Au fil de la collecte, on peut lister le plus de MOT[188|brins] possible. Comme les objectifs et les obstacles, on peut les numéroter dans leur ordre de relève. Un nouveau document contiendra la définition de tous les brins, qui pourra ressembler à :


DOC/rapport

BRIN #1
<strong><%= user.pseudo %></strong>
Ce brin concerne toutes les scènes où <%= user.pseudo %> est présent.

BRIN #2
<strong>Retrouver son frère</strong>
Ce brin concerne toutes les scènes de l'objectif principal de <%= user.pseudo %>.

BRIN #3
<strong>Relation entre <%= user.pseudo %> et Mathieu</strong>
Toutes les scènes qui concernent la relation entre <%= user.pseudo %>, le protagoniste, et Mathieu, son ancien prof de fac.

...
/Extrait du document de collecte de brins
/DOC


Dans la scène collectée, on peut indiquer les brins qui sont mis en jeu sur une ligne préfixée “BRINS” — cf. ci-dessus.

#### Liste des thèmes

On doit obtenir également une liste la plus complète possible des principaux MOT[112|thèmes] abordés dans le film, qu'on classera par ordre d'importance.

Pour chacun d'eux, on pourra indiquer ce que les auteurs en disent, comment ils le développent, comment ils insèrent l'antithèse de leur propos, comment ils s'en servent par rapport à leur MOT[94|prémisse] — si c'est le thème servant à établir la prémisse —, etc.

On pourra *identifier* chaque thème par un nombre afin d'y faire plus facilement référence dans la collecte des scènes : `THEME #1`, `THEME #2`, etc.

Là aussi, on peut soit indiquer le thème dans la collecte de la scène :

DOC/rapport
2:13:45 EXT. PARKING NUIT
<%= user.pseudo.upcase %> sort de l'ascenseur et avance […]
THEMES : #3, #6
...
/Extrait du document de collecte des scènes
/DOC

Ou on peut tenir un document qui liste ces thèmes à part en précisant les scènes :

DOC/rapport
THEME #3
<strong>L'exploitation des sous-sols</strong>
Le film exploite souvent les décors souterrains, parking, égouts, canalisations, etc.
SCÈNES : 5:45, 23:25, 1:12:00, 1:54:42, 2:13:45
...
/Extrait du document de thèmes
/DOC



#### Liste des procédés

Il va s'agir aussi pendant cette phase de collecte rigoureuse de relever le maximum de MOT[249|procédés narratifs] utilisés.

Dans les premiers temps de vos analyses, soyez particulièrement vigilant<%=user.f_e%> en ce qui concernent les MOT[95|préparations/paiements] ainsi que les MOT[19|ironies dramatiques] qui peuvent faire l'objet d'une liste séparée. Dans le cas contraire, vous pouvez *identifier* ces procédés par un préfixe différent :

* les préparations/paiements (`PP`),
* les ironies dramatiques (`IRDR`),
* les autres procédés (`PROC`).


Comme pour les éléments précédents, vous pouvez soit introduire ces éléments dans les scènes collectées, soit établir une liste séparée renvoyant aux scènes.

#### Liste des décors

La liste des décors peut tout à fait s'établir à la fin de la collecte des scènes. Il faut indiquer scrupuleusement s'il s'agit d'un lieu à l'extérieur, à l'intérieur ou les deux. On pourra préciser aussi pour chaque décor s'il est utilisé de jour, de nuit, ou les deux et en quelle proportion à peu près.


### Conclusion collecte

Forts de tous ces éléments qui nécessitent quelques heures de travail, nous pouvons passer à l'analyse proprement dite du film.

<webonly class="block">

Notez que si vous utilisez des outils tels que le <a href="analyse/collector">collecteur d’analyse</a>, cette collecte est grandement facilitée et vous pouvez d'ores et déjà obtenir de nombreuses données statistiques concernant le film analysé.

</webonly>
