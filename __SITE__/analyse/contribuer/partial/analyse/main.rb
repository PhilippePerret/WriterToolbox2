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
        raise('Seul un analyste peut proposer sa contribution à une analyse.')

      # L'analyse doit être en cours

      film.specs[5] == '1' || 
        (return __notice('Désolé, mais cette analyse n’est pas en cours. Impossible d’y contribuer.'))
      
      # Le candidat ne doit pas faire partie des analystes de l'analyse
      
      Analyse.has_contributor?(film_id, candidat.id) &&
        (return __notice("Vous contribuez déjà à cette analyse. Que voulez-vous de plus ? ;-)"))
      
      # Tout est OK, on peut faire un ticket et transmettre la demande au
      # créator de l'analyse et à l'administration.

      # TODO Définir `analyse`, une instance qui définira `creator_id` et `creator`
      # TODO Peut-être la faire avant le test `has_contributor?` pour qu'elle ait sa
      # propre méthode.
      analyse = Analyse.new(film_id)

      # Faire un ticket

      require_folder('./lib/procedure/ticket')
      Ticket.create({
        user_id: candidat.id,
        code:    "require_lib('analyse:validation_proposition')\nAnalyse.validate_proposition(#{candidat.id},#{analyse.creator_id})",
        a_title: 'Accepter immédiatement cette proposition',
        a_class: 'exergue'
      })
      lien_validation = Ticket.url.freeze

      Ticket.create({
        user_id: candidat.id,
        code: "require_lib('analyse:refus_proposition');\nAnalyse.refuser_proposition(#{candidat.id},#{analyse.creator_id})",
        a_title: "Refuser cette proposition",
        a_class: 'exergue'
      })
      lien_refus = Ticket.link.freeze

      analyse.creator.send_mail({
        subject: "Proposition de contribution à l'analyse de #{film.titre}",
        formated: true,
        message: <<-HTML
        <p>Bonjour #{analyse.creator.pseudo},</p>
        <p>L'analyste #{candidat.pseudo} (#{candidat.mail}) vous propose de contribuer à votre analyse du film #{film.titre.upcase} (vous pouvez bien sûr prendre contact avec lui par son mail).</p>
        <p>Pour accepter directement cette proposition (sans autre forme de validation) :</p>
        <p class="center">#{lien_validation}</p>
        <p>Pour refuser directement cette proposition (en fournissant une raison) :</p>
        <p class="center">#{lien_refus}</p>
        <p>Dans tous les cas vous pouvez gérer ces propositions depuis le <a href="analyse/contribuer/#{film_id}" class="exergue">tableau de bord de votre analyse</a>.</p>
        <p>Merci de votre attention.</p>
        HTML
      })
      # TODO Envoyer un mail au créateur de l'analyse ainsi qu'à 
      # l'administration du site.
      # TODO Annoncer au candidat que la demande a été transmise
    end
  end #/<< self
end #/Analyse
