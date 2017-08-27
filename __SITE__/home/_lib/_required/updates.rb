# encoding: UTF-8

require './lib/utils/updates'

#
# Extension de la class Updates pour la page d'accueil.
#
class Updates

  class << self

    def section_last_updates
      c = '<fieldset id="last_updates">'
      c << '<legend>Dernières actualités</legend>'
      last_updates.each do |type, databytype|
        debug "Traitement du type #{type.inspect}"
        debug "databytype: #{databytype.inspect}"
        c << "<div class=\"titre\">#{TYPES[type][:hname]}</div>"
        c << "<ul id=\"updates-#{type}\" class=\"updates\">"
        c << databytype[:updates].collect { |update| update.as_li }.join('')
        c << "</ul>"
      end
      c << '</fieldset>'
      return c
    end

    # Retourne une liste Array des instances Updates des derniers
    # actualités devant être affichées.
    # Les actualités, pour être retenues, doivent :
    #   - être moins vieille d'un an
    #   - avec le premier bit des options > à 0
    def last_updates 
      @last_updates ||= begin
                          list({
                            created_after:  Time.now.to_i - 365*24*3600, 
                            displayable:    true, 
                            group_by_type:  true,
                            limit:          10
                          })
                        end
    end

  end #/<< self

end
