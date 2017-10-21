# encoding: utf-8
class Analyse
  class AFile

    attr_accessor :ufiler


    class UFiler

      # L'analyse {Analyse} dont il est question
      attr_reader :analyse

      # Le fichier {Analyse::AFile}
      attr_reader :afile

      # L'User original
      attr_reader :real_user

      # Instanciation
      #
      def initialize analyse, afile, ruser
        @analyse    = analyse
        @afile      = afile
        @real_user  = ruser
        check_args_or_raise
      end

      # TRUE si c'est le créateur du fichier
      def creator? ; state(:creator) end
      # TRUE si c'est un rédacteur du fichier
      def redactor? ; state(:redactor) end
      # TRUE s'il peut éditer le fichier
      def can_edit?
        @they_can_edit.nil? && @they_can_edit = redactor? || corrector? || admin?
        @they_can_edit
      end
      # TRUE si c'est un correcteur du fichier (entre autres)
      def corrector? ; state(:corrector) end
      # TRUE is c'est SEULEMENT un correcteur du fichier
      def simple_corrector? ; state(:scorrector) end

      # Quelques raccourcis
      # ===================
      def admin?      ; real_user.admin?      end
      def identified? ; real_user.identified? end
      def analyste?   ; real_user.analyste?   end

      def state key
        @states ||= Hash.new
        @states[key] ||=
          case key
          when :creator     then role & 1 > 0
          when :redactor    then role & (1|2) > 0
          when :corrector   then role & 4 > 0
          when :scorrector  then role == 4
          else raise "La clé `#{key}` est inconnue comme statut."
          end
      end

      # Le rôle de l'user sur le fichier

      def role
        @role ||= data.nil? ? 0 : data[:role]
      end

      # Les données de l'user pour le fichier
      #
      # Comme pour l'analyse, ces données peuvent ne pas exister puisqu'il
      # s'agit ici d'un user quelconque, qui peut même ne pas être identifié
      # ou inscrit.

      def data
        @data ||=
          site.db.select(
            :biblio, 'user_per_file_analyse',
            {file_id: afile.id, user_id: real_user.id}
        ).first
      end

      # Vérification des arguments envoyés à l'instanciation

      def check_args_or_raise
        @analyse.is_a?(Analyse)      || raise('Le premier argument doit être une instance d’Analyse.')
        @afile.is_a?(Analyse::AFile) || raise('Le deuxième argument doit être une instance d’Analyse::AFile.')
        @real_user.is_a?(User)       || raise('Le troisième argument doit être une instance d’User.')
      end


    end #/UFiler

  end #/AFile
end #/Analyse
