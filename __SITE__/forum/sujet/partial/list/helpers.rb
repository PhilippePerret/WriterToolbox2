# encoding: utf-8
debug "-> #{__FILE__}"

class Forum
  class << self


    def boutons where
      debug "User grade : #{user.grade.inspect}"
      @boutons ||=
        begin
          bs = String.new
          case true
          when user.grade > 4
            bs << simple_link('forum/sujet/new', 'Nouveau sujet/nouvelle question')
          when user.grade > 0
            bs << simple_link('forum/sujet/new', "Nouvelle question")
          end
          bs
        end
      return "<div class=\"forum_boutons #{where}\">#{@boutons}</div>"
    end

  end #/<< self Forum

  class Sujet

    MAX_SUJETS = 20

    class << self

      # Retourne le code HTML des boutons pour voir les
      # sujets précédents et suivants
      def nav_boutons from, where
        @nav_boutons ||=
          begin
            from = from.to_i
            bs = String.new
            from_sujet = from - max_sujets
            from_sujet >= 0 || from_sujet = 0
            to_sujet   = from + max_sujets
            if from > max_sujets - 1
              bs << "<a href=\"forum/sujet/list?from=#{from_sujet}\">Sujets précédents</a>"
            end
            if to_sujet < nombre_sujets-1
              bs << "<a href=\"forum/sujet/list?from=#{to_sujet}\">Sujets suivants</a>"
            end
            bs
          end
        return "<nav class=\"nav_boutons #{where}\">#{@nav_boutons}</nav>"
      end

      # Retourne le code HTML de la liste des sujets
      #
      # @param {String} from
      #                 Index du premier sujet. 0-start.
      #                 Noter qu'il est String car il vient de l'url
      #
      # C'est une requête avec jointure qui permet de récupérer les
      # pseudo des créateurs des sujets (leur pseudo) en même temps que
      # les données des sujets.
      #
      def list from
        from = from.to_i
        request = <<-SQL
        SELECT s.*, u.pseudo AS creator_pseudo, uu.pseudo AS auteur_pseudo, uu.id AS auteur_id
        FROM sujets s
        INNER JOIN `boite-a-outils_hot`.users u ON s.creator_id = u.id
        INNER JOIN posts p ON s.last_post_id = p.id
        INNER JOIN `boite-a-outils_hot`.users uu ON p.user_id = uu.id
        WHERE SUBSTRING(specs,1,1) = "1"
        ORDER BY updated_at DESC 
        LIMIT #{from}, #{max_sujets};
        SQL
        #debug "Request: #{request.inspect}"
        site.db.use_database(:forum)
        result = site.db.execute(request)
        #debug "Nombre de sujets relevés : #{result.count}"
        result.collect do |hsujet|
          #debug "hsujet : #{hsujet.inspect}"
          div_sujet hsujet
        end.join('')
      end

      # On a besoin du module pour construire le sujet
      # Définit notamment 'div_sujet'
      require './__SITE__/forum/_lib/_not_required/module/sujet_build'

      # Retourne le nombre total de sujets
      def nombre_sujets
        @nombre_sujets ||= site.db.count(:forum,'sujets',"SUBSTRING(specs,1,1)='1'")
      end

      # Nombre maximum de sujets
      def max_sujets
        @max_sujets ||= MAX_SUJETS
      end
    end #/<< self Sujet
  end #/Sujet
end #/Forum
