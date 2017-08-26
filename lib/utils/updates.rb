# encoding: UTF-8
=begin

   Gestion des actualités du site

=end
class Updates


    extend PropsAndDbMethods
    include PropsAndDbMethods

    TYPES = {
      site:       {hname: 'La Boite à Outils'},
      narration:  {hname: 'Collection Narration'},
      analyse:    {hname: 'Analyse de film'},
      unan:       {hname: 'Programme UNAN'},
      video:      {hname: 'Tutoriel-vidéo'},
      forum:      {hname: 'Forum'},
      filmodico:  {hname: 'Filmodico'},
      scenodico:  {hname: 'Scénodico'}
    }
                                          
  # --------------------------------------------------------------------------------
  #     CLASSE
  # --------------------------------------------------------------------------------
  class << self


    # Ajoute une actualité dans la base
    #
    # @param {Hash} hdata
    #               Les données de l'actualité
    def add hdata
      data_valides?(hdata) || return
      insert(hdata)
    end

    # Return TRUE si les données sont valides, FALSE dans le
    # cas contraire.
    def data_valides? hdata
      hdata || raise("Il faut fournir les données à valider.")
      hdata[:message] = hdata[:message].nil_if_empty
      hdata[:message] || raise("Il faut impérativement définir le message de l'actualisation.")
      hdata[:type] && TYPES.key?(hdata[:type]) || raise("Le type #{hdata[:type]} est inconnu de nos services…")

      return true
    rescue Exception => e
      __error e.message
      return false
    end
    def base_n_table
      @base_n_table ||= [:cold, 'updates'] 
    end
  end #/<< self

  # --------------------------------------------------------------------------------
  #    INSTANCE 
  # --------------------------------------------------------------------------------

  def initialize hdata = nil
    hdata && dispatch(hdata)
  end

  def base_n_table ; self.class.base_n_table end
    
end #/Updates
