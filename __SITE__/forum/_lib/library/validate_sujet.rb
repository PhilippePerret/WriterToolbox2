# encoding: utf-8
class Forum
  class Sujet
    class << self

      # Validation du sujet de données +hsujet+ (lorsque l'on vient de valider
      # son premier message, ou qu'on s'apprête à le faire)
      #
      # Note : la méthode s'appelle "data_validation" car elle renvoie simplement
      # des données qui vont être ajoutées aux données enregistrées dans le sujet
      # lorsqu'un nouveau message est validé (pour le réglage de :last_post_id)
      #
      # Cette méthode permet aussi de faire de l'auteur le premier follower
      # de son nouveau sujet.
      def data_validation hsujet
        h = Hash.new
        sujet_specs = hsujet[:specs]
        sujet_specs[0] = '1'
        sujet_specs[4] = '1'
        h.merge!(specs: sujet_specs)

        # Avant d'appeler cette méthode, le :count de messages est incrémenté,
        # il faut donc, ici, le remettre à 1, entendu qu'il y a toujours un
        # et un seul message à la création d'un nouveau sujet.
        h.merge!(count: 1)

        # Le créateur du sujet suit son sujet
        site.db.use_database(:forum)
        site.db.execute(
          "INSERT INTO follows (user_id, sujet_id, created_at) VALUES (?, ?, ?)", 
          [hsujet[:creator_id], hsujet[:id], Time.now.to_i]
        )

        return h
      end
    end #/<<self Forum::Sujet
  end #/Sujet
end #/Forum
