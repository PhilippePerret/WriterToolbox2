# encoding: utf-8
class Analyse
  class << self

    # Pour définir ou récupérer la sortie à écrire dans la page
    def output sometext = nil
      if sometext
        @outputs ||= String.new
        @outputs << sometext
      else
        @outputs
      end
    end


    # Méthode pour créer une nouvelle analyse
    # @param {User} analyste
    #               L'analyste qui veut initier cette analyse
    # @param {Hash} adata
    #               Les données pour l'analyse à initier
    #               Ce sont les champs du formulaire de création
    #                 :film_titre   Titre du film (if any)
    #                 :film_annee   Année du film (if any)
    #                 :film_id      ID du film (if any - menu)
    #
    def create_new analyste, adata

      # Produit une erreur si l'analyste n'en est pas un

      analyste_only
      
      # On prépare les données, par exemple on cherche l'ID d'un film 
      # qui est fourni par son titre. Si tout se passe bien, on poursuit, sinon
      # on interromp la procédure
      #
      # Noter qu'on donne un Hash avec pour clé :titre_film, :titre_id, etc. et
      # qu'on reçoit un Hash avec :id, :titre et :annee (d'où le changement de
      # nom de la variable : "adata" -> "fdata")

      fdata = prepare_data(adata) || return

      # Produit une erreur si ce film est déjà analysé

      initiate_enabled?(fdata) || return

      # Tout est OK, on peut initier l'analyse

      initiate_analyse_film(analyste, fdata)

      # Les données générales de l'analyse, pour information
      # Elles seront écrites dans le document.

      output(data_generale_analyse(fdata))

    end

    # Initialisation de l'analyse du film défini par les
    # données +fdata+
    # @param {User} analyste
    #               L'analyste qui initie cette analyse.
    # @param {Hash} fdata
    #               Données pour le film à initier
    #               :titre, :annee, :id
    def initiate_analyse_film analyste, fdata
      
      # On marque que le film est initié

      specs = site.db.select(:biblio,'films_analyses',{id: fdata[:id]},[:specs]).first[:specs]
      specs[0] = '1'
      site.db.update(:biblio,'films_analyses',{specs: specs},{id: fdata[:id]})

      # On crée la relation entre l'analyste et l'analyse

      site.db.insert(
        :biblio,'user_per_analyse',{
        user_id: analyste.id,
        film_id: fdata[:id],
        role:    1|128|256
      })

      # On informe l'administration de cette initiation

      require_lib('site:mails_admins')
      site.mail_to_admins({
        subject:  "Nouvelle analyse initiée par #{analyste.pseudo}",
        formated: true,
        message:  <<-HTML
        <p>Ch<%=f_ere%> <%=pseudo%>,</p>
        <p>Je t'informe que #{analyste.pseudo} vient d'initier une
        nouvelle analyse pour le film #{fdata[:titre]} (#{fdata[:annee]}).</p>
        <p>Vous pouvez trouver cette analyse à l'adresse ci-dessous :</p>
        <p class="center">#{full_link("analyse/lire/#{fdata[:id]}")}</p>
        <p>Vous pouvez souhaiter bon courage à #{analyste.pseudo} (#{analyste.mail}), et de l'aide s'il en a besoin.</p>
        HTML
      })

      __notice("L’analyse a été initiée avec succès.")

      return true

    end


    # Données générales de l'initialisation, écrites dans le document
    # quand tout s'est bien passé
    def data_generale_analyse fdata
      lien_online_postuler = full_link("analyser/postuler/#{fdata[:id]}", "postuler à “#{fdata[:titre]}”")
      <<-HTML
      <p class="bold">Données générales de l’analyse du film “#{fdata[:titre]}” :</p>
      <p>Pour produire les documents de cette analyse : #{simple_link("analyser/dashboard/#{fdata[:id]}")}.</p>
      <p>Pour transmettre à d’autres analystes la lien pour la contribution : #{lien_online_postuler}.</p>
      <p>Pour consulter l'analyse en ligne : #{simple_link("analyse/lire/#{fdata[:id]}")}.</p>
      <p>Pour trouver de l'aide sur la création et la rédaction des documents d'analyse : 
      #{simple_link("aide?p=analyse%2Fcontribuer", 'Aide à la contribution')}.</p>
      HTML
    end

    

    # Prépare ls données pour l'initialisation de l'analyse et 
    # notamment recherche l'identifiant du film s'il a été fourni
    # par son titre (et son année) ou inversement définit son titre
    # et son année s'il a été défini par son ID.
    #
    # Noter que la définition du titre explicite est prioritaire sur le
    # choix dans le menu.
    #
    # @param {Hash} adata
    #               Les données du film, transmises par le formulaire.
    #               Contient:
    #                 :film_titre     Le titre du film (if any)
    #                 :film_annee     L'année (string) du film (if any)
    #                 :film_id        L'ID (string) du film (défini par le menu)
    #               Peut être nil en cas de "forçage" d'url
    def prepare_data adata
      
      if adata.nil?

        raise("Il faut fournir les données du film dont il faut initier l'analyse.")

      elsif adata[:film_titre].nil_if_empty

        film_titre = adata[:film_titre].strip
        film_annee = adata[:film_annee].nil_if_empty.to_i
        film_annee > 1894 || raise("Il faut fournir l'année du film quand on fournit son titre, et une année supérieur à 1894 (= #{film_annee.inspect}).")
        # Pour faire la recherche du titre dans la base de données, on doit supprimer
        # toutes les lettres majuscules et autres, car contrairement à ce que je lis
        # partout la recherche est case sensitive, et si l'user a entrer des lettres 
        # n'importe comment, ça ne fonctionnera pas.
        titre_searched = film_titre.gsub(/[^a-z]/,'_')
        where = "titre LIKE '#{titre_searched}'"
        hfilm = nil
        site.db.select(:biblio,'filmodico',where,[:titre,:annee,:id]).each do |hf|
          if film_titre.downcase == hf[:titre].downcase
            if film_annee > hf[:annee] - 5 && film_annee < hf[:annee] + 5
              hfilm = hf
              break
            end
          end
        end
        
        # Soit le film a été trouvé et on renseigne l'identifiant, soit
        # le film n'a pas été trouvé et on doit faire une demande à
        # l'administration (ou aux analystes compétents) pour créer la
        # fiche de ce nouveau film.

        if hfilm == nil
          
          # Le film n'a pas été trouvé, il faut transmettre une requête aux
          # administrateurs pour créer la fiche de ce nouveau film
          requete_nouveau_film_filmodico(titre: film_titre, annee: film_annee)

          return false

        else

          # Sinon, on peut retourner les données de ce film
          
          return hfilm

        end

      elsif adata[:film_id].nil_if_empty

        # Si un film a été choisi dans le menu des films
        # pas encore analysés.

        film_id = adata[:film_id]
        hf = site.db.select(:biblio,'filmodico',{id: film_id},[:titre, :annee, :id]).first
        hf != nil || raise("L'identifiant du film est inconnu…")

        return hf

      else

        raise("Il faut soit donner le titre du film, soit le choisir dans le menu.")

      end

    rescue Exception => e
      debug e
      __error(e.message)
    end


    # Retourne true si l'initialisation de cette analyse est possible
    # Sinon, affiche l'erreur et retourne false pour interrompre la
    # procédure
    def initiate_enabled? fdata
      Film.is_analysed?(fdata[:id]) && 
        begin
          titre_upcase = "<span class='film'>#{fdata[:titre].upcase}</span>"
          output(
            <<-HTML
             <p><a href="analyse/lire/#{fdata[:id]}">⇥ Consulter l’analyse de #{titre_upcase}</a> 
             <p><a href="analyser/postuler/#{fdata[:id]}">⇥ Contribuer à l’analyse de #{titre_upcase}</a> 
            HTML
          )
          raise("Ce film fait déjà l’objet d’une analyse.")
      end
    rescue Exception => e
      debug e
      __error(e.message)
    else
      true # pour poursuivre
    end


    def requete_nouveau_film_filmodico fdata
      require_lib('site:mails_admins')
      site.mail_to_admins({
        subject: "Fiche film Filmodico à créer",
        formated: true,
        message: <<-HTML
        <p>Ch<%=f_ere%> <%=pseudo%>,</p>
        <p>Je t'informe de la demande de création d'une <strong>nouvelle fiche Filmodico</strong> par un
        analyste du site.</p>
        <p>Il s'agit du film #{fdata[:titre]} (#{fdata[:annee]}).</p>
        <p>Cette demande a été émise par #{user.pseudo} (#{user.mail}). Merci de lui signaler lorsque cette fiche sera créée.</p>
        HTML
      }, {analystes: true})
    end


  end #/<<self

  class Film
    class << self

      # Retourne true si le film d'ID +film_id+ est analysé
      def is_analysed? film_id
        hf = site.db.select(:biblio,'films_analyses',{id: film_id.to_i},[:specs]).first
        hf != nil || raise("Aucun film ne possède l'identifiant #{film_id}… Merci de revoir votre copie.")
        hf[:specs][0] == '1'
      end

      # Retourne le code d'un select avec tous les films du filmodico qui n'ont pas
      # été analysés.
      def menu_films_unanalysed
        request = <<-SQL
        SELECT f.titre, f.titre_fr, f.annee, f.id
          FROM films_analyses fa
          INNER JOIN filmodico f ON fa.id = f.id
          WHERE SUBSTRING(specs,1,1) = '0'
          ORDER BY f.annee DESC
        SQL
        site.db.use_database(:biblio)

        "<select name=\"analyse[film_id]\" id=\"analyse_film_id\">"+
        site.db.execute(request).collect do |hfilm|
          titre = hfilm[:titre].force_encoding('utf-8')
          hfilm[:titre_fr].nil_if_empty && titre << " (#{hfilm[:titre_fr].force_encoding('utf-8')})"
          "<option value=\"#{hfilm[:id]}\">#{hfilm[:annee]} - #{titre}</option>"
        end.join +
        '</select>'
      end
    end #/<< self (Film::Analyse)
  end #/Film
end #/Analyse
