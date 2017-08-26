# encoding: UTF-8


class UUProjet

  extend  PropsAndDbMethods
  include PropsAndDbMethods

  class << self

    # Crée un nouveau projet pour l'utilisateur +user+
    #
    # @param {User} user
    #               Instance User de l'utilisateur pour lequel
    #               créer le nouveau projet.
    # @param {Hash} options
    #               Eventuellement, les options pour cette création.
    #               Par exemple :program_id pour l'identifiant du
    #               programme associé à ce projet.
    #
    def create_projet_for user, options = nil
      options ||= Hash.new

      data_projet = {
        auteur_id:  user.id,
        program_id: options[:program_id],
        titre:      nil,
        resume:     nil,
        specs:      '10000000'
      }

      return insert(data_projet)

    end

    def base_n_table
      @base_n_table ||= [:unan, 'projets']
    end
  end #/ << self

  # ---------------------------------------------------------------------
  #   INSTANCE
  # ---------------------------------------------------------------------

  def base_n_table ; self.class.base_n_table end
end #/ UUProjet
