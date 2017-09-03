# encoding: UTF-8

require './data/analyse/script/build_table_divisions.rb'

divisions = {
  duree: 126*60,
  2 => {
    temps_separation: ['1:03:00'],
    scenes_separation:  ['Première victoire de Seabiscuit'],
    parties: [
      "Découverte et formation de Seabiscuit. Rencontre des trois hommes.
<br><b>Seabiscuit n'a aucun avenir</b>.",
      "Accomplissement, gloire, chute et renaissance.
<br><b>Seabiscuit a un avenir</b>."
    ]
  },
  3 => {
    temps_separation: ['42:00', '1:24:00', '2:06:00'],
    scenes_separation: ["Découverte de Seabiscuit", "Riddle accepte de faire concourir son champion contre Seabiscuit"],
    parties: [
      "Exposition des trois personnages et Seabiscuit. Objectif de Charles Howard après la destruction de son foyer : monter une écurie de chevaux, et gagner.",
      "La formation d’un champion. Mais pas encore <em>LE</em> champion.<br><br><br>",
      "Grandeur, décadence et renaissance.<br>Seabiscuit devient le plus grand des chevaux, puis il chute et remonte la pente contre toute attente."
    ]
  },
  4 => {
    temps_separation: ['32:00', '1:03:00', '1:40:00', '2:06:00'],
    scenes_separation:[
      'Rencontre au Mexique de Charles et Marcella',
      'Première victoire de Seabiscuit',
      'Victoire de Seabiscuit contre War Amiral'
    ],
    parties: [
      'Charles, de la réussite au deuil.', 'De la renaissance à la possibilité de gagner.', 'De la première victoire au sacre du champion.', 'De la chute à la renaissance.'
    ]
  },
  6 => {
    temps_separation: ['21:00', '42:00', '1:03:00', '1:22:00', '1:35:00'],
    scenes_separation: [
      'Mort du fils de Charles (incident perturbateur)',
      'Smith découvre Seabiscuit',
      'Seabiscuit remporte sa première course',
      'Riddle accepte de faire concourir son champion contre Seabiscuit',
      'Duel entre Seabiscuit et War Admiral'
    ],
    parties: [
      'Trois destins : Charles Howard, Red Pollard et Tom Smith',
      'De la destruction<br>familiale au retour de l’ambition',
      'De la formation à la première victoire<br><br>',
      'De la gloire à<br>l’obtention de l’ultime duel',
      'De la préparation du combat à la victoire<br><br>',
      'La chute puis la renaissance<br><br>'
    ]
  }
}
build_table_divisions( divisions, 'seabiscuit')
