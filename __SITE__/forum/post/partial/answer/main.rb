# encoding: utf-8
class Forum
  class Post

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
      #
      # Il peut y avoir deux raisons pour lesquelles le post doit être
      # validé. D'abord, si l'auteur a un grade inférieur à 4, ses messages sont
      # systématiquement validés.
      # Ensuite, une validation est requise lorsque l'auteur a un grade entre 4 et 6
      # et que le sujet pour lequel il écrit n'est pas validé (il s'agit alors du
      # premier message de ce sujet, et la validation du premier message doit aussi
      # valider le sujet
      #
      validation_requise =
        if auteur_reponse.grade < 4
          true
        elsif auteur_reponse.grade < 7
          !sujet_is_validated?
        else
          false
        end



      require_lib('forum:create_post')
      pdata = {
        parent_id: self.id,
        content:   answer   # non formaté (le sera dans la méthode create ci-dessous)
      }
      new_post_id = Forum::Post.create auteur_reponse, self.sujet_id, pdata

      # Instance {Forum::Post} du nouveau message
      new_post = Forum::Post.new(new_post_id)

      # Si le bouton pour suivre est coché, il faut faire suivre le
      # sujet par l'auteur de la réponse.
      suivre_sujet = data_param[:suivre] != nil
      auteur_rep_suit = Forum::Sujet.user_suit_sujet?(auteur_reponse, data[:sujet_id])
      if auteur_rep_suit != suivre_sujet
        site.db.use_database :forum
        values = [auteur_reponse.id, data[:sujet_id]]
        request, message =
          if auteur_rep_suit
            # Il faut détruire la donnée de suivi
            ["DELETE FROM follows WHERE user_id = ? AND sujet_id = ?", "Vous ne suivez plus ce sujet."]
          else
            # Il faut ajouter une donnée de suivi
            values << Time.now.to_i
            ['INSERT INTO follows (user_id, sujet_id, created_at) VALUES (?,?,?)', "Vous suivez à présent ce sujet."]
          end
        site.db.execute(request, values)
        # Message
        # Noter qu'en cas de validation immédiate, il y a une redirection vers
        # la liste du sujet, et ce message est donc enregistré pour la redirection
        __notice(message)
      end

      if validation_requise
        debug "VALIDATION REQUISE (##{new_post.id})"
      else
        debug "VALIDATION NON REQUISE (##{new_post.id})"
      end
      if validation_requise
        # Le message a besoin d'être validé, on s'arrête là en en informant
        # l'auteur.
        # Avertir les administrateurs de la validation nécessaire
        new_post.notify_admin_post_require_validation(!sujet_is_validated?)

        if sujet_is_validated?
          __notice("Votre réponse a été enregistrée, elle devra être validée avant d’être publiée.")
          # Il faut donner à l'utilisateur un lien pour retourner au sujet
          lien = simple_link("forum/sujet/#{self.sujet_id}?from=-1", 'Retourner au sujet')
          @OUTPUT = "<div class=\"center\"><span class=\"cadre\">#{lien}</span></div>"
        else
          # Quand le sujet n'est pas validé, c'est qu'il s'agit du premier
          # message. Il y est donc inutile de donner un message à l'auteur
          # du message (et du sujet) puisque c'est surtout son sujet qu'on
          # traite.
        end
      else
        # Si la validation n'est pas requise, on valide immédiatement le
        # message.
        require_relative '../validate/main.rb'
        new_post.validate
      end
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


    # Retourne true si le sujet du post n'est pas encore validé
    def sujet_is_validated?
      @isfpofs.nil? && '1' == site.db.select(
          :forum,'sujets',{id:sujet_id},[:specs]
        )[0][:specs][0]
      @isfpofs
    end


  end #/Post
end #/Forum
