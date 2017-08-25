# encoding: UTF-8

class UUProjet

  include PropsAndDbMethods
  
  # Instanciation du projet d'identifiant +pid+ ou instanciation
  # simple, sans ID
  #
  def initialize pid = nil
    @id = pid
  end

  def base_n_table
    @base_n_table ||= [:unan, 'projets']
  end
  
end #/UUProjet
