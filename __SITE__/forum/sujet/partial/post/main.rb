# encoding: utf-8

class Forum
  class Sujet

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

    # Retourne le code HTML pour les boutons des autres messages.
    # Noter que cette méthode est appelée après que la liste a été définie, on 
    # connait donc, pour ce sujet, l'identifiant du premier message affiché
    # qui permettra de définir les liens pour les messages avant/après
    def boutons_autres_messages where = :bottom
      @btns_other_posts ||= 
        begin
          pref_qs = "nombre=#{@current_post[:nombre]}&pid=#{@current_post[:pid]}&dir="
          qs_prev_btn = "#{pref_qs}prev"
          qs_next_btn = "#{pref_qs}next"
          url = "forum/sujet/#{self.id}"
          btn_prev = simple_link("#{url}?#{qs_prev_btn}", 'Messages précédents')
          btn_next = simple_link("#{url}?#{qs_next_btn}", 'Messages suivants')
          btn_last = simple_link("#{url}?from=-1", 'Derniers messages')
          <<-HTML
          <span class="btn_first">
            <a href="#{url}?from=1">⇤ premiers messages</a>
          </span>
          <span class="btn_prev">
            <a href="#{url}?#{qs_prev_btn}">← messages précédents</a></span>
          </span>
          <span class="btn_next">
            <a href="#{url}?#{qs_next_btn}">messages suivants →</a></span>
          </span>
          <span class="btn_last">
            <a href="#{url}?from=-1">derniers messages ⇥</a></span>
          </span>
          HTML
        end
      "<div class='btns_other_posts #{where}'>#{@btns_other_posts}</div>"
    end

    # Retourne le code HTML pour souscrire au sujet courant
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
    # TIP
    #   Si une liste est vide, on rappelle la méthode avec des données qui permettent
    #   de trouver les messages.
    #
    # @param {Hash} params
    #                 :from     Si spécifié, c'est l'offset à partir duquel il
    #                           faut prendre les messages. -1 pour le dernier.
    #                           Noter qu'en SQL l'index est 0-start.
    #                 :pid      L'ID du message à afficher (en haut)
    #                           OU le message de référence si :dir est défini.
    #                 :dir      Si 'next', il faut prendre le tableau qui suit le
    #                           tableau contenant :pid (lire bien cette phrase)
    #                           Si 'prev', il faut prendre les messages précédent
    #                           :pid, sans le message :pid.
    #                 :nombre   Nombre de messages à prendre, 20 par défaut
    #                 :grade    Le privilège maximum des messages à afficher. Si
    #                           grade = 2, par exemple, il ne faut prendre que les
    #                           messages dont le bit de grade est inférieur ou égal
    #                           à 2.
    #                           OBSOLETE: Un message n'a pas de grade, c'est le
    #                           sujet qui en a un.
    #
    def post_list params = nil
      params ||= Hash.new
      params[:nombre] ||= 20
      params[:nombre] = params[:nombre].to_i

      #debug "params : #{params.inspect}"

      # Début de la requête
      req = <<-SQL
      SELECT p.*, c.content, v.vote, v.upvotes, v.downvotes
      , u.pseudo AS auteur_pseudo, u.id AS auteur_id
      FROM posts p
      INNER JOIN posts_content c ON p.id = c.id
      INNER JOIN posts_votes v ON p.id = v.id
      INNER JOIN `boite-a-outils_hot`.users u ON p.user_id = u.id
      WHERE sujet_id = #{self.id} AND SUBSTRING(p.options,1,1) = "1"
      SQL

      # Si params[:pid] est défini, on met la requête de récupération
      # de son created_at en mémoire car il servira pour plusieurs
      # situations.
      if params[:pid]
        pid_created_at = "(SELECT created_at FROM posts WHERE id = #{params[:pid]})"
      end


      offset = nil
      order  = 'DESC'
      nombre_releve = params[:nombre]
      if params[:from]
        offset = params[:from].to_i
        if offset > 0
          order = 'ASC'
        else
          offset = - offset # -1 sera retiré plus tard
        end
      elsif params[:dir] == 'prev'
        # On doit charger les <nombre> message strictement avant le message :pid
        req << "AND p.created_at < #{pid_created_at}"
      elsif params[:dir] == 'next'
        # On doit charger les 2 x <nombre> messages strictement après le message
        # :pid (pour en garder seuleement <nombre> qui n'appartiennent pas au panneau
        # du message :pid — qui est toujours en haut du panneau)
        nombre_releve *= 2
        req << "AND p.created_at >= #{pid_created_at}"
        order = 'ASC'
      elsif params[:pid]
        # On doit charger les messages à partir de celui-ci
        req << "AND p.created_at >= #{pid_created_at}"
        order = 'ASC'
      else
        # Ne devrait arriver que lorsqu'on appelle l'URL simple.
        # On charge à partir du premier message
        offset = 1
      end

      req += <<-SQL
      ORDER BY p.created_at #{order}
      LIMIT #{nombre_releve}
      SQL

      offset && req << " OFFSET #{offset - 1}"

       debug "REQUEST : #{req}"
      site.db.use_database(:forum)
      plist = site.db.execute(req)

      # Si c'est une demande des messages suivants (dir: :next) alors il
      # ne faut prendre que les <nombre> derniers messages relevés.
      # Note : il faut faire ce test ici pour pouvoir traiter le cas d'une
      # liste vide, comme ça peut arriver avec les derniers messages.
      if params[:dir] == 'next'
        first = params[:nombre]
        plist = plist[first..-1]
      end

      # Si la liste est vide, il faut rappeler la méthode
      # avec de nouvelles données.
      # Pour le moment, on renvoie toujours le tout dernier tableau.
      if plist.empty?
        case params[:dir]
        when 'next' then return post_list({from: -1, nombre: params[:nombre]})
        when 'prev', nil then return post_list({from: 1, nombre: params[:nombre]})
        end
      end

      # Si l'ordre est descendant, il faut inverser la liste pour
      # avoir les messages dans le bon ordre.
      order == 'ASC' || plist.reverse!

      # Débugt la liste finale
      debug "LISTE FINALE:"
      plist.each{|h| debug "#{h[:id]} : #{h[:created_at].as_human_date} #{h[:created_at]}"}


      c = String.new # pour mettre tout le code
      plist.each do |hpost|
        c << Forum::Post.div_post(hpost)
      end
      
      # On met en @current_post les données que l'on possède sur
      # ce message pour pouvoir notamment faire les boutons qui
      # permettent de voir les messages avant et après
      created_ats = [plist.first[:created_at], plist.last[:created_at]]
      @current_post = {
        sujet_id: self.id,
        pid:      plist.first[:id],
        nombre:   params[:nombre]
      }
      # debug "@curent_post du sujet #{self.id} : #{@current_post.inspect}"
      return c
    end
  end #/Sujet


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
