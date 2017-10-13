# encoding: utf-8
class Forum
  class Post

    # Enregistrement du message
    def modify
      user.id == auteur.id || user.admin? || raise('Cette opération ne vous est pas permise.')

      # Enregistrement du texte
     
      new_content = Forum::Post.traite_before_save(param(:post)[:content])
      site.db.update(:forum,'posts_content',{content: new_content, modified_by: user.id},{id: self.id})

      # Si le grade de l'auteur le nécessite, il faut transmettre une nouvelle
      # demande de validation aux administrateurs.
      # SAUF si cette demande a déjà été émise (on le sait en regardant le 4e bit 
      # des options).
      # Note : cela arrive aussi lorsque le message était refusé.
      # Lorsque ce n'est pas un refus, on met le 4e bit à 1 pour indiquer que le message
      # doit être validé mais qu'il peut tout de même être affiché.
      if user.grade < 4 && (refused? || data[:options][3] == '0')
        # Noter qu'un administrateur ne passera jamais par là, même lorsqu'il modifie 
        # le message d'un auteur de grade < 4
        if false == refused?
          opts = data[:options]
          opts[3] = '1'
          site.db.update(:forum,'posts',{options: opts},{id: self.id})
        end
        require_lib('forum:mails')
        Forum.message_to_admins({
          subject: "Message forum modifié à valider",
          formated: true,
          message: <<-HTML
          <p>Cher administrat<%=f_rice%>,</p>
          <p>Je vous informe qu'un message #{refused? ? 'refusé ' : ''}vient d'être modifié et doit être validé.</p>
          <p>Vous le trouverez à l'adresse :</p>
          <p class="center">#{simple_link(self.route(:full)+'?op=v', 'Valider le message')}</p>"
          <p class="tiny">Le lien ci-dessus permet de rejoindre le formulaire de validation du message, pour l'accepter, le détruire ou le refuser.</p>
          HTML
        })
        __notice 'Une nouvelle demande de validation a été envoyée aux administrateur. Merci de votre patience.'
      end
      # On retourne au sujet
      redirect_to "forum/sujet/#{self.sujet_id}?pid=#{self.id}"
    end


    # Retourne true si c'est un message refusé
    def refused?
      data[:options][2] == '1'
    end

    # Retourne true si c'est un message détruit
    def destroyed?
      data[:options][1] == '1'
    end

    # Retourne la version d'affichage du message lorsqu'il est détruit
    #
    def show_when_destroyed
      <<-HTML
      <div class="red cadre">Ce message a été détruit, il ne peut pas être modifié.</div>
      <section>#{data[:content]}</section>
      HTML
    end

    # Détraite le message pour son affichage dans le textarea
    # Si param(:post) est défini, on prend sa propriété :content car ça
    # correspond à un rechargement du formulaire, peut-être pour une correction à opérer
    def detraite_content
      if param(:post) && param(:post)[:content].nil_if_empty != nil
        param(:post)[:content]
      else
        # Traiter le contenu enregistré pour pouvoir l'éditer
        # Tous les <p>...</p> sont supprimés ainsi que les balises HTML remplacées
        c = data[:content]
        c.gsub!(/<p>(.*?)<\/p>/, "\\1\n\n")
        c.gsub!(/<(.*?)>/, '[\1]')
        return c
      end
    end
  end #/Post
end #/Forum
