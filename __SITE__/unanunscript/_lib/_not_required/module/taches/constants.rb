# encoding: utf-8
class Unan

  # Le type du projet développé par l'auteur
  #
  # Consigné dans le 5e bit (4) de la propriété `type` du projet
  #
  # Noter qu'on se sert de cette constante, dans task_listings.erb, pour savoir
  # si le module non requis 'taches' a été chargé. Si par hasard il devait être
  # déplacé, il faut se servir d'un autre constantes.
  #
  PROJET_TYPES = {
    0 => {hname:'Tous',                   value:0, shorthname: 'Projet',          pages: 300  },
    1 => {hname:'Film (scénario)',        value:1, shorthname: 'Scénario',        pages: 90   },
    2 => {hname:"Roman (manuscrit)",      value:2, shorthname: 'Roman',           pages: 300  },
    3 => {hname:"BD (scénario)",          value:3, shorthname: 'Bande dessinée',  pages: 48   },
    4 => {hname:"Jeu vidéo (Game design)",value:4, shorthname: 'Jeu vidéo',       pages: 200  },
    8 => {hname:"Je ne sais pas encore",  value:8, shorthname: 'Projet',          pages: 120  },
    9 => {hname:"Autre",                  value:9, shorthname: 'Projet',          pages: 120  }
  }

  # Les sujets cibles visés par un travail (un seul par travail)
  #
  SUJETS_CIBLES = {
    none: {
      value: 0, hname: "Aucun",
      sub: {
        none: {value: 0, hname: "Aucun"}
      }
    },
    projet: {
      value: 1, hname: "Projet",
      sub: {
        informations: {value: 0, hname: 'Informations'},
        presentation: {value: 1, hname: 'Présentation'},
        orgaordi:     {value: 2, hname: 'Organisation (sur l’ordinateur)'},
        orgagene:     {value: 3, hname: 'Organisation générale'},
        redaction:    {value: 4, hname: 'Rédaction du'},
        doc_final:    {value: 8, hname: 'Document final'},
        promotion:    {value: 9, hname: 'Promotion'}
      }
    },
    histoire: {
      value: 2, hname: 'Histoire',
      sub: {
        fondamentales: {value: 0, hname: 'Fondamentales'},
        pitch:         {value: 1, hname: 'Pitch'},
        synopsis:      {value: 2, hname: 'Synopsis'},
        documentation: {value: 5, hname: 'Documentation générale'}
      }
    },
    personnage: {
      value: 3, hname: 'Personnage',
      sub: {
        caracteristiques: {value: 0, hname: 'Caractéristique(s)'},
        dialogue:         {value: 2, hname: 'Dialogue'},
        coherence:        {value: 4, hname: 'Cohérence des personnages'},
        secondaires:      {value: 6, hname: 'Personnages secondaires'},
        docu:             {value: 9, hname: 'Documentation sur personnages'}
      }
    },
    structure: {
      value: 4, hname: 'Structure',
      sub: {
        plan:      {value: 0, hname: 'Plan général'},
        actes:     {value: 1, hname: 'Les actes'},
        kscenes:   {value: 2, hname: 'Les scènes-clés'},
        coherence: {value: 4, hname: 'Cohérence structurelle'},
        docu:      {value: 9, hname: 'Documentation sur structure'}
      }
    },
    dynamique: {
      value: 7, hname: 'Dynamique',
      sub: {
        gene: {value: 0, hname: 'La dynamique en général'},
        obj:  {value: 1, hname: 'Les objectifs'},
        obs:  {value: 4, hname: 'Les obstacles'},
        conf: {value: 7, hname: 'Le conflit'},
        docu: {value: 9, hname: 'Documentation sur dynamique'}
      }
    },
    thematique: {
      value: 5, hname: 'Thématique',
      sub: {
        definition: {value: 0, hname: 'Définition des thèmes'},
        theseanti:  {value: 5, hname: 'Thèse et Antithèse'},
        docu:       {value: 9, hname: 'Documentation sur thématique'}
      }
    },
    intrigues: {
      value: 6, hname:'Intrigues',
      sub: {
        definition:   {value: 0, hname: 'Définition'},
        conduite:     {value: 2, hname: 'Conduite'},
        intersection: {value: 5, hname: 'Intersection'},
        docu:         {value: 9, hname: 'Documentation sur intrigues'}
      }
    },
  programme: {
      value: 9, hname:'Programme 1A1S',
      sub: {
        engeneral:    {value: 0, hname: 'Généralité'},
        informations: {value: 1, hname: 'Déroulement'},
        evaluation:   {value: 2, hname: 'Évaluation'},
        exercice:     {value: 5, hname: 'Exercice'}
      }
    }
  }

  # On fabrique la méthode qui va permettre, à partir de deux valeurs, de
  # retrouver le sujet cible précis
  #
  # @return {Hash} Un hash contenant :
  #                :main_value        Valeur du sujet principal
  #                :main_name         Nom du sujet principal
  #                :value             Valeur du sous-sujet
  #                :hname             Nom du sous-sujet
  #
  def self.sujet_cible_of main_value, sub_value
    SUJETS_CIBLES.each do |sjid, sjdata|
      if sjdata[:value] == main_value
        # On a trouvé le sujet principal, on cherche le sous-sujet
        sjdata[:sub].each do |ssjid, ssjdata|
          if ssjdata[:value] == sub_value
            # On a tout trouvé, on retourne la table du sous-sujet à laquelle
            # on ajoute la propriété :main_sujet qui est le hname du sujet principal
            return ssjdata.merge(main_value: main_value, main_name: sjdata[:hname])
          end
        end
      end
    end 
  end
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
