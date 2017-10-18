# encoding: UTF-8
=begin

  Plan des divisions du film THE MAZE RUNNER.

  Il suffit de lancer ce script pour le construire, puis d'en tirer une
  image lorsque le fichier produit est ouvert dans Firefox
=end
ID_SYM_DU_FILM = 'the_maze_runner'
DUREE_FILM     = 128*60

require './data/analyse/script/build_table_divisions.rb'

divisions = {
  duree: DUREE_FILM,
  2 => {
    temps_separation: [''],
    scenes_separation:  ['cle_de_voute'],
    parties: [
      "PREMIERE_PARTIE",
      "SECONDE_PARTIE"
    ]
  },
  3 => {
    temps_separation: ['', ''],
    scenes_separation: ['Thomas tue un griffeur.', 'Les portes du labyrinthe ne se referment pas à la nuit venue.'],
    parties: [
      'Découverte de ce nouveau monde et de ses règles par Thomas.',
      'Thomas bouleverse les règles de ce nouveau monde.',
      'La vie n’est plus possible, il faut trouver une solution.'
    ]
  },
  4 => {
    temps_separation: ['', '', ''],
    scenes_separation:[
      'scene_un_quart',
      'scene_deux_quart',
      'scene_trois_quart'
    ],
    parties: [
      "PREMIER_QUART",
      "DEUXIEME_QUART",
      "TROISIEME_QUART",
      "QUATRIEME_QUART"
    ]
  },
  5 => {
    temps_separation: ['', '', '', ''],
    scenes_separation:[
      'scene_un_cinquieme',
      'scene_deux_cinquieme',
      'scene_trois_cinquieme',
      'scene_quatre_cinquieme'
    ],
    parties: [
      "PREMIER_PARTIE",
      "DEUXIEME_PARTIE",
      "TROISIEME_PARTIE",
      "QUATRIEME_PARTIE",
      "CINQUIEME_PARTIE"
    ]
  },
  6 => {
    temps_separation: ['', '', '', '', ''],
    scenes_separation: [
      'scene_un_sixieme',
      'scene_deux_sixieme',
      'scene_trois_sixieme',
      'scene_quatre_sixieme',
      'scene_cinq_sixieme'
    ],
    parties: [
      "PREMIER_SIXIEME",
      "DEUXIEME_SIXIEME",
      "TROISIEME_SIXIEME",
      "QUATRIEME_SIXIEME",
      "CINQUIEME_SIXIEME",
      "SIXIEME_SIXIEME"
    ]
  }
}

build_table_divisions( divisions, ID_SYM_DU_FILM)
