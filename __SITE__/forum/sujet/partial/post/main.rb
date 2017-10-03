# encoding: utf-8

class Forum
  class Sujet

    attr_reader :id

    def initialize sid
      @id = sid
    end

    # --------------------------------------------------------------------------------
    #
    #  Méthodes d'helper
    #
    # --------------------------------------------------------------------------------

    # Données du sujet (HTML)
    def encart_data
      <<-HTML
      <div id="entete_sujet-#{id}" class="entete_sujet">
        <span class="titre">#{data[:titre]}</span>
        <span class="libelle">Initié par</span><span class="sujet_creator">#{data[:creator_pseudo]}</span>
        <span class="libelle">le</span><span class="sujet_at">#{data[:created_at].as_human_date}</span>
        <div class="buttons">
          #{div_bouton_suscribe}
        </div>
        <div class="buttons">
          #{div_boutons_sujets}
        </div>
      </div>
      HTML
    end

    def div_bouton_suscribe
      user.identified? || (return '')
      is_following = user.follows_sujet?(id)
      op = (is_following ? 'un' : '') + 'suscribe'
      ti = (is_following ? 'ne plus ' : '') + 'suivre'
      simple_link("forum/sujet/#{id}?op=#{op}", ti)
    end

    def div_boutons_sujets
      bs = String.new
      bs << simple_link('forum/sujet/new', user.grade >= 5 ? 'Nouveau sujet' : 'Nouvelle question')      
      user.grade >= 7 && bs << simple_link("forum/sujet/#{id}?op=validate", 'Valider ce sujet')
      user.grade >= 7 && bs << simple_link("forum/sujet/#{id}?op=clore", 'Clore ce sujet')
      user.grade >= 8 && bs << simple_link("forum/sujet/#{id}?op=kill", 'Détruire ce sujet')
      return bs
    end

    # Retourne le code HTML de la liste des messages du sujet
    #
    # @param {Fixnum} from
    #                 Depuis cet index de message (1 start)
    #                 Peut être aussi égal à -1 pour indiquer qu'il faut prendre
    #                 le dernier
    # @param {Fixnum} nombre
    #                 Le nombre de messages à afficher.
    # @param {Hash}   options
    #                 Les options d'affichage :
    #                 :grade      Le grade des messages
    #
    def post_list from = 0, nombre = 20, options = nil
      from   = from.to_i
      nombre = nombre.to_i
      nombre > 0 || nombre = 20
      req = 'SELECT p.*, c.content, v.vote, v.upvotes, v.downvotes'+
            ', u.pseudo AS auteur_pseudo, u.id AS auteur_id' +
            ' FROM posts p'+
            ' INNER JOIN posts_content c ON p.id = c.id'+
            ' INNER JOIN posts_votes v   ON p.id = v.id'+
            ' INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id' +
            " WHERE sujet_id = #{id}" +
            ' AND SUBSTRING(p.options,1,1) = "1"'         # validés seulement
      if from < 0 
        real_from = - from - 1 # -1 = 0, -20 => 19
        req << " ORDER BY created_at DESC LIMIT #{real_from}, #{nombre}"
      else # from >= 0
        req << " ORDER BY created_at ASC LIMIT #{from}, #{nombre}"
      end

      c = String.new # pour mettre tout le code
      
      site.db.use_database(:forum)
      plist = site.db.execute(req)
      from < 0 && plist.reverse!
      plist.each do |hpost|
        c << Post.div_post(hpost)
      end

      return c
    end

    class Post
      class << self

        # Retourne le code HTML du div du message, dans un affichage de
        # listing de messages
        def div_post hpost
          <<-HTML
          <div class="post" id="post-#{hpost[:id]}">
            #{Forum::User.new(hpost[:user_id]).card}
            #{div_post_header(hpost)}
            <div class="content">#{hpost[:content]}</div>
            #{div_post_footer(hpost)}
          </div>
          HTML
        end

        # Code HTML pour l'entête des messages dans un listing de messages
        def div_post_header hpost
          auteur = simple_link("user/profil/#{hpost[:auteur_id]}", hpost[:auteur_pseudo])
          <<-HTML 
          <div class="post_header">
            #{bloc_votes(hpost)}
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
        def bloc_boutons_footer hpost
          user.identified? || (return '')
          user_is_auteur = user.id == hpost[:auteur_id]
          bs = String.new
          url = "forum/post/#{hpost[:id]}"
          user.grade > 2 && bs <<  simple_link("#{url}?op=n", 'Signaler')
          can_answer = !user_is_auteur && user.grade >= 3
          can_answer && bs <<  simple_link("#{url}?op=a", 'Répondre')
          user.grade > 6 && bs <<  simple_link("#{url}?op=u", '+1')
          user.grade > 6 && bs <<  simple_link("#{url}?op=d", '-1')
          user.grade >= 6 && bs <<  simple_link("#{url}?op=k", 'Supprimer')
          can_modify = user.grade >= 9 || user_is_auteur
          can_modify && bs << simple_link("#{url}?op=m", 'Modifier')
          can_validate = user.grade >= 6 && !user_is_auteur
          can_validate && bs << simple_link("#{url}?op=v", 'Valider')
          return "<div class=\"buttons\">#{bs}</div>"
        end

      end #/<< self Post
    end #/Post
  end #/Sujet
end #/Forum

class User

  # Retourne true si l'user suit le sujet d’identifiant sid
  def follows_sujet? sid
    site.db.count(:forum,'follows',{user_id: id, sujet_id: sid}) == 1
  end
end #/User

def sujet
  @sujet ||= Forum::Sujet.new(site.route.objet_id)
end
