# encoding: utf-8
class Forum
  class Sujet

    # Souscrire l'user +follower+ au sujet courant
    def suscribe follower
      user.id == follower.id || user.admin? || raise("Opération interdite.")
      
      # La requête pour suivre le sujet

      site.db.use_database(:forum)
      site.db.execute(
        "INSERT INTO follows (user_id, sujet_id, created_at) VALUES (?, ?, ?)", 
        [follower.id, self.id, Time.now.to_i]
      )

      # Le message de retour affiché dans la page

      lien_profil = simple_link("user/profil", "votre page de profil", 'exergue')
      <<-HTML
      <p>Vous suivez à présent le sujet « #{data[:titre]} ».</p>
      <p class="center">#{simple_link(self.route,'→ Retourner au sujet', 'exergue')}</p>
      <p>Vous pouvez retrouver tous les sujets que vous suivez sur #{lien_profil}.</p>
      HTML
    end


    # Désinscrire l'user +follower+ du sujet courant
    def unsuscribe follower
      user.id == follower.id || user.admin? || raise("Opération interdite.")

      # La requête pour supprimer le suivi

      site.db.use_database(:forum)
      site.db.execute("DELETE FROM follows WHERE user_id = ? AND sujet_id = ?", [follower.id, self.id])

      # Le message à afficher dans la page

      lien_profil = simple_link("user/profil", "votre page de profil", 'exergue')
      <<-HTML
      <p>Vous ne suivez plus le sujet « #{data[:titre]} ».</p>
      <p class="center">#{simple_link(self.route,'→ Retourner au sujet', 'exergue')}</p>
      <p>Vous pouvez retrouver tous les sujets que vous suivez sur #{lien_profil}.</p>
      HTML
    end

  end #/Sujet
end #/Forum
