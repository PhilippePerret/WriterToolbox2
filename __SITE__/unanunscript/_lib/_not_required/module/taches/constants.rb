# encoding: utf-8
class Unan

  # Unan::SUPPORTS_RESULTAT
  SUPPORTS_RESULTAT = [
    [0, 'Indéfini'],
    [1, 'Document'],
    [2, 'Plan'],
    [3, 'Image'],
    [4, 'Données'],
    [5, "-- inutilisé --"],
    [6, "-- inutilisé --"],
    [7, "-- inutilisé --"],
    [8, 'Aucun'], # Lecture d'un cours par exemple
    [9, 'Autre']
  ]
  
  # Unan::DESTINATAIRES
  DESTINATAIRES = [
    [0, 'Indéfini'],
    [1, 'Pour soi'],
    [2, 'Lecteurs proches'],
    [3, 'Producteurs'],
    [4, 'Le programme'],
    [5, 'Indéfini'],
    [6, 'Indéfini'],
    [7, 'Indéfini'],
    [8, 'Personne'],
    [9, 'Autre']
  ]

  # Unan::NIVEAU_DEVELOPPEMENT
  NIVEAU_DEVELOPPEMENT = [
    [0, 'Indéfini'],
    [1, "Simple ébauche"],
    [2, "Esquisse développée"],
    [3, "Développé"],
    [4, "Très développé"],
    [5, "Affiné"],
    [6, "Très affiné"],
    [7, "Presque parfait"],
    [8, "Travail abouti"],
    [9, "Peu importe"]
  ]



  class Abswork

    # Les types qui ne sont pas des task pures, c'est-à-dire qui sont des
    # pages de cours ou des quiz. Permet de distinguer les tâches à l'affichage
    # des différents onglets.
    # NORMALEMENT, DOIT DEVENIR OBSOLÈTE
    #
    TYPES_NOT_TASK = [20, 21, 30, 31, 35, 36, 80, 81, 85]



  end #/Abswork
end #/Unan
