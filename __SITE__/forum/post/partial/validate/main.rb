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
    #               :validateur     {User} qui valide le message, if any
    #               Mais noter qu'on passe par ici même lorsque le message
    #               se valide de lui-même (quand l'auteur n'a pas besoin 
    #               d'être modéré.)
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
      debug "data post ##{id} : #{data.inspect}"
      debug "data mini post ##{id} : #{data_mini.inspect}"

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

      # On ajoute le message à l'auteur
      Forum::Post.add_post_to_user(self.auteur, self.id)

      # On redirige l'user vers la liste du sujet
      redirect_to(self.route_in_sujet)
    end
    #/validate
    
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
      subject: "Réponse à votre message",
      formated: true,
      message: <<-HTML
      <p>Bonjour #{pseudo},</p>
      <p>Je vous annonce qu’un de vos messages sur le forum a reçu une réponse de #{post.auteur.pseudo}.</p>
      <p>Vous pouvez lire cette <a href="#{url_reponse}">réponse en cliquant ce lien</a>.</p>
      HTML
    })
  end
end #/User
    
