# encoding: utf-8
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

  class Sujets
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
        req = String.new
        req << 'SELECT tsujets.*, tusers.pseudo AS creator_pseudo'
        req << ' FROM sujets tsujets'
        req << ' INNER JOIN `boite-a-outils_hot`.users tusers'
        req << ' WHERE tsujets.creator_id = tusers.id'
        req << ' AND SUBSTRING(specs,1,1) = "1"' # seulement les validés
        req << ' ORDER BY updated_at DESC'
        req << " LIMIT #{from}, #{max_sujets}"
        site.db.use_database(:forum)
        site.db.execute(req).collect do |hsujet|
          div_sujet hsujet
        end.join('')
      end

      # Retourne le code HTML du conteneur du sujet
      def div_sujet hsujet
        sid = hsujet[:id]
        lien = simple_link("forum/sujet/#{sid}", hsujet[:titre])
        last_post_date =
          if hsujet[:last_post_id]
            Time.at(hsujet[:updated_at]).strftime("%d %m %Y - %H:%M")
          else
            '---'
          end
        lien_last_post = 
          if hsujet[:last_post_id] 
            simple_link("forum/message/#{hsujet[:last_post_id]}", 'Dernier message')
          else
            ''
          end
        lien_creator = simple_link("user/profil/#{hsujet[:creator_id]}", hsujet[:creator_pseudo])
        <<-HTML
<div id='sujet-#{sid}' class='sujet'>
  #{lien}
  #{lien_last_post}
  <span class='messages_count' id='messages_count-#{sid}'>#{hsujet[:count]}</span>
  <span class='last_message_date' id='last_message_date-#{sid}'>#{last_post_date}</span>
  <span class='created_at'>#{Time.at(hsujet[:created_at]).strftime('%d %m %Y - %H:%M')}</span>
  <span class='creator' id='creator-#{sid}'>#{lien_creator}</span>
</div>
        HTML

      end
      # Retourne le nombre total de sujets
      def nombre_sujets
        @nombre_sujets ||= site.db.count(:forum,'sujets',"SUBSTRING(specs,1,1)='1'") 
      end

      # Nombre maximum de sujets
      def max_sujets
        @max_sujets ||= MAX_SUJETS
      end
    end #/<< self Sujets
  end #/Sujet
end #/Forum
