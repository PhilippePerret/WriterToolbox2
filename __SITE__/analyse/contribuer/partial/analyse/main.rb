# encoding: utf-8
class Analyse
  class << self

    # Méthode appelée lorsqu'un analyse veut proposer sa contribution pour 
    # l'analyse courante.
    #
    # @param {Fixnum} film_id
    #                 ID du film donc de l'analyse
    # @param {User}   candidat
    #                 User qui se propose de contribuer à l'analyse du film
    #
    def proposition_contribution film_id, candidat
      
      # Ce doit être un analyste

      candidat.analyste? || 
        (return __error('Seul un analyste peut proposer sa contribution à une analyse.'))

      # Instance de l'analyse
      analyse = Analyse.new(film_id)

      # L'analyse doit être en cours

      analyse.specs[5] == '1' || 
        (return __notice('Désolé, mais cette analyse n’est pas en cours. Impossible d’y contribuer.'))
      
      # Le candidat ne doit pas faire partie des analystes de l'analyse
      
      Analyse.has_contributor?(film_id, candidat.id) &&
        (return __notice("Vous contribuez déjà à cette analyse. Que voulez-vous de plus ? ;-)"))
      
      # Tout est OK, on peut faire un ticket et transmettre la demande au
      # créator de l'analyse et à l'administration.

      # Faire un ticket

      require_folder('./lib/procedure/ticket')
      Ticket.create({
        user_id: candidat.id,
        code:    "require_lib('analyse:validation_proposition')\nAnalyse.validate_proposition(#{analyse.id},#{candidat.id})",
        a_title: 'Accepter immédiatement cette proposition',
        a_class: 'exergue'
      })
      lien_validation = Ticket.url.freeze

      Ticket.create({
        user_id: candidat.id,
        code: "require_lib('analyse:refus_proposition')\nAnalyse.refuser_proposition(#{analyse.id},#{candidat.id})",
        a_title: "Refuser cette proposition",
        a_class: 'exergue'
      })
      lien_refus = Ticket.link.freeze

      lien_creator  = full_link("user/profil/#{analyse.creator_id}", analyse.creator.pseudo, 'exergue')
      lien_candidat = full_link("user/profil/#{candidat.id}", candidat.pseudo, 'exergue')

      # Mail au créateur de l'analyse

      analyse.creator.send_mail({
        subject: "Proposition de contribution à l’analyse de #{analyse.film.titre}",
        formated: true,
        message: <<-HTML
        <p>Bonjour #{analyse.creator.pseudo},</p>
        <p>L'analyste #{lien_candidat} (#{candidat.mail}) vous propose de contribuer à votre analyse du film #{analyse.film.titre.upcase} (vous pouvez bien sûr prendre contact avec lui par son mail).</p>
        <p>Pour accepter directement cette proposition (sans autre forme de validation) :</p>
        <p class="center">#{lien_validation}</p>
        <p>Pour refuser directement cette proposition (en fournissant une raison) :</p>
        <p class="center">#{lien_refus}</p>
        <p>Dans tous les cas vous pouvez gérer ces propositions depuis le <a href="analyse/contribuer/#{film_id}" class="exergue">tableau de bord de votre analyse</a>.</p>
        <p>Merci de votre attention.</p>
        HTML
      })

      # Mail d'information à l'administration

      require_lib('site:mails_admins')
      site.mail_to_admins({
        subject: "Proposition de contribution à une analyse",
        formated: true,
        message: <<-HTML
        <p><%=pseudo%>,</p>
        <p>Juste pour information, une demande de proposition de contribution vient d'être déposée.</p>
        <p>Informations sur cette proposition de contribution :</p>
        <p>
          <div>Film : <a href="analyse/contribuer/#{film_id}">#{analyse.film.titre}</a></div>
          <div>Créateur de l'analyse : #{lien_creator} (##{analyse.creator_id} - #{analyse.creator.mail})</div>
          <div>Demandeur : #{lien_candidat} (##{candidat.id} - #{candidat.mail})</div>
          <div>Date proposition : #{Time.now.to_i.as_human_date}</div>
        </p>
        HTML
      })

      # Annoncer au candidat que la demande a été transmise

      __notice("Votre proposition de contribution vient d’être transmise à #{analyse.creator.pseudo}, créateur de cette analyse.<br>Il devrait vous répondre rapidement.<br>D’avance un grand merci à vous.")
    end
  end #/<< self
end #/Analyse
