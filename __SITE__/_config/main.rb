site.configure do |s|

  # URL du site
  # -----------
  # Ces deux données sont obligatoires (elles déterminent notamment la
  # METADATA `base` définissant la racine du site)
  # Ne pas mettre de '/' à la fin de ces deux adresses.
  s.url_online  = 'www.laboiteaoutilsdelauteur.fr'
  s.url_offline = 'localhost/WriterToolbox2'

  # PRÉFIXE DES BASES DE DONNÉES
  # ----------------------------
  # Données obligatoire pour pouvoir interagir avec les bonnes bases de
  # données.
  # Si nil, c'est la base '_<nom base>' qui sera utilisé (avec le '_')
  s.db_bases_prefix = 'boite-a-outils'

  # Le titre normal du site
  # -----------------------
  s.titre = 'La Boite à outils de l’auteur'
  # Le titre raccourci
  # ------------------
  s.short_titre = "BOA"

  # Mail principal
  # --------------
  # Utilisé notamment pour le :from et le :to des mails lorsqu'ils
  # ne sont pas définis.
  s.main_mail = 'phil@laboiteaoutilsdelauteur.fr'

  # Identifiant Facebook et Twitter
  # -----------------------
  s.facebook  = 'laboiteaoutilsdelauteur'
  s.twitter   = 'b_outils_auteur'

  # Observation des SASS
  # --------------------
  # Si cette propriété est à true et que l'on se trouve offline,
  # les fichiers SASS sont testés pour voir s'il faut les actualiser.
  s.watch_sass = true

  # Nom du cookie de session
  # ------------------------
  # Propre à ce site, sinon, on prend la valeur par défaut définie dans
  # ./lib/site/session.rb#cookie_name
  s.cookie_session_name = nil

end
