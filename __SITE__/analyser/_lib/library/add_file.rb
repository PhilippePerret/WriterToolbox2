# encoding: utf-8
class Analyse

  #--------------------------------------------------------------------------------
  #
  #   INSTANCE
  #
  #--------------------------------------------------------------------------------


  # Ajout d'un fichier à l'analyse
  #
  # @param {hash}   hfile
  #                 Données pour le fichier et notamment :
  #                 :titre    Le titre du fichier
  #                 :type     Le type du fichier (2e bit)
  # @param {User}   owner
  #                 Possesseur du fichier, c'est-à-dire celui qui crée
  #                 la donnée. Il sera mis en `user_id` dans la base.
  #
  def add_file hfile, owner
    ftype = hfile.delete(:type).to_i
    specs = '0'*8
    specs[1] = ftype.to_s
    hfile.merge!(film_id: self.id, specs: specs)
    file_id = 
      site.db.insert(
        :biblio,
        'files_analyses',
        hfile.merge!({
          film_id: self.id,
          specs:   specs
        })
      )

    # La donnée par `user_per_file_analyse`
    dupf = site.db.insert(
      :biblio,
      'user_per_file_analyse',
      {
        file_id: file_id,
        user_id: owner.id,
        role:    1
      }
    )

    # On fait l'annonce à tous les contributeurs, sauf celui qui
    # a créé ce fichier

    hfile.merge!(id: file_id, owner: owner)
    contributors.each do |hcont|
      mail_annonce_new_file(hcont, hfile)
    end


  end

  # Envoi du mail d'annonce de nouveau fichier à tous les 
  # contributeur de l'analyse.
  #
  # @param {Hash} hcont
  #               Les données du contributeur, et notamment
  #               son rôle dans l'analyse, ce qui permettra
  #               de faire une annonce différente pour le
  #               créateur de l'analyse
  # @param {Hash} hfile
  #               Les données du nouveau fichier, et notamment :
  #               :id       Son identifiant
  #               :owner    {User} Dépositeur du fichier
  #               :titre    Son titre
  #
  def mail_annonce_new_file hcont, hfile
    owner = hfile[:owner]

    # (noter qu'on pourrait faire une seule condition ci-dessous, mais pour la
    #  clarté j'en mets deux)
    if creator?(hcont[:id]) && owner.id == hcont[:id]
      # <= Le créateur de l'analyse et le dépositeur du fichier
      # => On ne fait rien
      return
    elsif owner.id == hcont[:id]
      # <= Le contributeur est le dépositeur du fichier
      # => On ne lui envoie rien, qu'il soit ou non le créateur
      #    de l'analyse.
      return
    end

    # Les infos du fichier, pour tout le monde

    infos_fichier = <<-HTML
      <p>Voici les infos précises sur ce dépôt :</p>
      <div>Analyse de : #{full_link("analyser/dashboard/#{id}",film.titre,'exergue')}</div>
      <div>Titre du fichier : #{hfile[:titre]} (##{hfile[:id]})</div>
      <div>Auteur du fichier : #{full_link("user/profil/#{owner.id}",owner.pseudo,'exergue')}</div>
      <div>#{full_link("analyser/file/#{hfile[:id]}",'voir le fichier')}</div>
    HTML

    # Définition du message et du sujet, en fonction du rôle

    if creator?(hcont[:id])

      # <= Le propriétare de l'analyse
      # => Un mail particulier

      sujet = "Nouveau fichier créé sur votre analyse"
      message = <<-HTML
          <p>Bonjour #{creator.pseudo},</p>
          <p>Je vous informe qu'un de vos contributeurs vient de déposer un fichier 
          sur votre analyse de #{film.titre}</p>
          #{infos_fichier}
          <p>Merci de votre attention.</p>
      HTML

    else

      # <= Un contributeur de l'analyse
      # => Le mail normal

      sujet = "Nouveau fichier sur une analyse à laquelle vous contribuez"
      message = <<-HTML
        <p><%= pseudo %>,</p>
        <p>Je vous informe qu'un nouveau fichier vient d'être créé par 
        #{owner.pseudo} sur l'analyse de “#{film.titre}” à laquelle vous contribuez.</p>
        #{infos_fichier}
        <p>Merci de votre attention.</p>
      HTML

    end
    User.get(hcont[:id]).send_mail({
      subject:  sujet,
      formated: true,
      message:  message
    })
  end

end #/Analyse
