# encoding: utf-8
=begin

   Module pour la création d'un post

=end
class Forum
  class Post
    class << self

      # Créer le post
      #
      # @param {User} auteur
      #               L'auteur du message.
      # @param {Fixnum} sujet_id
      #                 ID du sujet auquel appartient le message
      # @param {Hash}   pdata
      #                 Les données à enregistrer, et principalement :content
      #                 le contenu textuel non traité du message.
      #
      # @return {Fixnum} ID du nouveau message
      #
      def create auteur, sujet_id, pdata
        data2save = {
          sujet_id:  sujet_id,
          user_id:   auteur.id,
          parent_id: pdata[:parent_id],
          options:   options_post(auteur)
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
      def options_post auteur
        o = String.new
        o << (auteur.grade < 4 ? '0' : '1')
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
  end #/Post
end #/Forum
