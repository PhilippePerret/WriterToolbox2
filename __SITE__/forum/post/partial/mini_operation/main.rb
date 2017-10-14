# encoding: utf-8
class Forum
  class Post

    ERRORS = {
      bad_grade: 'Désolé, mais vous n’avez pas encore le droit de voter pour les messages.',
      has_already_downvoted: 'Vous avez déjà down-voté pour ce message, désolé.',
      has_already_upvoted:   'Vous avez déjà up-voté pour ce message, désolé.'
    }
    def upvote
      user.grade >= 2      || (return __error(ERRORS[:bad_grade]))
      has_upvoted?(user)   && (return __error(ERRORS[:has_already_upvoted]))
      if has_downvoted?(user)
        # => L'user avait downvoté pour ce message
        # <= Il faut retirer ce downvote et ajouter 1 au vote
        newdata = {downvotes: downvotes_sup(user)}
        req = "downvotes = downvotes - 1"
      else
        # => L'user n'avait pas downvoté pour ce message
        # <= Il faut l'ajouter dans les upvotes et ajouter 1 au vote
        newdata = {upvotes: upvotes_add(user)}
        req = "upvotes = upvotes + 1"
      end
      update_vote(newdata.merge(vote: data[:vote] + 1))
      # Modifier la donnée user
      request = "UPDATE users SET #{req} WHERE id = #{data[:user_id]};"
      site.db.use_database(:forum)
      site.db.execute(request)
    end

    # Down-voter pour un message
    def downvote
      user.grade >= 2      || (return __error(ERRORS[:bad_grade]))
      has_downvoted?(user) && (return __error(ERRORS[:has_already_downvoted]))
      if has_upvoted?(user)
        newdata = {upvotes: upvotes_sup(user)}
        req = "upvotes = upvotes - 1"
      else
        newdata = {downvotes: downvotes_add(user)}
        req = "downvotes = downvotes + 1"
      end
      update_vote(newdata.merge(vote: data[:vote] - 1))
      request = "UPDATE users SET #{req} WHERE id = #{data[:user_id]};"
      site.db.use_database(:forum)
      site.db.execute(request)
    end

    def update_vote new_data
      debug "New data pour Post ##{id} : #{new_data.inspect}"
      site.db.update(:forum,'posts_votes',new_data,{id:self.id})
      __notice("Votre vote a été enregistré. Merci à vous")
    end


    # Retourne true si le lecteur +lecteur+ a upvoté pour ce post
    def has_upvoted? lecteur
      " #{data[:upvotes]} ".match(/ #{lecteur.id} /)
    end
    # Retourne true si le lecteur +lecteur+ a downvoté pour ce post
    def has_downvoted? lecteur
      " #{data[:downvotes]} ".match(/ #{lecteur.id} /)
    end

    def upvotes_add   reader ; list_add(:upvotes, reader)   end
    def downvotes_add reader ; list_add(:downvotes, reader) end
    
    def upvotes_sup   reader ; list_sup(:upvotes, reader)   end
    def downvotes_sup reader ; list_sup(:downvotes, reader) end

    def list_add type, reader
      v = (data[type]||'').split(' ')
      v << reader.id.to_s
      return v.join(' ')
    end
    def list_sup type, reader
      v = (data[type]||'').split(' ')
      votes_init = v.count
      v.delete(reader.id.to_s)
      if v.count != votes_init - 1
        raise "Le nombre de votants devrait avoir été décrémenté…"
      end
      return v.join(' ').nil_if_empty
    end
  end #/Post
end #/Forum


