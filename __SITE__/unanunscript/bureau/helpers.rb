# encoding: utf-8

class Site

   def onglets_sections
     '<div id="onglets_sections">'+
     Unan::DATA_SECTIONS.collect do |ksection, dsection|
       sel = ksection == section.id ? ' selected' : ''
       "<a id=\"unan_#{ksection}\" href=\"unanunscript/bureau/#{ksection}\" class=\"onglet#{sel}\">#{dsection[:hname]}</a>"
     end.join('')+
     '</div>'
   end
end
