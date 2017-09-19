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
    cours:  {id: :cours, hname: "Pages", tache_type: :page},

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

  end #/Abswork
end #/Unan
