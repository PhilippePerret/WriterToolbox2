# encoding: utf-8

# On a besoin de ce (petit) module pour obtenir le tarif du programme.
require './__SITE__/unanunscript/_lib/_required/UnanUnscript/class/class'

class Outils
  class << self


    # Retourne le code HTML de la liste des outils
    def output
      c = String.new
      div_quick_access = String.new
      c << '<dl id="tool_list">'
      list.each do |toolid, tdata|
        titre = tool_title(tdata)
        div_quick_access << titre
        c << "<dt id=\"dt-#{toolid}\">#{titre}</dt>"
        c << "<dd>#{description tdata}</dd>"
      end
      c << '</dl>'

      c = "<div id=\"quick_access\"><div class=\"titre\">Accès rapide</div>#{div_quick_access}</div>" + c
      return c
    end

    # Retourne le titre de l'outil, lié à son accueil
    def tool_title htool
      "<a href=\"#{htool['home']|| 'outils'}\">#{htool['name']}</a>"
    end

    def description htool
      c = String.new
      desc = htool['description']
      desc.match(/#\{/) && desc = eval('"'+desc.gsub(/"/,'\"')+'"')
      c << desc
      return c
    end


    # Retourne la liste des outils, un Hash avec en clé un symbol représentant
    # l'outil et en valeur un hash des valeurs.
    # C'est le fichier tool_list.yaml qui est lu
    def list
     @list ||=
       begin
         require 'yaml'
         YAML.load(File.read(File.join(thisfolder,'tool_list.yaml')).force_encoding('utf-8'))
       end
    end

    def thisfolder
      @thisfolder ||= File.dirname(__FILE__)
    end
  end #/<< self Outils



end #/Outils
