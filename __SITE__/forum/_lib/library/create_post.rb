# encoding: utf-8
=begin

   Module pour la création d'un post

=end
class Forum
  class Post
    class << self

      # Créer le post
      #
      # @param {User}   auteur
      #                 L'auteur du message.
      # @param {Fixnum} sujet_id
      #                 ID du sujet auquel appartient le message
      # @param {Hash}   pdata
      #                 Les données à enregistrer, et principalement :content
      #                 le contenu textuel non traité du message.
      #                 :parent_id      ID du message parent, si c'est une réponse
      #                 :content        {String} Le contenu du message
      #                 :is_new_sujet   Mis à true si c'est un nouveau sujet.
      #
      # @return {Fixnum} ID du nouveau message
      #
      def create auteur, sujet_id, pdata

        # Données à enregistrer
        data2save = {
          sujet_id:  sujet_id,
          user_id:   auteur.id,
          parent_id: pdata[:parent_id],
          options:   options_post(pdata.merge(auteur: auteur))
        }
        post_id = site.db.insert(:forum,'posts',data2save)

        # Donnée pour le contenu

        site.db.insert(:forum,'posts_content',{id: post_id, content: cformated(pdata[:content]) })

        # Donnée pour les votes

        site.db.insert(:forum,'posts_votes',{id: post_id, vote: 0})

        return post_id
      end


      # Retourne les options pour le nouveau message, en fonction
      # de l'auteur du message
      def options_post pdata
        grade = pdata[:auteur].grade
        validation_required = grade < 4 || (pdata[:is_new_sujet] && grade < 7)
        o = String.new
        o << (validation_required ? '0' : '1')
        o << '0'*7
        return o
      end

      # Retourne le contenu du message formaté
      def cformated content
        c = content.nil_if_empty
        c ||= "Premier message du sujet ou de la question."
        self.traite_before_save(c)
      end

    end #/<< self


    # Méthode d'instance pour notifier les administrateurs de
    # la création du nouveau sujet d'identifiant +sujet_id+ par
    # l'user +creator+ dont le post courant est le premier message
    def notify_admin_new_sujet creator, sujet_id
      require_lib('site:mails_admins')
      isujet = Forum::Sujet.new(sujet_id)
      message_template = <<-HTML
        <p>Ch<%=f_ere%> administrat<%=f_rice%>,</p>
        <p>Nouveau sujet créé sur le forum par l’utilisateur #{simple_link(creator.route(:online), creator.pseudo)} :</p>
        <p class="center">#{simple_link(isujet.route(true), isujet.data[:titre])}</p>
        <p>Note : ce sujet ne nécessite pas de validation.</p>
      HTML
      data_mail = {
        subject: 'Création d’un nouveau sujet',
        formated: true,
        message: message_template
      }
      site.mail_to_admins(data_mail, forum: true)
    end

    # Méthode pour notifier les administrateurs que ce nouveau message
    # est à valider.
    # Utilisé pour la création d'un message par un utilisateur ayant un
    # grade inférieur ou un sujet créé.
    def notify_admin_post_require_validation for_new_sujet = false
      debug "for_new_sujet = #{for_new_sujet.inspect}"
      require_lib('site:mails_admins')
      subject = for_new_sujet ? 'Sujet forum à valider' : 'Message forum à valider'
      ajout_nouveau_sujet =
        if for_new_sujet
          '<p>Ce post validera par la même occasion le sujet dont il est le premier post.</p>'
        else
          ''
        end
      lien = "<a href=\"http://#{site.configuration.url_online}/forum/post/#{self.id}?op=v\">valider le message</a>"
      message_template = <<-HTML
        <p>Cher administrat<%=f_rice%>,</p>
        <p>Un nouveau message est à valider sur le forum.</p>
        <p>Vous pouvez le valider à l'aide du lien ci-dessus :</p>
        <p>#{lien}</p>
        #{ajout_nouveau_sujet}
        <p>Information sur le message :</p>
        <p>Message ##{self.id} de #{self.auteur.pseudo} (##{self.auteur.id})</p>
        <p>Merci à vous.</p>
        HTML
      data_mail = {
        subject: subject,
        formated: true,
        message: message_template
      }
      site.mail_to_admins( data_mail, forum: true )
    end
  end #/Post
end #/Forum
