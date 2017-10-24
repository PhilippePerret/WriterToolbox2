# encoding: utf-8
class User
  class << self

    # Reçoit le role en nombre (bit) et retourne la
    # valeur humaine.
    # P.e. 4 => "simple correcteur du fichier"
    #
    # @param {Fixnum} role
    #                 Le rôle en valeur intégrale, tel qu'enregistré
    #                 dans la base de donnée (user_per_file_analyse)
    #                 Peut être également fourni en String.
    #
    # @param {User}   who
    #                 L'user visé par ce rôle. Utile pour déterminer
    #                 si l'on va retourner "créateur" ou "créatrice"
    def human_role role, who = nil
      teur = who.nil? ? 'teur' : "t#{who.f_rice}"
      r = role.to_i
      rs = Array.new
      case
      when r.bitin(1) then rs << "créa#{teur}"
      when r.bitin(2) then rs << "rédac#{teur}"
      when r.bitin(4) then rs << "correc#{teur}"
      end
      rs.join(' et ') + ' du fichier'
    end

  end #/<< self
end #/User
