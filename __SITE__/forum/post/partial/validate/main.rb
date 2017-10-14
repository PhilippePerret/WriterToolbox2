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
      
      # On indique que c'est le tout dernier message du sujet
      # Si le sujet n'était pas encore validé, la validation
      # de ce premier message validera automatiquement le sujet.
      # On marque aussi le bit d'annonce (5e) qui sera mis à 0 lorsque
      # le sujet aura été annoncé par le cronjob.
      # On met le résultat dans @validation_sujet car ce sont les
      # autres méthodes qui auront besoin de cette valeur, et notamment
      # la validation par l'administrateur.
      hsujet = site.db.select(:forum,'sujets',{id:sujet_id}).first
      new_data_sujet = {last_post_id: self.id, count: hsujet[:count] + 1}
      @validation_sujet = hsujet[:specs][0] == '0'
      if @validation_sujet
        require_lib('forum:validate_sujet')
        new_data_sujet.merge!(Forum::Sujet.data_validation(hsujet))
      end
      site.db.update(:forum,'sujets',new_data_sujet,{id:sujet_id})

      # Pour rafraichir les données
      @data = @data_mini = nil

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
      opts[0..3] = '1000'
      new_data = {options: opts, valided_by: admin.id}
      site.db.update(:forum,'posts',new_data,{id: self.id})

      # Opérations normales de validation, comme le réglage du dernier
      # post du sujet, du dernier post de l'user, du mail envoyé au l'auteur
      # original du message, etc.
      # La méthode va également s'occuper de valider le sujet, si c'est le
      # premier message.

      self.validate(redirection: false)

      # Envoi du mail pour avertir l'auteur du post que son post ou son sujet a
      # été validé.
      # Note : on sait que c'est un sujet validé (par son post) lorsque l'on
      # passe par la méthode `validate`. Elle met la propriété @validation_sujet
      # à true
      ajout_validation = 
        if @validation_sujet
          "<p>Ce premier message validé valide du même coup votre sujet.</p>"
        else '' end
      self.auteur.send_mail({
        subject: "Validation de votre #{@validation_sujet ? "sujet" : "message"}sur le forum",
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
    #
    # En fait, ce refus consiste surtout à demander à l'auteur du 
    # message de le corriger pour qu'il puisse être validé.
    # 
    # Mais aussi : le 3e bit des options est mis à 1. Il sera remis à 0 si
    # le message est validé.
    #
    def refus_par_admin admin
      admin.admin? || raise('Vous n’êtes pas autorisé à exécuter cette action.')
      opts = data[:options]
      opts[2] = '1'
      site.db.update(:forum,'posts',{options: opts},{id: self.id})
      auteur.annonce_refus_message(self, motif_formated)
      __notice("Le message est refusé. L'auteur a été prévenu.")
    end


    # Méthode qui retourne le motif formaté
    #
    # Note : TODO On pourrait aussi l'écrire en markdown… et donc utiliser
    # la librairie propre pour le transformer. On verra à l'usage, s'il faut
    # vraiment avoir des messages compliqués.
    def motif_formated
      m = param(:post)[:motif].nil_if_empty
      m != nil || (return nil)
      m.gsub!(/\r/,'')
      m.gsub!(/\n[  \t]+/,'')
      m.gsub!(/\n\n\n+/,"\n\n")
      m = m.split("\n\n").collect{|p|"<p>#{p}</p>"}.join('')
      m.gsub(/\n/,'<br>')
      return m
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
      
      # Si le post était déjà validé, il y a encore du travail, comme par
      # exemple décrémenter le nombre de message de l'auteur ou le retirer
      # des propriétés last_post_id du sujet ou de l'auteur.
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
      auteur.annonce_destroy_message(self, motif_formated)
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

  # Message envoyé à l'user lorsque son message est refusé
  #
  def annonce_refus_message post, raison
    message = <<-HTML
    <p>Votre message du #{post.data[:created_at].as_human_date} sur le forum de #{site.configuration.name} a malheureusement été refusé pour le motif suivant :</p>
    #{raison}
    <p>Vous avez la possibilité de le modifier en rejoignant l'adresse suivante :</p>
    <p class="center">#{simple_link(post.route(:full) + '?op=m', "Modifier le message")}</p>
    <p>Merci de votre compréhension,</p>
    HTML
    send_mail({
      subject: "Votre message sur le forum a été refusé",
      formated: true,
      message:  message
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

