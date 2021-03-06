# encoding: UTF-8
class Unan
  class UUProjet
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
          program_id: options[:program_id] || nil,
          titre:      nil,
          resume:     nil,
          specs:      '10000000'
        }

        return insert(data_projet, site_id = true)

      end
    end #/<< self (UUProjet)
  end #/UUProjet
end #/Unan
