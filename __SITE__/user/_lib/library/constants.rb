# encoding: utf-8
class User

  # Les grades d'un inscrit
  #
  # Noter que ces grades ne servent pas seulement pour le forum, mais
  # pour tout le site (même si, pour le moment, c'est surtout pour le
  # forum que c'est utile et pertinent).
  GRADES = {
    # Note par rapport aux privilèges forum : ils sont additionnés, donc
    # par exemple le privilège du 3 reprend toujours les privilèges des
    # 0, 1 et 2
    # Si la description commence par "!!!", elle ne sera ajoutée que pour
    # ce grade.
    0 => {hname:'Padawan de l’écriture',                      privilege_forum:'!!!lire les messages publics'},
    1 => {hname:'Simple audit<%=f_rice%>',                    privilege_forum:'lire tous les messages'},
    2 => {hname:'Audit<%=f_rice%> patient<%=f_e%>',           privilege_forum:'voter pour les messages'},
    3 => {hname:'Apprenti<%=f_e%> surveillé<%= user.f_e %>',  privilege_forum:'!!!écrire des réponses qui seront modérées'},
    4 => {hname:'Simple rédact<%=f_rice%>',                   privilege_forum:'répondre librement aux messages'},
    5 => {hname:'Rédact<%=f_rice%>',                          privilege_forum:'initier un sujet'},
    6 => {hname:'Rédact<%=f_rice%> émérite',                  privilege_forum:'supprimer ou valider des messages'},
    7 => {hname:'Rédact<%=f_rice%> confirmé<%=f_e%>',         privilege_forum:'valider ou clore un sujet'},
    8 => {hname:'Maitre<%=f_sse%> rédact<%=f_rice%>',         privilege_forum:'supprimer des sujets'},
    9 => {hname:'Expert<%=f_e%>',                             privilege_forum:'bannir des utilisateurs'}

  } unless defined?(GRADES) # quand tests, car on reload ce module

end#/User
