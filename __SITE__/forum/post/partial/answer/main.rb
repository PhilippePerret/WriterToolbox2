# encoding: utf-8
# debug "-> #{__FILE__}"
class Forum
  class Post

    P_SEPARATOR = "</p><p>"

    # Pour sauver la réponse et la publier immédiatement si le grade de
    # l'auteur le permet.
    # 
    # Publier une réponse revient à créer un nouveau message
    # pour le fil (sujet) courant, désigné par `post.data[:sujet_id]`
    #
    def save_and_publish
      # L'auteur de la réponse est-il susceptible de déposer
      # une réponse à un message ?
      auteur_reponse.grade > 2 || begin
        return __error("Vous n'êtes pas abilité#{auteur_reponse.f_e} à répondre à des messages ou des questions.")
      end

      # La réponse doit-elle être validée ?
      validation_requise = auteur_reponse.grade < 4

      # On crée le nouveau message qui constitue la réponse
      data_new_post = {
        user_id:   auteur_reponse.id,
        sujet_id:  self.sujet_id,     # le même que l'original
        parent_id: self.id,           # ce post
        options:   "#{validation_requise ? '0':'1'}0000000"
      }
      new_post_id = site.db.insert(:forum,'posts',data_new_post)

      # Ajouter la donnée DB pour les votes
      votes_new_post = {
        id: new_post_id,
        vote: 0
      }
      site.db.insert(:forum,'posts_votes',votes_new_post)

      # Ajouter la donnée pour le CONTENU du message
      # Note : la méthode `traite_before_save` traite la réponse avant
      # son enregistrement pour éviter tout code malveillant.
      content_new_post = {
        id: new_post_id,
        content: traite_before_save(answer)
      }
      site.db.insert(:forum,'posts_content', content_new_post)

      # Instance {Forum::Post} du nouveau message
      new_post = Forum::Post.new(new_post_id)
      
      # Si le bouton pour suivre est coché, il faut faire suivre le
      # sujet par l'auteur de la réponse.
      suivre_sujet = data_param[:suivre] != nil
      auteur_rep_suit = Forum::Sujet.user_suit_sujet?(auteur_reponse, data[:sujet_id])
      if auteur_rep_suit != suivre_sujet
        if auteur_rep_suit
          # Il faut détruire la donnée de suivi
          # TODO
          __notice("Vous ne suivez plus ce sujet.")
        else
          # Il faut ajouter une donnée de suivi
          # TODO
          __notice("Vous suivez à présent ce sujet.")
        end
      end

      if validation_requise
        # Le message a besoin d'être validé, on s'arrête là en en informant
        # l'auteur.
        # Avertir les administrateurs de la validation nécessaire
        new_post.notify_admin_post_require_validation
        __notice("Votre réponse a été enregistrée, elle devra être validée avant d’être publiée.")
        # Il faut donner à l'utilisateur un lien pour retourner au sujet
        lien = simple_link("forum/sujet/#{self.sujet_id}?from=-1", 'Retourner au sujet')
        @OUTPUT = "<div class=\"center\"><span class=\"cadre\">#{lien}</span></div>"
      else
        # Si la validation n'est pas requise, on valide immédiatement le
        # message.
        require_relative '../validate/main.rb'
        new_post.validate
      end
    end


    # Méthode pour notifier les administrateurs que ce nouveau message
    # est à valider.
    def notify_admin_post_require_validation
      require_folder './lib/procedure/user/send_mail'
              
      lien = "<a href=\"http://#{site.configuration.url_online}/forum/post/#{self.id}?op=v\">valider le message</a>"
      message_template = <<-HTML
        <p>Cher administrat<%=f_rice%>,</p>
        <p>Un nouveau message est à valider sur le forum.</p>
        <p>Vous pouvez le valider à l'aide du lien ci-dessus :</p>
        <p>#{lien}</p>
        <p>Information sur le message :</p>
        <p>Message ##{self.id} de #{self.auteur.pseudo} (##{self.auteur.id})</p>
        <p>Merci à vous.</p>
        HTML
      data_mail = {
        from:    site.configuration.mail,
        subject: "Message forum à valider",
        formated: true,
        message: nil
      }
      site.db.select(
        :hot,'users',
        "(CAST(SUBSTRING(options,1,1) AS UNSIGNED) & 1) OR CAST(SUBSTRING(options,2,1) AS UNSIGNED) > 6",
        [:id, :pseudo, :mail]
      ).each do |hadmin|
        debug "Administrateur contacté : #{hadmin.inspect}"
        admin = User.get(hadmin[:id])
        data_mail[:message] = ERB.new(message_template).result(admin.bind)
        Mailer.send_mail_to_user(admin, data_mail)
      end
    end

    # Traiter le code du message avant son enregistrement
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
    
    def output_post_operation
      @OUTPUT || ''
    end
    
    # Pour montre l'aperçu du message
    #
    # La méthode retourne le code HTML à insérer dans la page pour voir
    # à quoi ressemblera le message.
    def apercu
     @OUTPUT = '[Aperçu du message tel qu’il est écrit]'
    end

    # La réponse donnée
    # Soit elle est définie dans les paramètres (param :post)[:answer],
    # Soit on prend le texte du message original, et on lui ajoute les
    # balise de l'auteur pour faire des citations.
    def answer
      @answer ||=
        begin
          if data_param.nil?
            taguser = "USER##{auteur.pseudo}"
            c = data[:content].strip
            c.start_with?('<p>') && c = c[3..-1]
            c.end_with?('</p>')  && c = c[0..-5]
            c.split(P_SEPARATOR).collect{|p| "[#{taguser}]<p>#{p}</p>[/#{taguser}]"}.join("\r\n\r\n")
          else
            data_param[:answer]
          end
        end
    end


    # Les données telles qu'elles sont dans les paramètres (après la
    # soumission du formulaire)
    def data_param ; @data_param ||= param(:post) end

    # {User} Auteur de la réponse courante
    # C'est l'user courant au moment du dépôt de la réponse, mais ça
    # peut être la donnée enregistrée dans le formulaire lorsque c'est une
    # validation ou autre.
    def auteur_reponse
      @auteur_reponse ||= User.get(data_param[:auteur_reponse_id])
    end


  end #/Post
end #/Forum
