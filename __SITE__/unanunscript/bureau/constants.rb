# encoding: utf-8
class Unan


  # Les données de toutes les sections, pour un travail plus facile de construction
  # des pages du bureau.
  DATA_SECTIONS = {

    # Tout ce qui concerne le programme lui-même
    program: {id: :program, hname: "Programme"},

    # Tout ce qui concerne le projet de l'auteur
    projet:  {id: :projet, hname: "Projet"},

    # Tout ce qui concerne les taches à exécuter
    taches: {id: :taches, hname: "Tâches", tache_type: :task},

    # Tout ce qui concerne les pages de cours à lire
    pages:  {id: :cours, hname: "Cours", tache_type: :page},

    # Tout ce qui concerne les quiz
    quiz:   {id: :quiz, hname: "Quiz", tache_type: :quiz},

    # Tout ce qui concerne le forum attaché au programme
    forum:  {id: :forum, hname: "Forum", tache_type: :forum},

    # Tout pour les préférences du programme, par exemple le rythme
    prefs:  {id: :prefs, hname: "Préférences"},

    # Tout pour l'aide sur le programme
    aide:   {id: :aide, hname: "Aide"}

  }


  class Abswork

    ITYPES = {
      task: 1, page: 2, quiz: 3, forum: 4
    }

    TYPES = {
      0  => {value:0, hname:"Indéfini", id_list: :tasks, type: :task, itype: 1},

      # --- Document à produire ---
      12 => {value:12, hname:'Document à créer',                  id_list: :tasks, type: :task, itype: 1},
      10 => {value:10, hname:'Document à écrire',                 id_list: :tasks, type: :task, itype: 1},
      11 => {value:11, hname:'Document à retravailler',           id_list: :tasks, type: :task, itype: 1},
      15 => {value:15, hname:'Document “de vente” à produire',    id_list: :tasks, type: :task, itype: 1},

      # --- Cours ---
      20 => {value:20, hname:"Page de cours à lire",              id_list: :pages, type: :page, itype: 2},
      21 => {value:21, hname:"Page de cours à relire",            id_list: :pages, type: :page, itype: 2},
      25 => {value:25, hname:"Analyse à lire",                    id_list: :pages, type: :page, itype: 2},
      26 => {value:26, hname:"Analyse à faire",                   id_list: :tasks, type: :task, itype: 1},

      # --- Questionnaire ---
      30 => {value:30, hname:"Questionnaire/Quiz",                id_list: :quiz, type: :quiz, itype: 3},
      31 => {value:31, hname:"Checklist",                         id_list: :quiz, type: :quiz, itype: 3},
      35 => {value:35, hname:"Questionnaire/Quiz à reprendre",    id_list: :quiz, type: :quiz, itype: 3},
      36 => {value:36, hname:"Checklist à reprendre",             id_list: :quiz, type: :quiz, itype: 3},

      # --- Actions à accomplir ---
      40 => {value:40, hname:"Action à accomplir",                id_list: :tasks, type: :task, itype: 1,  exemple:"Créer un dossier sur son ordinateur"},
      41 => {value:41, hname:"Documentation sur le sujet",        id_list: :tasks, type: :task, itype: 1},
      42 => {value:42, hname:"Manipulation à apprendre",          id_list: :tasks, type: :task, itype: 1, exemple: "Apprendre à se servir des styles pour la rédaction"},

      # --- Divers ---
      50 => {value:50, hname:"Réflexion sur le projet",           id_list: :tasks, type: :task, itype: 1},
      51 => {value:51, hname:"Mise en lecture d'un document",     id_list: :tasks, type: :task, itype: 1},
      52 => {value:52, hname:"Rencontre d'un lecteur",            id_list: :tasks, type: :task, itype: 1},
      # --- Autres ---
      60 => {value:60, hname:"Analyse de film à faire",           id_list: :tasks, type: :task, itype: 1},
      61 => {value:61, hname:"Analyse de film à vérifier",        id_list: :tasks, type: :task, itype: 1},

      # --- Le site ---
      80 => {value:80, hname:"Message privé à lire",                id_list: :forum, type: :forum, itype: 4},
      81 => {value:81, hname:"Réponse à message privé",             id_list: :forum, type: :forum, itype: 4},
      85 => {value:85, hname:"Commentaire sur document à rédiger",  id_list: :forum, type: :forum, itype: 4},

      99 => {hname:"Autre", id_list: :tasks, type: :task, itype: 1}

    }
  end #/Abswork
end #/Unan
