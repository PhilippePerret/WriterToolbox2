# User dans le forum {#forum_user}


## Grade sur le forum {#user_grade_forum}

Les users ont des grades différents en fonction de leur ancienneté et leurs compétences.

C'est le 2e bit (options[1]) qui détermine ce grade.

> Noter que 0 correspond à un visiteur non inscrit, alors qu'un inscrit est automatiquement mis à 1.

Les valeurs sont les suivantes :

```ruby

# Grade d'un utilisateur par rapport au forum
# Ces valeurs correspondent au bit 1 (donc le deuxième) des options de l'user.
GRADES_FORUM = {
  # Note par rapport aux privilèges forum : ils sont additionnés, donc
  # par exemple le privilège du 3 reprend toujours les privilèges des
  # 0, 1 et 2
  # Si la description commence par "!!!", elle ne sera ajoutée que pour
  # ce grade.
  0 => {hname:'Padawan de l’écriture',                  privilege_forum:'!!!lire les messages publics'},
  1 => {hname:'Simple audit<%= user.f_rice %>',         privilege_forum:'lire tous les messages'},
  2 => {hname:'Audit<%= user.f_rice %> patient',        privilege_forum:'noter les messages'},
  3 => {hname:'Apprenti<%= user.f_e %> surveillé<%= user.f_e %>',     privilege_forum:'!!!écrire des réponses qui seront modérées'},
  4 => {hname:'Simple rédact<%= user.f_rice %>',        privilege_forum:'répondre librement aux messages'},
  5 => {hname:'Rédact<%= user.f_rice %>',               privilege_forum:'initier un sujet'},
  6 => {hname:'Rédact<%= user.f_rice %> émérite',       privilege_forum:'supprimer des messages'},
  7 => {hname:'Rédact<%= user.f_rice %> confirmé<%= user.f_e %>',     privilege_forum:'valider ou clore un sujet'},
  8 => {hname:'Maitre<%=sse%> rédact<%=user.f_rice%>',       privilege_forum:'supprimer des sujets'},
  9 => {hname:'Expert<%= user.f_e %> d’écriture',      privilege_forum:'bannir des utilisateurs'}
} unless defined?(GRADES) # quand tests, car on reload ce module

```
