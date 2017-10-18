# encoding: UTF-8

# ---------------------------------------------------------------------
#   CODE PERMETTANT DE PRODUIRE UNE TABLE DE DIVISION D'UN
#   FILM
#
#   Cette table doit être ouverte dans le navigateur, puis on fait
#   un screenshot pour en faire une image à introduire dans le
#   livre narration ou autre.
#
#   Utilisation :
#     - charger ce code
#         require './data/analyse/script/build_table_divisions.rb'
#     - appeler la méthode `build_table_divisions` en passant en
#       paramètre les divisions définies comme dans l'exemple ci-
#       dessous
#         build_table_divisions(divisions[, <affixe fichier>])
#     - Lancer le script
#     - Le fichier est créé dans le dossier du script et ouvert dans
#       Firefox.
# ---------------------------------------------------------------------


divisions_test = {
  duree: 7200,
  2 => {
    temps_separation: [3600],
      # Les temps de séparation peuvent aussi être donnés en horloge
    scenes_separation: ["La scène clé de voûte"],
    parties: [
      "Ce qui caractérise la première partie",
      "Ce qui caractérise la seconde partie"
    ]
  },
  3 => {
    temps_separation: [2400, 4810],
    scenes_separation:["Premier tiers", "Deuxième tiers"],
    parties: [
      "Le contenu du premier tiers",
      "Le contenu du deuxième tiers",
      "Le contenu du troisième tiers volontairement allongé pour voir comment vont se comporter les autres cellules."
    ]
  },
  4 => {
    temps_separation: [1800, 3635, 5400],
    scenes_separation: ["Pivot 1", "Une clé de voûte assez longue pour voir comment elle va faire.", "Pivot 2"],
    parties: [
      "Exposition",
      "Partie 1 du développement",
      "Partie 2 du développement",
      "Dénouement"
    ]
  },
  5 => {
    temps_separation: [1440, 2880, 4320, 5760],
    scenes_separation: ["1/5", "2/5", "3/5", "4/5"],
    parties:["1er cinquième", "2e cinquième", "3e cinquième", "4e cinquième", "5e cinquième"]
  },
  6 => {
    temps_separation: [1200, 2400, 3600, 4800, 6015],
    scenes_separation:["1/6", "2/6", "3/6", "4/6", "5/6"],
    parties:[
      "1er sixième", "2e sixième", "3e sixième allongé par rapport aux autres cellules.", "4e sixième", "5e sixième", "6e sixième"
    ]
  }
}

# Largeur utilisée pour les divisions
# Le reste est utilisé pour l'indication de la division
POURCENTAGE_WIDTH = 97

def build_table_divisions data_divisions, affixe = "tableau_divisions"

  folder_script = File.dirname(File.expand_path(__FILE__))
  path = File.join(folder_script, "#{affixe}.html")
  File.unlink(path) if File.exist?(path)

  code_tableau = ""
  @un_decalage_de_temps_existe = false
  (2..8).each do |division|

    # Les données de la division courante
    data_division = data_divisions[division]

    # On passe les divisions qui ne sont pas définies
    data_division != nil || next

    temps  = data_division[:temps_separation]
    temps << data_divisions[:duree]
    scenes = data_division[:scenes_separation]
    scenes << 'Fin' # on pourra aussi ne rien mettre
    parties = data_division[:parties]

    # On doit faire un truc pas beau du tout pour faire que
    # les divs des textes soient égaux en hauteur : on prend le
    # texte le plus long et on met tous les autres à la même
    # longueur. Ce problème pourrait être évité en se servant de
    # table (<table>) au lieu de div, mais je n'ai pas envie de tout
    # refaire.
    #
    # NOTE Si la partie contient des <br>, elle ne sera pas modifiée car
    # on considère alors que la gestion des hauteurs se fait par le biais
    # de ces br.
    max_len = 0
    parties.each do |partie|
      partie.length < max_len || max_len = partie.length
    end
    parties =
      parties.collect do |partie|
        len = partie.length
        if len < max_len && !partie.match(/<br/)
          # On ajoute des espaces pour que le div soit aussi
          # grand que le plus haut, lorsque le texte est plus
          # court
          diff = (max_len - len) - 2 # -2 pour le br
          diff > 0 || diff = 0
          partie + '<br>' + ("  "*diff)
        else
          partie
        end
      end

    # 2 => 50% donc 100 / 2
    # 3
    pourcentage = POURCENTAGE_WIDTH.to_f / division
    # On répète autant de fois qu'il y a de divisions
    # pour faire une rangée complète
    rangee_complete = ''
    division.times do |i|
      tps = temps[i]
      tps != nil || tps = ''
      tps.instance_of?(String) || tps = tps.to_horloge

      # Le temps absolu
      abs_time = ((data_divisions[:duree].to_f / division) * (i+1)).to_i
      rel_time = tps.to_seconds

      # Quand la différence de temps est supérieure à 30 secondes
      if (abs_time - rel_time).abs > 30
        tps = "<span class='temps_absolu'>#{abs_time.to_horloge}</span>#{tps}"
        @un_decalage_de_temps_existe = true
      end

      rangee_complete +=
        "<div class='cell' style='width:#{pourcentage}%'>" +
          # Rangée contenant le temps et la scène de séparation
          "<div class='seps'>" +
            "<span class='temps'>#{tps}</span>" +
            "<span class='scene'>#{scenes[i]}</span>" +
          "</div>" +
          # Rangée contenant le contenu de la partie
          "<div class='partie div#{division}'>#{parties[i]}</div>" +
        "</div>"
    end
    code_tableau << "<div class='row'><div class='mark_division'>x#{division}</div>#{rangee_complete}</div>"
  end

  code_tableau = "<div class='table'>#{code_tableau}</div>"

  # Le code complet
  code_complet =
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta http-equiv="Content-type" content="text/html; charset=utf-8">
      <title>Tableau de divisions d'un film</title>
      <style type="text/css">
        #{code_styles_tableau_divisions}
      </style>
    </head>
    <body>#{explications_tableau_divisions}#{code_tableau}#{ajout_sous_tableau_divisions}</body>
    </html>
    HTML

  File.open(path,'wb').write code_complet
  sleep 0.2

  if File.exist?(path)
    `open -a Firefox.app "#{path}"`
  else
    puts "ERREUR"
  end
end
def ajout_sous_tableau_divisions
  c = String.new
  if @un_decalage_de_temps_existe
    c << '<div style="font-size:11.5pt;font-style:italic;">'+
    "Les temps indiqués entre crochets sont les temps absolus, c'est-à-dire les positions exactes des divisions lorsqu'il y a un décalage significatif avec la position de la scène du film (> 30 secondes)."+
    '</div>'
  end
  return c
end
def explications_tableau_divisions
  <<-HTML
  <div style="font-size:11pt;margin-bottom:2em;font-style:italic">
    <p>Jouez sur la largeur de la fenêtre pour ajuster la taille du tableau puis faire un screenshot du tableau. Vous pouvez l'insérer à l'aide d'une balise IMAGE[...].</p>
    <p>S'il y a des problèmes de hauteurs de cellule, on peut les ajuster en ajoutant des &lt;br&gt; (sans `/>`).</p>
  </div>
  HTML
end
# Mise en forme de la table
def code_styles_tableau_divisions
  <<-CSS
  body{margin:4em;}
  div.table {
/*    width: 1000px;*/
    width: 100%;
    font-size:    13pt;
    font-family:  Arial;
  }
  div.table div.row {
    border: 1px solid;
    margin-bottom: 1em;
  }
  /* La marque indiquant la division */
  div.table div.row div.mark_division {
    display: inline-block;
    font-weight: bold;
    font-size: 11.2pt;
    color: #777;
    text-align: center;
    width: calc(#{100 - POURCENTAGE_WIDTH}%);
  }
  div.table div.row div.cell {
    display: inline-block;
  }
  /* Les div qui contiennent les scènes charnières */
  div.table div.row div.cell div.seps {
    border-right: 1px solid;
    padding-right: 8px;
    text-align: right;
  }
  div.table div.row div.cell div.seps span.temps {
    font-family: Georgia;
    font-size: 12.8pt;
    display:block;
  }
  div.table div.row div.cell div.seps span.temps span.temps_absolu {
    font-size:11pt;
    color: #777;
  }
  div.table div.row div.cell div.seps span.temps span.temps_absolu:before {
    content: "[";
  }
  div.table div.row div.cell div.seps span.temps span.temps_absolu:after {
    content: "] ";
  }
  div.table div.row div.cell div.seps span.scene {
    display:block;
    padding-left: 20%;
  }
  div.table div.row div.cell div.partie {
    display: block;
    border: 1px solid;
    padding: 4px 8px;
    text-align: center;
  }
  /*Les div de couleur, en fonction de la division courante*/
  div.table div.row div.cell div.partie.div2 {
    background-color: #ccccff;
  }
  div.table div.row div.cell div.partie.div3 {
    background-color: #ccffcc;
  }
  div.table div.row div.cell div.partie.div4 {
    background-color: #ffccff;
  }
  div.table div.row div.cell div.partie.div5 {
    background-color: #ffffcc;
  }
  div.table div.row div.cell div.partie.div6 {
    background-color: #ffcccc;
  }
  div.table div.row div.cell div.partie.div7 {
    background-color: #ccffff;
  }
  div.table div.row div.cell div.partie.div8 {
    background-color: #ccccff;
  }
  CSS
end

unless 2.respond_to?(:to_horloge)
  class ::Fixnum
    def to_horloge
      hrs = self / 3600
      mns = self % 3600
      scs = mns % 60
      mns = mns / 60
      "#{hrs}:#{mns.to_s.rjust(2,'0')}:#{scs.to_s.rjust(2,'0')}"
    end
  end#/Fixnum
end
unless ''.respond_to?(:to_seconds)
  class ::String
    def to_seconds
      h = self.split(':').reverse.collect{|n| n.to_i}
      (h[0]||0) + (h[1]||0)*60 + (h[2]||0)*3600
    end
  end
end

# Si c'est ce script lui-même qui est lancé, on lance la
# méthode avec les données de test
if $0 == __FILE__
  build_table_divisions(divisions_test)
end
