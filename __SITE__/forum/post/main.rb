# encoding: utf-8
class Forum
  
  class << self

    # Pour faire une annonce à tous les administrateurs du site, par
    # exemple pour valider un message
    #
    # @param {Hash} data_mail
    #               Les données du mail, avec notamment :subject et :message
    #               :message sera considéré comme un template déserbé avec l'administrateur
    #               bindant. Cela permet notamment de régler le pseudo des administrateurs ou
    #               le féminin/masculin, grâce à des codes comme "Cher administrat<%=f_rice%>"
    def message_to_admins data_mail
      require_folder './lib/procedure/user/send_mail'
      data_mail.key?(:from) || data_mail.merge!(from: site.configuration.mail)
      message_template = data_mail.delete(:message)
      data_mail[:message] = nil
      site.db.select(
        :hot,'users',
        "(CAST(SUBSTRING(options,1,1) AS UNSIGNED) & 1) OR CAST(SUBSTRING(options,2,1) AS UNSIGNED) > 6",
        [:id, :pseudo, :mail]
      ).each do |hadmin|
        #debug "Administrateur contacté : #{hadmin.inspect}"
        admin = User.get(hadmin[:id])
        data_mail.merge!(message: ERB.new(message_template).result(admin.bind))
        Mailer.send_mail_to_user(admin, data_mail)
      end
    end
  end



  class Sujet
    class << self

    # Retourne true si l'user +user+ suit le sujet +sujet_id+
    def user_suit_sujet? user, sujet_id
      site.db.count(:forum,'follows',{user_id: user.id, sujet_id: sujet_id}) == 1
    end

    end #/<< self
  end #/Sujet

  class Post

    P_SEPARATOR = "</p><p>"

    class << self

      # Ajoute le message d'identifiant +post_id+ à l'user +user+
      #
      # La méthode vérifie que le message appartienne bien à l'auteur
      # spécifié.
      #
      # @param {User|Fixnum}  user
      #                       L'auteur du message ou son ID
      # @param {Fixnum}       post_id
      #                       ID du message.
      def add_post_to_user user, post_id
        user_id = user.is_a?(User) ? user.id : user
        user_id.is_a?(Fixnum) || raise(ArgumentError.new('Il faut spécifié l’user du post.'))
        post_id.is_a?(Fixnum) || raise(ArgumentError.new('Il faut spécifié l’ID (Fixnum) du message.'))
        hpost = site.db.select(:forum,'posts',{id: post_id},[:user_id]).first
        hpost != nil || raise(ArgumentError.new("L’ID #{post_id} ne correspond pas à un message existant."))
        if hpost[:user_id] == user_id
          huser = site.db.select(:forum,'users',{id: user_id}).first
          if huser.nil?
            # <= C'est le tout premier message de l'auteur
            # => Il faut lui créer une donnée complète et l'insérer
            request = <<-SQL
            INSERT INTO users (id, count, last_post_id, options) VALUES (?, ?, ?, ?);
            SQL
            values = [user_id, 1, post_id, '0'*8]
          else
            # <= Ce n'est pas le premier message de l'auteur
            # => Il faut imcrémenter ses messages et régler le dernier ID de message
            request = <<-SQL
            UPDATE users SET count = ?, last_post_id = ?
            SQL
            values = [huser[:count] + 1, post_id]
          end
          site.db.use_database(:forum)
          site.db.execute(request, values)
        else
          raise ArgumentError.new("Le message n’appartient pas à cet auteur.")
        end
      end
    end #/<< self Forum::Post

    
    # Traiter le code du message avant son enregistrement
    #
    # La méthode est mise ici car elle doit servir aussi bien le module answer
    # que le module modify.
    # 
    def traite_before_save contenu
      contenu.gsub!(/<.*?>/,'')     # toutes les balises <...>
      contenu.gsub!(/\r/,'')
      contenu.gsub!(/\n[  \t]+/,"\n")   # tous les lignes pas vraiment vides
      contenu.gsub!(/\n\n+/m,"\n\n") # Triples RC et plus
      
      # On remplace les double-retours chariot
      contenu = contenu.split("\n\n").collect{|p|"<p>#{p.strip}</p>"}.join('')
      # On finit par les RC simples (noter qu'il ne faut surtout pas le
      # faire avant les doubles RC, sinon tous les toucles RC seraient
      # remplacés...)
      contenu.gsub!(/\n/,'<br>')
      return contenu
    end
    
  end #/Post
end #/Forum

# Instance {Forum::Post} du message courant, précisé dans l'url
def post
  @post ||= Forum::Post.new(site.route.objet_id)
end
