# encoding: utf-8
debug "-> #{__FILE__}"
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
      # Si c'est une réponse (parent_id défini), on avertit l'auteur du
      # message parent qu'il y a une réponse
      data[:parent_id] && Forum::Post.get(data[:parent_id]).auteur.annonce_new_reponse(self)
      end
      # Annonce en page d'accueil
      require './lib/utils/updates'
      Updates.add({
        message: "Message forum de <strong>#{self.auteur_pseudo}</strong>.",
        route:   self.route,
        type:    'forum', 
        options: '10000000' # annonce aux inscrits (qui le souhaient)

      })

      # On ajoute le message à l'auteur
      Forum::Post.add_post_to_user(self.auteur, self.id)

      # On redirige l'user vers la liste du sujet
      redirect_to(self.route)
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
    raise "Il faut implémenter l'avertissement à l'auteur du message original."
  end
end #/User
    
  end
