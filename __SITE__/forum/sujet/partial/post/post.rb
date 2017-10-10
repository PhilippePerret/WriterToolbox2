# encoding: utf-8
class Forum
  class Post
    class << self


      # Retourne le code HTML du div du message, dans un affichage de
      # listing de messages
      def div_post hpost
        <<-HTML
          <div class="post" id="post-#{hpost[:id]}">
            #{div_post_header(hpost)}
            #{Forum::User.new(hpost[:user_id]).card}
            <div class="content">#{mise_en_forme_post_content hpost}</div>
            #{div_post_footer(hpost)}
          </div>
        HTML
      end

      # Code HTML pour l'entête des messages dans un listing de messages
      def div_post_header hpost
        auteur = simple_link("user/profil/#{hpost[:auteur_id]}", hpost[:auteur_pseudo])
        <<-HTML
        <div class="post_header">
        #{bloc_specs_post(hpost)}
        #{bloc_votes(hpost)}
        </div>
        HTML
      end

      # Code HTML pour les infos sur le message
      # Pour le moment, elles sont visibles pour tout le monde mais plus
      # tard seuls les administrateurs pourront les voir
      def bloc_specs_post hpost
        <<-HTML
        <div class="post_specs">
        <span class="post_id">Message ##{hpost[:id]}</span>
        </div>
        HTML
      end

      # Code HTML pour les votes du message
      # Suivant le niveau du visiteur, il peut ou non voter par le message
      def bloc_votes hpost
        upvotes   = (hpost[:upvotes]||'').as_id_list.count
        downvotes = (hpost[:downvotes]||'').as_id_list.count
        <<-HTML
        <span class='post_votes_up'>
        <span class="post_upvotes">#{upvotes}</span>&nbsp;👍
        </span>
        <span class='post_votes_down'>
        <span class="post_downvotes">#{downvotes}</span>&nbsp;👎
            </span>
        HTML
      end


      # Code HTML pour le pied de page des messages dans un listing de
      # messages.
      # On met notamment les votes et les boutons pour voter, si le lecteur
      # peut voter.
      def div_post_footer hpost
        <<-HTML
          <div class="post_footer">
            <span class='post_date'>
              <span class="libelle">Message du</span>
              #{hpost[:created_at].as_human_date} <span class='small'>(#{hpost[:created_at].ago})</span>
            </span>
            #{bloc_votes(hpost)}
            #{bloc_boutons_footer(hpost)}
          </div>
        HTML
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
      def bloc_boutons_footer hpost
        user.identified? || (return '')
        user_is_auteur = user.id == hpost[:auteur_id]
        bs = String.new
        url = "forum/post/#{hpost[:id]}"
        user.grade > 2 && bs <<  simple_link("#{url}?op=n", 'Signaler')
        can_answer = !user_is_auteur && user.grade >= 3
        can_answer && bs <<  simple_link("#{url}?op=a", 'Répondre')
        if user.grade >= 2
          has_upvoted   = " #{hpost[:upvotes]} ".match(/ #{user.id.to_s} /)
          has_downvoted = " #{hpost[:downvotes]} ".match(/ #{user.id.to_s} /) 
          no_vote = !has_upvoted && !has_downvoted
          (has_upvoted   || no_vote) && bs << simple_link("#{url}?op=d", '-1')
          (has_downvoted || no_vote) && bs << simple_link("#{url}?op=u", '+1')
        end
        user.grade >= 6 && bs <<  simple_link("#{url}?op=k", 'Supprimer')
        can_modify = user.grade >= 9 || user_is_auteur
        can_modify && bs << simple_link("#{url}?op=m", 'Modifier')
        can_validate = user.grade >= 6 && !user_is_auteur
        can_validate && bs << simple_link("#{url}?op=v", 'Valider')
        return "<div class=\"buttons\">#{bs}</div>"
      end

      # Met en forme le :content du message +hpost+ et le retourne
      # @param {Hash} hpost
      #               Doit contenir :
      #                 :content      Le contenu du message
      #                 :id           l'identifiant du message
      def mise_en_forme_post_content hpost
        c = hpost[:content]
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
        return c
      end
    end #/<< self
  end #/Post
end #/Forum
