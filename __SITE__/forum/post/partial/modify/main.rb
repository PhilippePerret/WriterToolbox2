# encoding: utf-8
class Forum
  class Post

    # Enregistrement du message
    def modify
      
      user.id == auteur.id || user.admin? || raise('Cette opération ne vous est pas permise.')

      new_content = traite_before_save(param(:post)[:content])

      # Noter que ça peut être un administrateur ou l'auteur du message
      # qui vient modifier.
      new_data = Hash.new
      new_data.merge!(modified_by: user.id)

      # Enregistrement du texte
     
      site.db.update(:forum,'posts_content',{content: new_content},{id: self.id})

      # Enregistrement des nouvelles données

      site.db.update(:forum,'posts',new_data,{id: self.id})

      # Si le grade de l'auteur le nécessite, il faut transmettre une nouvelle
      # demande de validation aux administrateurs.
      # Note : cela arrive aussi lorsque le message était refusé.
      if user.grade < 4
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
  end #/Post
end #/Forum
