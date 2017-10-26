# encoding: utf-8
class Analyse
  class << self

    # Le titre pour toute la section des analyses
    # @usage:     <%= Analyse.main_title %>

    # @param {Hash} options
    #               Permet de définir plus précisément certaines choses,
    #               comme par exemple le sous-menu pour le TITLE de la page
    #               Les paramètres peuvent être :
    #               :subtitle       Sous-titre devant suivre le titre dans TITLE
    def main_titre options = nil
      site.titre_page(
        
        # Le titre proprement dit
        simple_link('analyse/home',"Les Analyses de films",'nodeco'),
        
        # Les liens sous le titre
        {
          subtitle: options && options[:subtitle],
          under_buttons:[
            simple_link('aide?p=analyse','aide'),
            simple_link('analyser','contribuer')
          ]
        }
      ) 
    end
  end #/<< self
end #/Analyse

