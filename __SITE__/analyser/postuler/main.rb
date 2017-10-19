# encoding: utf-8
class Analyse

  class << self
    
    # Appelée quand l'analyste confirme sa demande de participation
    # à l'analyse spécifiée dans l'URL
    #
    # @param {User} candidat
    #               L'user qui postule pour l'analyse courante.
    def confirmation analyse_id, candidat
      require_lib('analyser:proposition')
      do_proposition_contribution analyse_id, candidat
      @confirmation_is_confirmed = true
    end

    # TRUE quand la proposition a été confirmer par le candidat, pour
    # lui afficher le bon message.
    def confirmed? ; @confirmation_is_confirmed || false end



    # Demande de participation générale aux analyses par +candidat+
    # 
    # @param {User} candidat
    #               L'user qui postule pour les analyses de film
    #
    def demande_de_participation candidat

      # On indique que le candidat est analyste
      # TODO Est-ce vraiment maintenant qu'il faut faire ça ?
      opts = candidat.data[:options].ljust(17,'0')
      opts[16] = '1'
      candidat.set(options: opts)


      lien_dashboard = simple_link(
        "http://#{site.configuration.url_online}/admin/analyse", 
        'bureau d’administration des analyses'
      )

      mess = <<-HTML
      <p>Ch\<%=f_ere%\> administrat\<%=f_rice%\>,</p>
      <p>Je vous fais part de la demande de participation aux analyses 
        de films de #{candidat.pseudo} (##{candidat.id}).</p>
      <p>Pour <strong>valider cette demande</strong>, il faut rejoindre le #{lien_dashboard}.</p>
      <p>Merci de votre attention.</p>
      HTML

      # Envoi du mail aux administrateurs

      require_lib('site:mails_admins')
      data_mail = {
        subject: "Demande de participation aux analyses de films",
        formated: true,
        message:  mess 
      }
      site.mail_to_admins(data_mail)
    end

  end #/<< self


  # Méthode d'instance renvoyant TRUE si l'analyse est en cours
  # FALSE dans le cas contraire.
  def en_cours?
    data[:specs][5] == '1'
  end

end #/Analyse


