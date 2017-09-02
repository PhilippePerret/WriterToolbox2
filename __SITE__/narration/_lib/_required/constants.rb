# encoding: UTF-8
=begin
Pour ne télécharger que ce fichier, sans charger tout narration :

  require './__SITE__/narration/_lib/_required/constants.rb'
=end

class Narration
  LIVRES = {
    # :nbp_expected définit le nombre de pages escomptés pour le livre
    1   => {id:1,   hname: "La Structure", nbp_expected: 120,
      short_hname: "Structure",
      stitre:"Construire un récit captivant au moyen d'une structure solide, émotionnelle et agilement menée d'un bout à l'autre de vos histoires.", folder:'structure'},
    2   => {id:2,   hname: "Les Personnages", nbp_expected: 120,
      short_hname: "Personnages",
      stitre:"Développer des personnages riches, complets et captivants au cœur de vos récits.", folder:'personnages'},
    3   => {id:3,   hname: "La Dynamique narrative", nbp_expected: 100, folder:'dynamique',
      short_hname: "Dynamique",
      stitre:"Construire des intrigues riches, dynamiques et tendues en maitrisant la triade Objectifs-Obstacles-Conflits."},
    4   => {id:4,   hname: "La Thématique", nbp_expected: 100, folder:'thematique',
      short_hname: "Thèmes",
      stitre:"Donner de la consistance et de la force au récit en développant leur thématique. Tous les outils pour développer de façon riche, équilibrée et audible ses thèmes."},
    5   => {id:5,   hname: "Les Documents d'écriture", nbp_expected:120, folder:'documents',
      short_hname: "Documents",
      stitre:"Tous les documents utilisés par les auteurs pour concevoir avec aisance leurs récits. Tous les documents à connaitre pour se dire auteur."},
    6   => {id:6,   hname: "Le Travail de l'auteur", nbp_expected: 100, folder:'travail_auteur',
      short_hname: "Travail auteur",
      stitre:"Tout ce qu'il faut savoir sur le quotidien de l'auteur, méthodologie, organisation et attitude."},
    7   => {id:7,   hname: "Les Procédés narratifs", nbp_expected: 100, folder:'procedes',
      short_hname: "Procédés",
      stitre: "Comprendre et apprendre à maitriser les procédés narratifs utilisés par les plus grands auteurs."},
    8   => {id:8,   hname: "Les Concepts narratifs en action", nbp_expected: 100, folder:'concepts',
      short_hname: "Théorie",
      stitre: "Quand la théorie et la pratique se rejoignent pour aider l'auteur à comprendre et améliorer ses récits."},
    9   => {id:9,   hname: "Le Dialogue", nbp_expected: 100, folder:'dialogue',
      short_hname: "Dialogue",
      stitre: "Apprendre à écrire le meilleur dialogue possible, efficace, riche et cohérent."},
    10  => {id:10,  hname: "L'Analyse de films", nbp_expected: 100, folder:'analyse',
      short_hname: "Analyses",
      stitre:"Apprendre à tirer le maximum de sa vision des films."},
    11  => {id:11,  hname: "Recueil d'exemples", nbp_expected: 100, folder:'exemples',
      short_hname: "Exemples",
      stitre:"Recueil d'exemples et d'illustrations de tous les travaux à accomplir par l'auteur."}
  }

  # Symbole du livre vers son ID
  # Comprend les noms des dossiers
  SYM2ID = {
    analyse:            10,
    concepts_narratifs: 8,
    concepts:           8,
    dialogue:           9,
    documents:          5,
    dynamique:          3,
    exemples:           11,
    personnages:        2,
    procedes:           7,
    structure:          1,
    thematique:         4,
    theorie:            8,
    travail_auteur:     6,
    travail:            6
  }

  NIVEAUX_DEVELOPPEMENT = {
    0   => {hname:  'Niveau indéfini'},
    1   => {hname:  'Création de la page'},
    2   => {hname:  'Amorce de la page'},
    3   => {hname:  'Esquisse'},
    4   => {hname:  'Développée'},
    5   => {hname:  'Doit être achevée'},
    6   => {hname:  'À lire par le lecteur'},
    7   => {hname:  'À corriger par le rédacteur'},
    8   => {hname:  'Relecture finale'},
    9   => {hname:  'Correction finale'},
    'a' => {hname:  'Achevée'}
  }
end #/Cnarration
