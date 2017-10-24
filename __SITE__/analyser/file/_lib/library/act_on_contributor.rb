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
      afiler.creator? || afiler.admin? || raise(NotAccessibleViewError.new)
      
      # Avertir le contributeur
      # TODO
      __notice("Je dois supprimer le contributeur #{cont_id}")
    end

  end #/AFiler
end #/Analyse
