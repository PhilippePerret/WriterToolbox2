# encoding: utf-8
class Forum
  class << self

    # Le message d'accueil pour l'user visitant la page
    # Note : utile seulement sur la page d'accueil du forum
    def invite_pour_user reader
      defined?(User::GRADES) || require_lib('user:constants')
      hgrade = ERB.new(User::GRADES[reader.grade][:hname]).result(reader.bind)
      lien_profil = simple_link("user/profil/#{reader.id}", 'la page de votre profil', 'exergue')
      <<-HTML
      <div class="small cadre">
      <div>Bienvenue sur le forum d’écriture du site.</div>
      <div>Votre grade est « #{hgrade} », vos privilèges sont détaillés sur #{lien_profil}.</div>
      </div>
      HTML
    end


    # Ajoute les boutons pour voir les sujets précédents et
    # suivants
    def define_boutons_sujets_next_previous from, nombre
      from = from.to_i
      nombre = nombre.to_i
      bs = String.new
      if from > 0
        prev = from - nombre
        prev >= 0 || prev = 0
        bs << simple_link("forum/home?from=#{prev}&nombre=#{nombre}", 'Précédents')
      end
      bs << simple_link("forum/home?from=#{from+nombre}&nombre=#{nombre}", 'Suivants')
      # On les ajoute
      add_boutons_forum bs
    end

    # Retourne le code HTML de la liste des derniers messages,
    # à placer dans le fieldset.
    #
    # Noter que pour un user de grade 0, seuls les messages publics
    # sont affichés.
    #
    def last_messages from = 0, nombre = 20, options = nil
      from = from.to_i
      nombre = nombre.to_i
      lm = String.new
      Sujet.x_derniers_sujets(from, nombre, options).each do |hsujet|
        lm << Sujet.div_sujet(hsujet)
      end
      return lm
    end


  end #/<< self Forum

  class Sujet
    class << self

      # On a besoin du module pour construire le sujet
      # Définit notamment 'div_sujet'
      require './__SITE__/forum/_lib/_not_required/module/sujet_build'


      # Retourne les tables de données des +nombre+ derniers sujets
      # répondus en respectant les +options+
      # Détail : c'est donc un Array de Hash où chaque Hash contient :
      #
      #   :titre            Titre String du sujet
      #   :id               ID du sujet
      #   :sujet_date       Time de la création du sujet
      #   :updated_at       Time d'actualisation du sujet
      #   :creator_id       ID du créateur du sujet
      #   :creator_pseudo   Pseudo du créateur du sujet
      #   :count            Nombre de messages
      #   :specs            Les spécifications du sujet
      #   :last_post_id     ID du dernier mes
      #   :post_date        Time de la création du message
      #   :auteur_id        ID de l'auteur du message
      #   :auteur_pseudo    Pseudo de l'auteur du message
      #
      # @param {Hash} options
      #               :grade      Grade minimum. Si 4 par exemple, on ne
      #                           prend que les sujets avec un grade minimum
      #                           de 4.
      def x_derniers_sujets from = 0, nombre = 20, options = nil
        request = <<-SQL
SELECT s.titre, s.id, s.last_post_id, s.creator_id, s.created_at AS sujet_date
  , s.count, s.specs, s.updated_at
  , us.pseudo AS creator_pseudo
  , p.created_at AS post_date, p.user_id AS auteur_id
  , up.pseudo AS auteur_pseudo
 FROM sujets s
 INNER JOIN posts p ON s.last_post_id = p.id
 INNER JOIN `boite-a-outils_hot`.users us ON s.creator_id = us.id
 INNER JOIN `boite-a-outils_hot`.users up ON p.user_id = up.id
 WHERE SUBSTRING(s.specs,1,1) = '1'
        SQL
        if options && options[:grade]
          request << " AND CAST(SUBSTRING(s.specs,6,1) AS UNSIGNED) <= #{options[:grade]}"
        end
        request += <<-SQL
 ORDER BY s.updated_at DESC
 LIMIT #{from}, #{nombre};
        SQL

        site.db.use_database(:forum)
        site.db.execute(request)
      end
    end #/self Sujet
  end #/Sujet
end #/Forum
