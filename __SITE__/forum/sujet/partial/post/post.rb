# encoding: utf-8
class Forum
  class Post
    class << self


      # Retourne le code HTML du div du message, dans un affichage de
      # listing de messages
      #
      # Pour le faire, on crée une instance Forum::Post qui permettra
      # de simplifier le code.
      #
      def div_post hpost
        ipost = new(hpost[:id])
        ipost.data = hpost
        return ipost.as_div_for(user)
      end

    end #/<< self



    # -----------------------------------------------------------------------------
    # 
    #  INSTANCE
    # 
    # -----------------------------------------------------------------------------
    
    attr_accessor :data
    attr_accessor :reader # l'user courant, en fait
    
    def id ; @id ||= data[:id] end

    # Retourne le code HTML du post pour un div (affichage de listing)
    # pour l'user +reader+ ({User})
    def as_div_for reader
      self.reader = reader
      <<-HTML
      <div class="post" id="post-#{id}">
        #{div_post_header}
        #{Forum::User.new(data[:user_id]).card}
        <div class="content">#{mise_en_forme_post_content}</div>
        #{div_post_footer}
      </div>
      HTML
    end

    def div_post_header
      <<-HTML
      <div class="post_header">
        #{bloc_specs_post}
        #{bloc_votes}
      </div>
      HTML
    end
    def bloc_specs_post
      <<-HTML
      <div class="post_specs">
        <span class="post_id">Message ##{id}</span>
      </div>
      HTML
    end


    # Code HTML pour les votes du message
    # Suivant le niveau du visiteur, il peut ou non voter par le message
    #
    # Noter qu'on ne retourne rien s'il n'y a ni upvote ni downvote
    #
    def bloc_votes
      upvotes   = (data[:upvotes]||'').as_id_list.count
      downvotes = (data[:downvotes]||'').as_id_list.count
      upvotes > 0 || downvotes > 0 || (return '')
      total = upvotes - downvotes
      classe = total > 0 ? 'green' : 'red'
      <<-HTML
        <span class='post_votes_up'>
          <span class="post_upvotes">#{upvotes}</span>&nbsp;#{hand_up_vote}
        </span>
        <span class='post_votes_down'>
          <span class="post_downvotes">#{downvotes}</span>&nbsp;#{hand_down_vote}
        </span>
        <span class="post_cote #{classe}">total&nbsp;: #{total}</span>
      HTML
    end

    # Retourne la main pour up-voter pour le message.
    # En fonction des votes du reader courant, on met un lien pour qu'il
    # puisse up-voter ou non.
    def hand_up_vote
      hand = "👍" 
      reader_has_voted? || hand = simple_link("forum/post/#{id}?op=u", hand)
      return hand
    end
    def hand_down_vote
      hand = "👎"
      reader_has_voted? || hand = simple_link("forum/post/#{id}?op=d", hand)
      return hand
    end

    # Met en forme le :content du message +hpost+ et le retourne
    # @param {Hash} hpost
    #               Doit contenir :
    #                 :content      Le contenu du message
    #                 :id           l'identifiant du message
    #
    # Note : quand updated_at diffère de created_at, on indique la date
    # de dernière modification et qui l'a opérée.
    def mise_en_forme_post_content
      c = data[:content]
      if c.match(/\[USER#/)
        # <= Il y a des citations dans le message, on les met en forme
        # => On doit les mettre en forme
        c.gsub!(/\[USER#(.*?)\](.*?)\[\/USER#\1\]/m){
          <<-HTML
              <div class="post_citation">
                <div class="auteur-citation">#{$1} a dit :</div>
                <p>#{$2}</p>
              </div>
          HTML
        }
      end
      # Pour les styles de base
      c.gsub!(/\[(i|b|u|del|ins|center|strong)\](.*?)\[\/\1\]/, '<\1>\2</\1>')
      # Pour les liens
      # Les liens vers les pages du site lui-même, de la forme :
      # [BOA=route/to/page]titre du lien[/BOA]
      c.gsub!(/\[BOA=(.*?)\](.*?)\[\/BOA\]/,'<a href="\1">\2</a>')

      # Si le contenu a été modifié, on indique quand et par qui
      c << mark_content_modified

      return c
    end

    # Marque de contenu modifié, s'il a été modifié
    # (les informations utiles se trouvent dans les données complètes)
    def mark_content_modified
     data[:content_created_at] != data[:content_updated_at] || (return '') 
     modificator = ::User.get(data[:content_modified_by] || data[:user_id]) || self.auteur
     "<div class=\"date_last_update\">Dernière modification : #{data[:updated_at].as_human_date} par #{modificator.pseudo}</div>"
    end


    # Code HTML pour le pied de page des messages dans un listing de
    # messages.
    # On met notamment les votes et les boutons pour voter, si le lecteur
    # peut voter.
    def div_post_footer
      <<-HTML
      <div class="post_footer">
        <span class='post_date'>
          <span class="libelle">Message du</span>
          #{post_human_date} 
        </span>
        #{bloc_votes}
        #{bloc_boutons_footer}
      </div>
      HTML
    end

    def post_human_date
      "#{data[:created_at].as_human_date} <span class='small'>(#{data[:created_at].ago})</span>" 
    end

    # Code HTML du bloc qui contient tous les boutons pour répondre, supprimer,
    # signaler le message (en fonction du grade de l'user)
    #
    # Les opérations (op) définis pour les boutons sur les posts sont
    # les suivantes :
    #     op=n           Signaler un message aux modérateurs
    #     op=a           Répondre à un message
    #     op=u           Upvoter pour un message
    #     op=d           Downvoter pour un message
    #     op=k           Supprimer un message
    #     op=m           Modifier un message
    #     op=v           Valider un message
    #
    # Bien entendu, chaque opération dépend du grade de l'auteur.
    # 
    def bloc_boutons_footer
      reader.identified? || (return '')
      bs = String.new
      url = "forum/post/#{id}"
      reader.grade > 2 && bs <<  simple_link("#{url}?op=n", 'Signaler')
      if reader.grade >= 2
        case
        when !reader_has_voted?
          bs << simple_link("#{url}?op=d", '-1')
          bs << simple_link("#{url}?op=u", '+1')
        when reader_has_upvoted?
          bs << "<a href=\"#{url}?op=d\" title=\"Retirer votre up-vote\">- up</a>"
        when reader_has_downvoted?
          bs << "<a href=\"#{url}?op=u\" title=\"Retirer votre down-vote\">- down</a>"
        end
      end
      reader.grade >= 6 && bs <<  simple_link("#{url}?op=k", 'Supprimer')
      reader_can_modify? && bs << simple_link("#{url}?op=m", 'Modifier')
      reader_can_validate? && bs << simple_link("#{url}?op=v", 'Valider')
      reader_can_answer? && bs <<  simple_link("#{url}?op=a", 'Répondre', 'exergue')

      return "<div class=\"buttons\">#{bs}</div>"
    end

    # Retourne true si l'user courant peut répondre au message
    def reader_can_answer?
      !reader_is_auteur? && reader.grade >= 3
    end
    def reader_can_modify?
      reader_is_auteur? || reader.grade >= 9
    end

    # Retourne true si le reader courant peut valider le message
    # Bien sûr, pour pouvoir valider le message, il ne faut pas que
    # le message soit déjà validé.
    def reader_can_validate?
      data[:options][0] == '0' && !reader_is_auteur? && reader.grade >= 6
    end

    # Retourne true si l'user (reader) a voté pour ce message, en up ou 
    # en down
    def reader_has_voted?
      if @curHasVoted === nil
        @curHasVoted = reader_has_upvoted? || reader_has_downvoted?
      end
      @curHasVoted
    end
    # Retourne true si l'user (reader) a up-voter pour ce message
    def reader_has_upvoted?
      if @curHasUpvoted === nil
        @curHasUpvoted = upvotes_as_list.include?(reader.id) 
      end
      @curHasUpvoted
    end
    def reader_has_downvoted?
      if @curHasDownvoted === nil
        @curHasDownvoted = downvotes_as_list.include?(reader.id) 
      end
      @curHasDownvoted
    end
    # Retourne true si l'auteur courant est l'auteur du message
    def reader_is_auteur?
      @is_user_auteur === nil && @is_user_auteur = data[:auteur_id] == reader.id
      @is_user_auteur
    end

    def upvotes_as_list
      @upvotes_as_list ||= data[:upvotes].as_id_list
    end
    def downvotes_as_list
      @downvotes_as_list ||= data[:downvotes].as_id_list
    end
  end #/Post

end #/Forum
