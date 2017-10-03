# encoding: utf-8
debug "-> #{__FILE__}"
class Forum
  class Post

    P_SEPARATOR = "</p><p>"

    # Pour publier la réponse.
    # Publier une réponse revient à créer un nouveau message
    # pour le fil (sujet) courant, désigné par `post.data[:sujet_id]`
    #
    def publier

      # TODO S'assure que l'user peut publier cette réponse
      # La réponse doit-elle être validée ?
      validation_requise = auteur_reponse.grade < 4

      # TODO On crée le nouveau message qui constitue la réponse
      data_new_post = {
        user_id:   auteur_reponse.id,
        parent_id: id, # ce post
        options:   "#{validation_requise ? '0':'1'}0000000"
      }
      new_post_id = site.db.insert(:forum,'posts',data_new_post)
      debug "ID post réponse : #{new_post_id}"

      content_new_post = {
        id: new_post_id,
        content: answer
      }
      site.db.insert(:forum,'posts_content', content_new_post)

      votes_new_post = {
        id: new_post_id,
        vote: 0
      }
      site.db.insert(:forum,'posts_votes',votes_new_post)


      # TODO On ajoute ce message à l'user, mais seulement s'il la validation
      # n'est pas requise. Dans le cas contraire, il faut attendre de voir si
      # le message ne sera pas détruit.
      if !validation_requise
        Forum::Post.add_post_to_user(auteur_reponse, new_post_id)
      end
      # TODO Si le bouton pour suivre est coché, il faut faire suivre le
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
      # TODO Si l'auteur de la réponse suivant le sujet et que la case n'est
      # plus cochée, il ne doit plus le suivre.
      # TODO Mettre en forme la réponse à enregistrer
      # TODO Enregistrer la réponse avec sa mise en forme.
      # TODO Il faut indiquer dans le sujet que c'est le tout dernier message
      # TODO si l'auteur de la réponse n'a pas le grade suffisant, il faut
      # avertir les administrateurs pour qu'ils puissent valider le message
      # avant sa publication.
      # TODO Prévenir l'auteur du message que son message a obtenu une
      # réponse, mais seulement si elle est publiée maintenant.
      # (note : il ne faudra pas multiplier les méthodes de publication, donc la
      # validation d'un post devra se faire aussi ici)
      # Confirmer l'opération à l'auteur
      # en tenant compte du grade de l'auteur de la réponse
      __notice(confirmation_suivant_grade_auteur_reponse)
      # TODO Peut-être : rediriger vers la liste du forum avec ce nouveau message
      # en dernier
      redirect_to("forum/sujet/post?from=-1#post-#{new_post_id}")
    end


    def confirmation_suivant_grade_auteur_reponse
      if auteur_reponse.grade >= 4
        "Votre réponse a été publiée."
      else
        "Votre réponse a été enregistrée, elle devra être validée avant d’être publiée."
      end
    end

    # Pour montre l'aperçu du message
    #
    # La méthode retourne le code HTML à insérer dans la page pour voir
    # à quoi ressemblera le message.
    def apercu
     '[Aperçu du message tel qu’il est écrit]'
    end

    # La réponse donnée
    # Soit elle est définie dans les paramètres (param :post)[:answer],
    # Soit on prend le texte du message original, et on lui ajoute les
    # balise de l'auteur pour faire des citations.
    def answer
      @answer ||=
        begin
          if data_param.nil?
            taguser = "USER##{data[:auteur_post_id]}"
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

    # {User} Auteur du message original
    # Mais aussi auteur du nouveau post qui constitue la réponse.
    def auteur_post
      @auteur_post ||= User.get(data[:auteur.id])
    end
    # {User} Auteur de la réponse courante
    def auteur_reponse
      @auteur_reponse ||= user # pour le moment, c'est toujours l'auteur courant
      # Mais tenir compte du fait qu'on passera peut-être par ici pour valider le
      # message et que donc cette auteur de la réponse ne sera plus l'user courant.
    end


  end #/Post
end #/Forum
