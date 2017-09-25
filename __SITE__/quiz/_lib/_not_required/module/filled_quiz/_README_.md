# Module `filled_quiz`

Ce module est chargé quand des réponses ont été données par l'user et qu'il faut les réafficher.

> Rappel : on ne fonctionne plus avec javascript, maintenant, mais avec du code ERB enregistré dans le code `output` du quiz, qui appelle des méthodes permettant de définir les réponses données.

Lorsqu'il n'y a pas encore de réponse, c'est le module `unfilled_quiz` qui est chargé, qui contient les mêmes méthodes mais qui ne renvoie rien.
