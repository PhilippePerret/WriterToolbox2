# encoding: utf-8
class Forum
  class User

    attr_reader :id
    def initialize uid
      @id = uid
    end

    # Carte d'identité de l'auteur du message ajoutée en regard du message 
    def card
      fame = data[:upvotes] - data[:downvotes]
      <<-HTML
      <div class="user_card">
        <span class="pseudo">#{data[:pseudo]}</span>
        <div><span class="libelle">Depuis le </span><span class="created_at">#{data[:created_at].as_human_date}</span></div>
        <div>
          <span class="libelle noblock">Cote </span><span class="fame #{fame > 0 ? 'bon' : 'bad'}">#{fame}</span>
          <span>&nbsp;&nbsp;</span>
          <span class="ups">#{data[:upvotes]}</span><span> 👍</span>
          <span>&nbsp;&nbsp;</span>
          <span class="downs">#{data[:downvotes]}</span><span> 👎</span>
        </div>
        <div><span class="libelle">Messages </span><span class="post_count">#{data[:count]}</span></div>
        <div><span class="libelle">Dernier </span><span class="last_post">#{lien_last_post}</span></div>
      </div>
      HTML
    end


    def lien_last_post
      data[:last_post_id] || (return 'aucun')
      simple_link("forum/sujet/#{data[:last_post_sujet_id]}?pid=#{data[:last_post_id]}", data[:last_post_at].as_human_date)
    end

    # Retourne les données forum de l'user
    # Si l'user n'a pas encore de données (pas de table), on lui en fabrique une
    def data
      @data ||= 
        begin
          request = <<-SQL
          SELECT uf.*, u.pseudo, u.created_at,
             p.created_at AS last_post_at, p.sujet_id AS last_post_sujet_id
             FROM `boite-a-outils_forum`.users uf
             INNER JOIN `boite-a-outils_hot`.users u ON uf.id = u.id
             INNER JOIN posts p ON uf.last_post_id = p.id
             WHERE uf.id = #{id}
             LIMIT 1
          SQL
          site.db.use_database(:forum)
          site.db.execute(request).first || default_user_data
        end
    end
    # Données par défaut lorsque l'user n'a encore aucune
    # donnée forum, c'est-à-dire qu'il n'a encore déposé aucun
    # message.
    def default_user_data
      huser = site.db.select(:hot,'users',{id: self.id}).first
      huser.merge!(
        count: 0, 
        last_post_at: nil, last_post_sujet_id: nil, last_post_id: nil,
        upvotes: 0, downvotes: 0
      )
    end
  end#/User
end#/Forum
