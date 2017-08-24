#

Ce dossier contient tout le matériel nécessaire pour l'utilisation des formulaires sur le site.

Il s'appelle en ajoutant simplement l'appel à la méthode suivante n'importe où avant le chargement de la vue.

```erb

<%
# Par exemple en haut du fichier ERB qui présente le formulaire

require_form_support

%>

<!-- Ici le formulaire -->

```
