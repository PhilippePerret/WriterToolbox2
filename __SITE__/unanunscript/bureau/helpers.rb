# encoding: utf-8

class Site

  # Fabrication des onglets de chaque section. Une "section" est un type de tâche ou 
  # d'information (projet, préférence, etc.)
  # Pour déterminer le nom des onglets, il faut connaitre le nombre de tâches en cours
  # et savoir si elles sont en dépassement ou non.
   def onglets_sections
     '<div id="onglets_sections">'+
     Unan::DATA_SECTIONS.collect do |ksection, dsection|
       nom_onglet = nom_onglet_section(dsection)
       sel = ksection == section.id ? ' selected' : ''
       "<a id=\"unan_#{ksection}\" href=\"unanunscript/bureau/#{ksection}\" class=\"onglet#{sel}\">#{dsection[:hname]}</a>"
     end.join('')+
     '</div>'
   end

   # Retourne le nom pour l'onglet de section avec, pour les onglets concernant
   # des tâches, le nombre de travaux et l'indication du dépassement le cas
   # échéant.
   def nom_onglet_section dsection
     case dsection[:tache_type]
     when NilClass 
       dsection[:hname]
     else
       total, nb_to_start, nb_overtaken = nombre_taches_type(dsection[:tache_type])
       span_class =
         case true
         when nb_overtaken > 0 then 'red'
         when nb_to_start  > 0 then 'orange'
         else ''
         end
       "#{dsection[:hname]} <span class=\"nombre #{span_class}\">(#{total})</span>"
     end
   end

   def nombre_taches_type ttype
     wheretype = "SUBSTRING(options,5,1) = '#{Unan::Abswork::ITYPES[ttype]}'"
     nbstart = site.db.count(:users_tables,"unan_works_#{user.id}", "#{wheretype} AND status = 0")
     nbgood  = site.db.count(:users_tables,"unan_works_#{user.id}", "#{wheretype} AND status = 1")
     total   = site.db.count(:users_tables,"unan_works_#{user.id}", "#{wheretype} AND status != 9")
     nbover  = total - nbstart - nbgood
     return [total, nbstart, nbover]
   end
end
