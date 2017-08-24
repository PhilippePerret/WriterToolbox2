# encoding: UTF-8
class Site

  # @return {String} Citation
  #                   Le texte formaté d'une citation à mettre en entête
  #                   des messages
  def citation_courante
    @citation_courante ||= begin
      db.use_database(:biblio)
      res = db.execute('SELECT citation, auteur, id FROM citations ORDER BY last_sent ASC LIMIT 1;')
      q = res.first
      # On actualise la date de dernier envoi de cette citation
      db.update( :biblio, 'citations',
        {last_sent: Time.now.to_i}, {id: q[:id]}
      )
      # On construit le texte une fois pour toutes
      "<a href=\"http://#{configuration.url_online}/citation/show/#{q[:id]}\">" +
        "<span id=\"quote_citation\">#{q[:citation].strip_tags(' ')}</span>" +
        "<span id=\"quote_auteur\">#{q[:auteur]}</span>" +
      "</a>"
    end
  end

end
