# encoding: utf-8
class Analyse
  class AFile

    # Un lien externe vers le fichier courant
    def as_full_link
      @as_link ||= full_link("analyser/file/#{id}", "Voir le fichier #{data[:titre]}")
    end
    
    # Pour ajouter un contributeur au fichier
    # @param {Hash} hncont
    #               Données contenant le nouveau contributeur
    #               :id, :role
    #               
    # Note : seul le créateur du fichier ou un administrateur peut
    # exécuter cette opération.
    #
    def add_contributor hncont
      ufiler.creator? || ufiler.admin? || raise(NotAccessibleViewError.new)
      ncont_id   = hncont[:id].to_i
      ncont_role = hncont[:role].to_i
      site.db.insert(
        :biblio, 'user_per_file_analyse',
        {user_id: ncont_id, file_id: self.id, role: ncont_role}
      )
      newc = User.get(ncont_id)
      newc.send_mail({
        subject:  "Ajout comme contributeur à un fichier",
        formated: true,
        message:  <<-HTML
        <p>Bonjour #{newc.pseudo},</p>
        <p>Ce message pour vous informer que #{ufiler.pseudo} vient de vous 
        ajouter comme contributeur (en qualité de #{User.human_role(ncont_role)}) sur l'analyse de
        “#{analyse.film.titre}” à laquelle vous contribuez.</p>
        <p>Vous pouvez rejoindre cette analyse par le lien :</p>
        <p class="center">#{analyse.as_full_link}</p>
        <p>Vous pouvez voir ce fichier en suivant le lien :</p>
        <p class="center">#{self.as_full_link}</p>
        <p>Bonne participation à vous et merci de votre contribution !</p>
        HTML
      })
      __notice("Nouveau contributeur ajouté avec succès. Il a également été prévenu.")
    end

    # Pour supprimer un contributeur au fichier
    #
    # Cette opération s'appelle depuis la liste des contributeurs à un
    # fichier.
    #
    # Note : seule le créateur du fichier ou un administrateur
    # peut exécuter cette opération.
    #
    # Note : deux cas peuvent se présenter. Soit le contributeur n'a pas
    # contribué du tout et on peut le détruire simplement, soit il a contribué
    # et on marque simplement qu'il n'est plus actif sur ce fichier.
    #
    # @param {Fixnum} cont_id
    #                 Identifiant du contributeur
    #                 Ou l'instance User du contributeur.
    # @param {String} motif
    #                 La raison pour laquelle on le supprime
    #                 Peut être nil pour le moment.
    #
    def remove_contributor cont_id, motif = nil
      ufiler.creator? || ufiler.admin? || raise(NotAccessibleViewError.new)
      
      # On ne peut pas faire cette opération sur le créateur du fichier
      cont_id != creator_id || (return __error("Impossible de supprimer le créateur du fichier lui-même."))

      # Supprimer le contributeur consiste à supprimer sa donnée dans la
      # table `user_per_file_analyse`. Mais si le contributeur a déjà produit 
      # des versions du fichier courant, on doit le garder comme contributeur, mais
      # préciser simplement qu'il n'est plus actif.

      cont_wrote_versions = Dir["#{fpath}/*-#{cont_id}.*"].count > 0 
      cont = User.get(cont_id)

      if cont_wrote_versions
        
        # <= Le contributeur à supprimer a écrit des versions
        # => Il ne faut pas supprimer son enregistrement dans `user_per_file_analyse`
        #    mais simplement modifier son rôle.

        site.db.use_database(:biblio)
        site.db.execute(<<-SQL)
            UPDATE user_per_file_analyse
            SET role = role | 32
            WHERE file_id = #{self.id} AND user_id = #{cont_id}
          SQL

      else

        # <= Le contributeur à supprimer n'a écrit aucune version du fichier
        # => On peut détruire simplement son enregistrement dans `user_per_file_analyse`

        site.db.delete(
          :biblio, 'user_per_file_analyse',
          {user_id: cont_id, file_id: self.id}
        )

      end

      # Avertir le contributeur

      cont.send_mail({
        subject:    "Changement de votre rôle de contribut#{cont.f_rice}",
        formated:   true,
        message: <<-HTML
        <p>#{cont.pseudo},</p>
        <p>Je vous informe que vous n'êtes plus contribut#{cont.f_rice} acti#{cont.f_ve} du fichier 
        "#{self.titre}" de l'analyse de film "#{analyse.film.titre}".</p>
        <p>Merci de votre attention.</p>
        HTML
      })
      __notice("#{cont.pseudo} ne contribue plus à ce fichier.")
    end

  end #/AFiler
end #/Analyse
