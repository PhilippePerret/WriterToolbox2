# encoding: utf-8
class Forum
  class Sujet
    class << self

      # Retourne le code HTML pour l'affichage d'un sujet de données +hsujet+
      # sur la page d'accueil
      #
      # Noter que +hsujet+ n'est pas du tout le Hash des données récupérées dans
      # la base de données, mais une table beaucoup plus complète avec les pseudos
      # des créateurs du sujet et de l'auteur du dernier message, etc. telles que
      # retournées par x_derniers_sujets ci-dessous
      def div_sujet hsujet
        sid = "sujet-#{hsujet[:id]}"
        type_s = hsujet[:specs][1].to_i
        <<-HTML
        <div id="#{sid}" class="sujet">
          <div>
            <span class="titre" id="#{sid}-titre">#{titre_sujet_linked(hsujet)}</span>
            <span class="libelle">créé par</span>
            #{span_creator_sujet(hsujet)}
            <span class="libelle">le</span>
            <span class="sujet_date">#{(hsujet[:sujet_date]||Time.now.to_i).as_human_date}</span>
            <span class="libelle">Messages</span>
            <span class="posts_count">#{hsujet[:count]}</span>
            <span class="libelle">Type</span>
            <span class="type_s">#{type_s}</span>
          </div>
          <div class="last_post">
            #{last_post_link(hsujet)}
            <span> par </span>
            #{span_auteur_last_post(hsujet)}
            <span class="libelle">datant du</span>
            <span class="post_date">#{last_post_date(hsujet)}</span>
          </div>
        </div>
        HTML
      end
      # Date formatée du dernier message, ou '---'
      def last_post_date hsujet
        hsujet[:last_post_id] || (return '---')
        "#{hsujet[:updated_at].as_human_date} <span class='small'>(#{hsujet[:updated_at].ago})</span>"
      end

      # Lien vers le dernier message, s'il existe
      def last_post_link hsujet
        hsujet[:last_post_id] || (return '')
        simple_link(
          "forum/sujet/#{hsujet[:id]}?from=-1#post-#{hsujet[:last_post_id]}", 
          'Dernier message', 
          'exergue'
        )
      end

      def titre_sujet_linked hsujet
        simple_link("forum/sujet/#{hsujet[:id]}?from=-1", hsujet[:titre])
      end
      def span_creator_sujet hsujet
        <<-HTML
        <span class="sujet_creator" id="sujet-#{hsujet[:id]}-creator" data-id="#{hsujet[:creator_id]}">
          #{creator_sujet_linked(hsujet)}
        </span>
        HTML
      end
      def creator_sujet_linked hsujet
        simple_link("user/profil/#{hsujet[:creator_id]}", hsujet[:creator_pseudo])
      end
      def span_auteur_last_post hsujet
        <<-HTML
          <span class="post_auteur" data-id="#{hsujet[:auteur_id]}">
            #{auteur_last_post_link(hsujet)}
          </span>
        HTML
      end
      def auteur_last_post_link hsujet
        simple_link("user/profil/#{hsujet[:auteur_id]}", hsujet[:auteur_pseudo])
      end

    end #/<< self
  end #/Sujet
end #/Forum
