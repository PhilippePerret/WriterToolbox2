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
      <div id="entete_sujet">
        <span class="titre">#{data[:titre]}</span>
      </div>
      HTML
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

      debug "Requête : #{req}"
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
          dp = String.new
          dp << div_post_header(hpost)
          dp << "<div class='content'>#{hpost[:content]}</div>"
          dp << div_post_footer(hpost)
          return "<div class=\"post\" id=\"post-#{hpost[:id]}\">#{dp}</div>"
        end

        # Code HTML pour l'entête des messages dans un listing de messages
        def div_post_header hpost
          auteur = simple_link("user/profil/#{hpost[:auteur_id]}", hpost[:auteur_pseudo])
          <<-HTML 
            <span class="libelle">Message de</span>         
            <span class='post_auteur' data-id='#{hpost[:user_id]}'>#{auteur}</span>
            <span class="libelle">du</span>
            <span class='post_date'>#{hpost[:created_at].as_human_date} <span class='small'>(#{hpost[:created_at].ago})</span></span>
          HTML
        end


        # Code HTML pour le pied de page des messages dans un listing de
        # messages.
        # On met notamment les votes et les boutons pour voter, si le lecteur
        # peut voter.
        def div_post_footer hpost
          upvotes   = (hpost[:upvotes]||'').as_id_list.count
          downvotes = (hpost[:downvotes]||'').as_id_list.count
          nombre_votes = upvotes + downvotes
          <<-HTML
            <span class="libelle">Nombre de votes</span>
            <span class='post_vote_count'>#{nombre_votes}</span>
            <span class="libelle">Pour</span>
            <span class='post_votes_up'>#{upvotes}</span>
            <span class="libelle">Contre</span>
            <span class='post_votes_down'>#{downvotes}</span>
          HTML
        end
      end #/<< self Post
    end #/Post
  end #/Sujet
end #/Forum



def sujet
  @sujet ||= Forum::Sujet.new(site.route.objet_id)
end
