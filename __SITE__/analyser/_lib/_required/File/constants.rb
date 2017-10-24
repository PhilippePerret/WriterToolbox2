# encoding: utf-8
class Analyse
  class AFile

    FILES_TYPES = {
      0 => {hname: "Simple texte (markdown)",     ext: 'md'},
      1 => {hname: "Fichier de collecte",         ext: 'film'},
      2 => {hname: "Fichier sur les personnages", ext: 'persos'},
      3 => {hname: "Fichier de structure",        ext: 'stt'},
      4 => {hname: "Fichier de procédés",         ext: 'prc'},
      9 => {hname: "Table des matières",          ext: 'yml'}
    }

  end #/AFile
end #/Analyse
