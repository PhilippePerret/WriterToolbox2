# encoding: utf-8
=begin
  Module de validation d'un poste
  Il est pensé pour pouvoir fonctionner "seul", c'est-à-dire en étant chargé
  dans cette section aussi bien pour être chargé d'ailleurs
=end
class Forum
  class Post

    # Méthode principale qui valide le post
    #
    # @param {Hash} options
    #               :redirection    {String} La route à prendre après la
    #                               validation.
    #                               Si c'est exactement `false`alors on prend
    #                               la route normale, sans redirection. C'est le
    #                               cas par exemple lorsque l'administrateur doit
    #                               valider un seul message.
    def validate options = nil
      options ||= Hash.new
      # debug "-> Validation du message"
      # On indique que c'est le tout dernier message du sujet
      site.db.update(
        :forum,
        'sujets',
        {last_post_id: self.id},
        {id:sujet_id}
      )

      # Pour rafraichir les données
      @data = @data_mini = nil

      # Pour voir les données
      # debug "data post ##{id} : #{data.inspect}"
      # debug "data mini post ##{id} : #{data_mini.inspect}"

      # Si c'est une réponse (parent_id défini), on avertit l'auteur du
      # message parent qu'il y a une réponse
      data[:parent_id] && Forum::Post.get(data[:parent_id]).auteur.annonce_new_reponse(self)

      # Annonce en page d'accueil
      require './lib/utils/updates'
      Updates.add({
        message: "Message forum de <strong>#{self.auteur.pseudo}</strong>.",
        route:   self.route_in_sujet,
        type:    'forum', 
        options: '10000000' # annonce aux inscrits (qui le souhaitent)

      })

      # On ajoute le post à l'auteur
      Forum::Post.add_post_to_user(self.auteur, self.id)

      # On redirige l'user (ou l'admin) vers la route demandée ou
      # vers la liste du sujet
      if options[:redirection] === false
        # Aucune redirection
        return true
      else
        redirect_to(options[:redirection] || self.route_in_sujet)
      end
    end
    #/validate
    
    # Méthode appelée quand l'administrateur clique le bouton pour
    # valider le message
    # @param {User} admin
    #               L'administrateur qui valide le message
    def validation_par_admin admin
      admin.admin? || raise("Vous essayez vraiment de pénétrer le site en loose-D ?")

      # Marque de validation dans les options du message
      
      opts = self.data[:options]
      opts[0] = '1'
      new_data = {options: opts, valided_by: admin.id}
      site.db.update(:forum,'posts',new_data,{id: self.id})

      # Opérations normales de validation, comme le réglage du dernier
      # post du sujet, du dernier post de l'user, du mail envoyé au l'auteur
      # original du message, etc.

      self.validate(redirection: false)

      # Envoi du mail pour avertir l'auteur du post que son post a
      # été validé.

      self.auteur.send_mail({
        subject: "Validation de votre message sur le forum",
        formated: true,
        message: <<-HTML
        <p>Bonjour #{auteur.pseudo},</p>
        <p>Je vous informe qu’un de vos messages vient d’être validé sur le forum de #{site.configuration.name}.</p>
        <p>Vous pouvez le retrouver à l’adresse ci-dessous :</p>
        <p>#{simple_link(self.route_in_sujet(:full))}</p>
        <p>Merci ià vous de votre participation,</p>
        HTML
      })
      __notice("Le message est validé.")
    end

    # Méthode appelée quand l'administrateur refuse le message
    def refus_par_admin
      motif = param(:post)[:motif]
      __notice("Le message est refusé. L'auteur a été prévenu.")
    end


    # Méthode appelée par le bouton "Détruire", pour détruire le message tout
    # simplement.
    # En fait, pour le moment, "détruire le message" correspond simplement à mettre
    # son deuxième bit d'option à 1 (et, par mesure de prudence, à mettre son premier à 0).
    # On envoie également un mail à l'auteur du message pour l'avertir.
    # Note : si le message était déjà validé, il faut :
    # - décrémenter le nombre de message de l'auteur
    # - voir s'il n'était pas en dernier message de l'auteur et le retirer
    # - voir s'il n'était pas en dernier message du sujet et le retirer
    def destroy_par_admin admin
      admin.admin? || raise("Vous n’êtes pas autorisé à exécuter cette action.")

      # Pour savoir s'il a déjà été validé
      already_validated = data[:options][0] == '1'

      # On marque le post détruit
      opts = data[:options]
      opts[0..1] = '01'
      site.db.update(:forum,'posts',{options: opts, modified_by: admin.id},{id: self.id})
      
      # Si le post était déjà validé, il faut faire encore des choses
      if already_validated
        new_last_post_id = site.db.select(
          :forum,'posts',
          "user_id = #{auteur.id} AND SUBSTRING(options,1,1) != '0' ORDER BY created_at DESC LIMIT 1",
          [:id]
        ).first[:id]
        # Note : ça peut être le même last_post_id, mais peu importe
        req = "UPDATE users SET count = count - 1, last_post_id = #{new_last_post_id} WHERE id = #{auteur.id}"
        site.db.use_database(:forum)
        site.db.execute(req)
      end
      # Envoi du message à l'auteur
      auteur.annonce_destroy_message(self, param(:post)[:motif].nil_if_empty)
      __notice('Le message a été détruit.')
    end
  end #/Post
end #/Forum

class User

  # Pour avertir un auteur qu'un de ses messages a reçu une nouvelle réponse
  #
  # @param {Forum::Post} post
  #                      Le message réponse.
  def annonce_new_reponse post
    url_reponse = "http://#{site.configuration.url_online}/#{post.route_in_sujet}"
    send_mail({
      subject: "Votre message a reçu une réponse sur le forum",
      formated: true,
      message: <<-HTML
      <p>Bonjour #{pseudo},</p>
      <p>Je vous annonce qu’un de vos messages sur le forum a reçu une réponse de #{post.auteur.pseudo}.</p>
      <p>Vous pouvez lire cette <a href="#{url_reponse}">réponse en cliquant ce lien</a>.</p>
      HTML
    })
  end

  # Message envoyé à l'user pour lui annoncer la destruction
  # de son message
  def annonce_destroy_message post, raison
    mess_destroy = <<-HTML
      <p>#{pseudo},</p>
      <p>Votre message sur le forum de #{site.configuration.name} a malheureusement dû être détruit.</p>
      <p>Les raisons en sont les suivantes :</p>
      <p>#{raison ? raison : 'Aucune raison invoquée.'}</p>
      <p>Vraiment désolé pour vous.</p>
    HTML
    send_mail({
      subject: 'Destruction de votre message sur le forum',
      formated: true,
      message: mess_destroy
    })
  end
end #/User

