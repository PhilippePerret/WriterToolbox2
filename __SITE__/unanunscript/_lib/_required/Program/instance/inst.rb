# encoding: UTF-8

class UUProgram

  include PropsAndDbMethods

  attr_reader :id

  # Instanciation du programme Un an un script
  # @param {Fixnum} pid
  #                 Identifiant du programme, fourni ou non
  #
  def initialize pid = nil
    @id = pid
    
  end

  # Les méthodes de propriétés et de base ont besoin de
  # connaitre la base et la table de cette classe.
  def base_n_table
    @base_n_table ||= [:unan, 'programs']
  end
end
