# encoding: UTF-8


class UUProgram
class << self

  # Création d'un programme Unan pour l'user +user+
  #
  # @param {User} user
  #               Instance user de l'user pour lequel il faut
  #               construire le programme.
  # @param {Hash} options
  #               Eventuellement, les options à prendre en compte
  #               Par exemple l'identifiant du projet, s'il existe
  #               déjà.
  #
  # @return {Fixnum} program_id
  #                  ID du nouveau programme créé.
  #
  def create_program_for user, options = nil
    options ||= Hash.new

    data_program = {
      auteur_id:    user.id,
      projet_id:    nil,
      rythme:       5,
      current_pday: 1,
      options:      '000000000000',
      points:       0,
      retards:      nil,
      pauses:       nil
    }

    pid = site.db.insert(:unan, 'programs', data_program)

    return pid
  end
end #/ << self
end #/ UUProgram
