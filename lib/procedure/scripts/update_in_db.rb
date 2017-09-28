# encoding: UTF-8



valeur = <<-TEXT
La 1<sup>ère</sup> Fondamentale:::0
La 2<sup>e</sup> Fondamentale:::10:::C'est de la 3<sup>e</sup> Fondamentale, dédiée aux oppositions fondamentales donc à ce qui va s'opposer à la résolution heureuse de l'histoire, dont découle directement les obstacles qui seront traités dans l'histoire. Un obstacle, c'est une opposition concrète et incarnée dans l'histoire.
La 3<sup>e</sup> Fondamentale:::0
La 4<sup>e</sup> Fondamentale:::0
La 5<sup>e</sup> Fondamentale:::0
La 6<sup>e</sup> Fondamentale:::-10
Je ne sais pas:::-7
TEXT
valeur = valeur.strip

site.db.update(:quiz,'questions',{reponses: valeur},{id: 73})

debug "Actualisation de la donnée opérée avec succès dans la DB."
