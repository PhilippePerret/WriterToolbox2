# encoding: UTF-8
class Unan
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

        # Données du programme à créer
        data_program = {
          auteur_id:            user.id,
          projet_id:            options[:projet_id] || nil,
          rythme:               5,
          current_pday:         1,
          current_pday_start:   Time.now.to_i,
          options:              '100000000000',
          points:               0,
          retards:              nil,
          pauses:               nil
        }

        prog_id = insert(data_program, set_id = true)
        # On met tout de suite ce programme en programme courant de
        # l'auteur
        user.var['unan_program_id'] = prog_id

        # On retourne l'ID dont aura besoin la suite du programme.
        return prog_id
      end

    end #/<< self (UUProgram)
  end   #/UUProgram
end     #/Unan
