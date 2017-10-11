# encoding: utf-8
class Forum
  class << self

    # Ajoute les boutons pour voir les sujets précédents et
    # suivants
    def add_boutons_sujets_next_previous from, nombre
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
        req  = 'SELECT s.titre, s.id, s.last_post_id, s.creator_id, s.created_at AS sujet_date'
        req << ', s.count, s.specs, s.updated_at'
        req << ', us.pseudo AS creator_pseudo'
        req << ', p.created_at AS post_date, p.user_id AS auteur_id'
        req << ', up.pseudo AS auteur_pseudo'
        req << ' FROM sujets s'
        req << ' INNER JOIN posts p'
        req << '   ON s.last_post_id = p.id'
        req << ' INNER JOIN `boite-a-outils_hot`.users us'
        req << '   ON s.creator_id = us.id'
        req << ' INNER JOIN `boite-a-outils_hot`.users up'
        req << '   ON p.user_id = up.id'
        if options && options[:grade]
          req << " WHERE CAST(SUBSTRING(s.specs,6,1) AS UNSIGNED) <= #{options[:grade]}"
        end
        req << ' ORDER BY s.updated_at DESC'
        req << " LIMIT #{from}, #{nombre};"

        site.db.use_database(:forum)
        site.db.execute(req)
      end
    end #/self Sujet
  end #/Sujet
end #/Forum
