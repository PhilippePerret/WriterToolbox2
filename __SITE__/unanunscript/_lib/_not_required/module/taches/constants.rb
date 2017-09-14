# encoding: utf-8
class Unan
  class Abswork

    # Les types qui ne sont pas des task pures, c'est-à-dire qui sont des
    # pages de cours ou des quiz. Permet de distinguer les tâches à l'affichage
    # des différents onglets.
    #
    TYPES_NOT_TASK = [20, 21, 30, 31, 35, 36, 80, 81, 85]

    TYPES = {
      0  => {value:0, hname:"Indéfini", id_list: :tasks, type: :task},

      # --- Document à produire ---
      12 => {value:12, hname:'Document à créer',                  id_list: :tasks, type: :task},
      10 => {value:10, hname:'Document à écrire',                 id_list: :tasks, type: :task},
      11 => {value:11, hname:'Document à retravailler',           id_list: :tasks, type: :task},
      15 => {value:15, hname:'Document “de vente” à produire',    id_list: :tasks, type: :task},

      # --- Cours ---
      20 => {value:20, hname:"Page de cours à lire",              id_list: :pages, type: :page},
      21 => {value:21, hname:"Page de cours à relire",            id_list: :pages, type: :page},
      25 => {value:25, hname:"Analyse à lire",                    id_list: :pages, type: :page},
      26 => {value:26, hname:"Analyse à faire",                   id_list: :tasks, type: :task},

      # --- Questionnaire ---
      30 => {value:30, hname:"Questionnaire/Quiz",                id_list: :quiz, type: :quiz},
      31 => {value:31, hname:"Checklist",                         id_list: :quiz, type: :quiz},
      35 => {value:35, hname:"Questionnaire/Quiz à reprendre",    id_list: :quiz, type: :quiz},
      36 => {value:36, hname:"Checklist à reprendre",             id_list: :quiz, type: :quiz},

      # --- Actions à accomplir ---
      40 => {value:40, hname:"Action à accomplir",                id_list: :tasks, type: :task ,  exemple:"Créer un dossier sur son ordinateur"},
      41 => {value:41, hname:"Documentation sur le sujet",        id_list: :tasks, type: :task},
      42 => {value:42, hname:"Manipulation à apprendre",          id_list: :tasks, type: :task, exemple: "Apprendre à se servir des styles pour la rédaction"},

      # --- Divers ---
      50 => {value:50, hname:"Réflexion sur le projet",           id_list: :tasks, type: :task},
      51 => {value:51, hname:"Mise en lecture d'un document",     id_list: :tasks, type: :task},
      52 => {value:52, hname:"Rencontre d'un lecteur",            id_list: :tasks, type: :task},
      # --- Autres ---
      60 => {value:60, hname:"Analyse de film à faire",           id_list: :tasks, type: :task},
      61 => {value:61, hname:"Analyse de film à vérifier",        id_list: :tasks, type: :task},

      # --- Le site ---
      80 => {value:80, hname:"Message privé à lire",                id_list: :forum, type: :forum},
      81 => {value:81, hname:"Réponse à message privé",             id_list: :forum, type: :forum},
      85 => {value:85, hname:"Commentaire sur document à rédiger",  id_list: :forum, type: :forum},

      99 => {hname:"Autre", id_list: :tasks, type: :task}

    }

  end #/Abswork
end #/Unan
