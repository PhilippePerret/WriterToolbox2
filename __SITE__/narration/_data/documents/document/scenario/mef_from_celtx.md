<!-- Page: 223 Mise en forme du scénario depuis CeltX -->

[CeltX](http://www.celtx.com) est un logiciel libre très pratique pour écrire son scénario, qui réduit le travail de mise en forme à la simple — et géniale — utilisation des touches retour de chariot (IMAGE[clavier/K_Entree.png|inline]) et tabulation (IMAGE[clavier/K_Tab.png|inline]).

Cependant, le logiciel étant américain, la mise en forme n'est pas adaptée à l'usage hexagonal et les lecteurs français peuvent être heurtés par la présentation en police “`Courier`”.

Cette page décrit le moyen de mettre en forme votre scénario pour une utilisation française, à l'aide de CeltX et de [LibreOffice](http://fr.libreoffice.org/), un autre logiciel libre. 

Dans une première partie, on présente la version abrégée, rapide, de la procédure, pour ceux qui l'ont déjà suivie en détail ou qui maitrisent parfaitement les deux logiciels requis. Dans une seconde partie, on reprend la procédure en détail.

### Méthode abrégée


DOC/procedure
action: Exporter le scénario CeltX (`.celtx`) au format HTML.
resultat: Un document `.html` est produit.
action: Ouvrir le scénario exporté `.html` dans LibreOffice et l'enregistrer au format ODF.
resultat: Un document `.odt` est produit.
action: Modifier les feuilles de styles ou charger les styles d'un scénario existant.
action: Enregistrer, imprimer ou exporter une version PDF du nouveau document.
resultat: Un document `.pdf` est produit.
/DOC


### Méthode détaillée

#### Produire le document ODF

DOC/procedure
main_action: Exporter le scénario CeltX en HTML
action: Ouvrir le scénario CeltX (dans CeltX évidemment, où il a dû être travaillé).
action: Choisir l'onglet “Scénario”, s'il n'est pas sélectionné, en bas de la fenêtre, à côté de “Mise en forme”.
action: Activer le menu “Scénario > Exporter le scénario…”.
resultat: La fenêtre d'export s'ouvre.
action: Choisir le format HTML.
action: Enregistrer le fichier.
note: Bien choisir l'emplacement pour que le nouveau fichier `.html` soit enregistré au même endroit que le scénario CeltX (qui doit porter l'extension `.celtx`).
note: Par la suite, j'appellerai le document `.html` :  “Scénario HTML”.

main_action: Transformer le scénario HTML en scénario ODF (LibreOffice).
action: Ouvrir le `scénario HTML` (le fichier que nous venons de créer à partir du fichier CeltX) dans LibreOffice en passant par le menu “Fichier > Ouvrir…”.
note: Il faut impérativement passer par le menu “Fichier > Ouvrir…” pour exécuter cette opération.
action: Enregistrer le scénario HTML au format ODF (`.odt`, le format naturel de LibreOffice).
/DOC


À partir d'ici, vous devez avoir dans le dossier de votre scénario CeltX :

* le scénario CeltX original (`monScenario.celtx`) ;
* le scénario HTML exporté (`monScenario.html`) ;
* le scénario ODF enregistré (`monScenario.odt`).

S'il vous manque un de ces trois documents, c'est que :

* vous avez manqué une étape ci-dessus,
* vous n'avez pas enregistré les différents documents produits *dans le même dossier que le scénario CeltX original*.

Il ne vous reste plus alors qu'à recommencer l'opération ou à déplacer les fichiers vers le bon dossier.

#### Modifier les styles

Au point où nous en sommes, si vous parcourez votre document scénario dans LibreOffice, vous vous apercevrez que le formatage n'est pas bon. Nous allons modifier les styles pour pallier ce problème. 

Notez que cette modification ne sera à faire qu'une seule fois. Pour votre prochain scénario, il suffira de *charger* les styles que vous allez modifier.

<webonly>
<em>Bien sûr, je pourrais me contenter de fournir un document à télécharger, contenant les feuilles de styles d'un scénario, mais il est plus intéressant pour l'auteur de se familiariser avec la création des styles. Il y gagnera beaucoup dans son travail quotidien.</em>
</webonly>

Il va falloir ensuite redéfinir le style de chaque élément du scénario. En sachant que :

* les marges des pages doivent être modifiées,
* le style dont tous les autres découlent est le style “Standard” (ou “Style par défaut”),
* l'intitulé de scène s'appelle “Corps de texte.sceneheading” (c'est le “sceneheading” — intitulé de scène — qui est important ici),
* les actions/descriptions sont dans le style “Corps de texte.action” (ou simplement “Corps de texte”),
* les noms de personnage des dialogues sont dans le style “Corps de texte.character”,
* les dialogues sont dans le style “Corps de text.dialog”,
* les notes de jeu (entre le nom du personnage et son dialogue) sont dans le style “Corps de texte.parenthetical”.

#### Le nom des styles

On pourrait modifier le nom de ces styles pour qu'ils soient plus simples et plus lisibles, mais cela empêcherait d'utiliser ce réglage pour tous les autres scénarios à formater par la suite.

En effet, une fois que nous aurons réglé les caractéristiques des styles de ce document, il nous servira pour reformater rapidement tous nos scénarios suivants, simplement en rechargeant les styles de notre document. Seulement, si le nom du style s'appelle “Corps de texte.dialog” et que nous le renommons “Dialogues” ici, voyons ce qui se passera.

Pour l'exemple, nous appellerons “`doc_avec_styles.odt`” le document présent, qui contiendra tous les styles bien reformatés. Nous appellerons “`doc_a_formater.odt`” le prochain scénario qui devrait être reformaté.

DOC/procedure plain

main_action: Remplacement du nom “Corps de texte.dialog” par “Dialogues”
action: Dans “`doc_avec_styles.odt`”, nous changeons le nom “Corps de texte.dialog” en “Dialogues”
resultat: Le style “Corps de texte.dialog” n'existe plus dans le document “`doc_avec_styles.odt`”.

PLUS TARD
-----------------

main_action: Nous voulons formater notre document “`doc_a_formater.odt`”.
action: Nous ouvrons le document “`doc_a_formater.odt`”.
note: Nous allons donc remplacer ses styles mal formatés par les styles bien formatés du document “`doc_avec_styles.odt`”.
action: Nous chargeons les styles du document “`doc_avec_styles.odt`” dans le document “`doc_a_formater.odt`”.
resultat: Comme le style “Corps de texte.dialog” n'existe plus dans “`doc_avec_styles.odt`” (il a été renommé), il ne peut pas venir écraser le style de même nom du document “`doc_a_formater.odt`”. Donc le style “Corps de texte.dialog” du document “`doc_a_formater.odt`” n'est pas du tout modifié.
/DOC

En revanche, si nous conservons le même nom de style, le style “Corps de texte.dialog” du document “`doc_a_formater.odt`” (mal formaté) sera *écrasé* et *remplacé* par le style “Corps de texte.dialog” du document “`doc_avec_styles.odt`” (bien formaté), simplement parce qu'ils ont exactement le même nom.

C'est le principe de l'écrasement : un style ne peut remplacer (écraser) qu'un style de même nom. Voilà pourquoi il faut conserver le nom des styles tels qu'ils sont.

#### Caractéristiques à appliquer

Nous allons commencer par régler les marges des pages.

DOC/procedure plain
main_action: Régler la largeur des marges
action: Activer le menu “Format > Page…”.
resultat: La boite de dialogue “Style de page” s'ouvre.
action: Activer l'onglet “Page”.
action: Régler les quatre marges à 2cm.
action: Cliquer sur le bouton “OK”.
resultat: La boite de dialogue se referme et les marges se règlent.
/DOC

Ensuite, nous allons définir la police et la taille de police qui seront appliquées à tous les styles du scénario, en modifiant le style parent `Standard`.

DOC/procedure
main_action: Régler la police et la taille standard
action: Afficher si nécessaire la boite des styles par le menu “Styles > Styles et formatage”.
resultat: La boite des styles s'affiche.
action: En bas de la boite des “Styles et formatage”, s'assurer que le menu “Styles appliqués” est bien sélectionné.
resultat: La liste des styles appliqués dans le document courant doit être affichée.
action: Dans la boite des styles, effectuer un clic droit (clic + CTRL sur Apple) sur le nom du style `Standard` (ou `Style par défaut`).
resultat: Un menu contextuel s'affiche.
action: Choisir le menu “Modifier…” dans le menu contextuel.
resultat: La fenêtre du style de paragraphe s'ouvre.
note: Le titre de la fenêtre doit contenir “Standard” : “Style de paragraphe : Standard” (ou “Style de paragraphe : Style par défaut”).
action: Activer l'onglet “Police”.
resultat: L'onglet “Police” s'affiche.
action: Choisir la police “Geneva”.
note: On peut choisir aussi la police Helvetica ou Arial.
action: Choisir la taille de police “12pt”.
action: Cliquer sur le bouton “OK” de la fenêtre d'édition du style.
resultat: Le style “Standard” (ou `Style par défaut`) a été modifié, modifiant l'aspect général du scénario au niveau des polices et de la taille du texte.
/DOC

Nous allons voir maintenant en détail la procédure pour modifier le premier style — intitulé — puis, ensuite, seules seront données les valeurs à attribuer aux autres styles, qu'il conviendra de modifier de la même façon.

DOC/procedure
main_action: Réglage du style des intitulés
action: Dans la boite des styles, effectuer un clic droit (clic + CTRL sur Apple) sur le nom du style `Corps de texte.sceneheading`.
resultat: Un menu contextuel s'affiche.
action: Dans le menu contextuel, choisir “Modifier…”.
resultat: La fenêtre du style de paragraphe s'ouvre.
action: Activer l'onglet “Gestionnaire”.
action: Choisir le style `Corps de texte.action` (ou simplement `Corps de texte`) dans le menu “Style de suite”.
resultat: Cela définit que le style de suite sera une action <sup>(*)</sup>.
action: Activer l'onglet “Numérotation” (ou “Plan & numérotation”).
action: Choisir la numérotation “Numérotation 1” (ou autre, à volonté).
resultat: Cela permettra de régler l'aspect de la numérotation des intitulés.
action: Activer l'onglet “Effets de caractère”.
action: Choisir “Majuscules” dans le menu “Effets”.
resultat: Tous les intitulés seront en majuscules, comme il se doit.
action: Activer l'onglet “Police”.
action: Choisir “Gras”.
resultat: Les intitulés seront en gras, comme les noms de personnage des dialogues.
action: Activer l'onglet “Enchainements”.
action: Cocher la case “Conserver avec le paragraphe suivant”.
resultat: Cela empêchera d'avoir un intitulé en dernière ligne de la page, en bas.
action: Cliquer le bouton “OK” pour enregistrer les modifications.
resultat: La boite de dialogue se referme et les styles s'appliquent à tous les intitulés du scénario.
/DOC

<div class='small'>(*) Cela n'est pas indispensable pour reformater un scénario, mais si l'on poursuit le travail d'écriture sur ce document LibreOffice au lieu du document CeltX, ce réglage facilitera le travail : après avoir écrit un intitulé de scène, le style suivant passera automatiquement au style des actions/descriptions sans qu'on ait à le choisir.</div>

Nous présentons à présent les valeurs à attribuer aux autres styles qu'il conviendra de modifier en suivant la même procédure.

DOC/brut plain

<strong>Style des actions et descriptions</strong>

Nom : `Corps de texte.action` (ou `Corps de texte`)

<u>Onglet “Gestionnaire”</u>

Style de suite : Corps de texte.action (ou `Corps de texte`)

<u>Onglet “Retraits et espacement”</u>

Avant le texte           : 1,30cm
Au-dessus du paragraphe  : 0,50cm
Sous le paragraphe : 0cm

<u>Onglet “Alignement”</u>

Options : Justifié.

<u>Onglet “Enchainements”</u>

Traitement des orphelines         : coché
Traitement des veuves             : coché

/DOC



DOC/brut plain

<strong>Style des noms de personnage de dialogues</strong>

Nom : Corps de texte.character

<u>Onglet “Gestionnaire”</u>

Style de suite : Corps de texte.dialog

<u>Onglet “Retraits et espacement”</u>

Avant le texte           : 6cm
Au-dessus du paragraphe  : 0,50cm
Sous le paragraphe : 0cm

<u>Onglet “Police”</u>

Style : Gras

<u>Onglet “Effets de caractère”</u>

Effets : Majuscules

<u>Onglet “Enchainements”</u>

Conserver avec paragraphe suivant : coché

/DOC

DOC/brut plain

<strong>Style des notes de jeu (dialogues)</strong>

Nom : Corps de texte.parenthetical

<u>Onglet “Gestionnaire”</u>

Style de suite : Corps de texte.dialog

<u>Onglet “Police”</u>

Style : Italique

<u>Onglet “Retraits et espacement”</u>

Avant le texte           : 6cm
Après le texte           : 5cm
Au-dessus du paragraphe  : 0cm
Sous le paragraphe : 0cm

<u>Onglet “Enchainements”</u>

Conserver avec paragraphe suivant : coché


/DOC


DOC/brut plain

<strong>Style des notes de jeu (dialogues)</strong>

Nom : Corps de texte.dialog

<u>Onglet “Gestionnaire”</u>

Style de suite : Corps de texte.dialog

<u>Onglet “Retraits et espacement”</u>

Avant le texte           : 4cm
Après le texte           : 5cm
Au-dessus du paragraphe  : 0cm
Sous le paragraphe : 0cm

<u>Onglet “Enchainements”</u>

Traitement des orphelines         : coché
Traitement des veuves             : coché

/DOC



### Rechargement de styles

Si vous possédez déjà un document scénario possédant les styles formatés, vous pouvez les charger facilement dans votre nouveau scénario en suivant la procédure suivante.

DOC/procedure
action: Ouvrir le document `.odt` dans LibreOffice.
action: Ouvrir la boite des styles — si elle n'est pas affichée — en jouant le menu “Styles > Styles et Formatage”.
resultat: La boite des styles s'affiche.
action: Dans le menu en haut à droite de la boite de styles (un petit carré avec une coche verte), choisir “Charger les styles…”.
resultat: La boite de dialogue “Charger les styles” s'ouvre.
action: Dans la boite “Charger les styles”, cocher la case “Écraser”.
note: Si vous ne cochez pas cette case, au lieu d'*écraser* — c'est-à-dire de *remplacer* — les styles présents dans votre document, LibreOffice chargera les styles en modifiant leur nom, ce qui ne produira aucun effet sur le scénario. Par exemple, le style “`Corps de texte.dialog`” deviendra “`Corps de texte.dialog 2`” en laissant le style “`Corps de texte.dialog`” inchangé. Au contraire, si la case est cochée, le style “`Corps de texte.dialog`” du scénario courant sera “écrasé” et remplacé par le style “`Corps de texte.dialog`” chargé du scénario formaté.
action: Cliquer sur le bouton “À partir d'un fichier…”.
resultat: La boite de dialogue “Ouvrir” s'affiche.
action: Retrouver un scénario `.odt` formaté.
note: Par exemple celui que vous avez réalisé en suivant ce tutoriel.
action: Sélectionner ce document.
action: Cliquer sur le bouton “Ouvrir”.
resultat: La boite de dialogue “Ouvrir” se referme et la boite de dialogue “Charger les styles” revient au premier plan.
action: Cliquer “OK” dans la boite de dialogue “Charger les styles”.
resultat: La boite “Charger les styles” se ferme et les styles sont automatiquement affectés au document courant.
action: Enregistrer le document ODF bien formaté.
resultat: Le document bien formaté est enregistré, vous pouvez l'envoyer !
/DOC

Si vous avez suivi correctement ces étapes, votre scénario s'est mis en forme correctement en respectant les styles formatés. Il ne vous reste plus qu'à en faire une version PDF en l'exportant dans ce format.

### Astuce

Pour retrouver plus vite vos modèles de scénarios et autres synopsis, vous pouvez créer un dossier “`Modèles`” dans votre dossier “`Documents/Ecriture`” pour y placer tous vos fichiers qui contiennent des styles bien formatés.

Vous pouvez également créer des *modèles de document*. Nous vous renvoyons au manuel de votre traitement de texte pour connaitre en détail la procédure à suivre. Cependant, comme nous le conseillons dans cet ouvrage, il est préférable de ne pas travailler avec les *modèles de document* mais plutôt de se contraindre à créer chaque fois les styles nécessaires pour que cette création devienne tellement facile que votre utilisation des styles en deviendra très efficace. Vous y gagnez des heures de travail et vos documents en sortiront beaucoup plus beaux et cohérents.