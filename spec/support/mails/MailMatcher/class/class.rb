# encoding: UTF-8

=begin

  Class MailMatcher
  -----------------
  Pour tester les mails

  * Pour obtenir le mail checké (si un seul):

    MailMatcher::mail_found
    # => Un hash avec les données du mail

  * Pour obtenir les mails checkés (si plusieurs)

    MailMatcher::mails_found
    # => Array de hash des données des mails

  * Pour obtenir tous les mails

    MailMatcher::all_mails
    # => Array de hash des données des mails

  * Pour obtenir les mails qui ne satisfaisaient pas la recherche

    MailMatcher::bad_mails
    # => Array de hash des données des mails

=end
class MailMatcher
  class << self

    # Les mails trouvés, qui correspondent à la recherche
    # C'est un Array d'instances MailMatcher
    attr_reader :mails_found
    # Les mails qui ne remplissaient pas les conditions de
    # la recherche.
    attr_reader :bad_mails

    # Les mails qui correspondent presque à la recherche
    def almost_founds ; @_almost_founds || {} end

    # Tous les mails contenus dans le dossier temporaire
    # des mails envoyés.
    # Rappel : ils sont tous au format Marshal
    #
    # Array de Hash de données
    #
    # Chaque donnée contient :
    #   :subject      Le sujet complet du message
    #   :message      Le message
    #   :created_at   La date d'envoi
    #   :to           Le mail du destinataire
    #   :from         Le mail de l'expéditeur
    #
    def all_mails
      Dir["#{folder_mails_temp}/*.msh"].collect do |path|
        File.open(path, 'r'){ |f| Marshal.load(f) }
      end
    end

    # Ajoute un mail à la liste des mails presque valides.
    #
    # Noter que tous les mails valides commencent par passer par là,
    # dès que leur première propriété correspond, et qu'on appelle ensuite
    # la méthode `sup_almost_found` pour les retirer.
    def add_almost_found key, mail
      @_almost_founds ||= Hash.new
      @_almost_founds.key?(mail.id) || begin
        @_almost_founds.merge!(mail.id => {instance: mail, keys: Array.new})
      end
      @_almost_founds[mail.id][:keys] << key
    end
    # Quand le message est finalement valide, on le retire des "presque"
    # trouvés.
    def sup_almost_found mail
      @_almost_founds ||= Hash.new
      @_almost_founds.delete(mail.id)
    end
    # Quand le message correspond presque, on lui ajoute les raisons de son
    # échec pour le message final.
    def almost_found_add_bad_props mail, raison_echec
      @_almost_founds[mail.id].merge!(raison_echec: raison_echec)
    end

    # Message ajouté au résultat quand on n'a trouvé aucun mail mais
    # que des messages correspondaient presque
    def message_almost_founds
      !almost_founds.empty? || ( return '' )
      nombre_almost = 0
      almost_as_message =
        almost_founds.collect do |mail_id, dfound|
          # dfound contient `keys`, la liste des clés qui correspondaient et
          # `instance`, l'instance mail du mail, pour pouvoir récupérer son
          # sujet.
          dfound[:keys] = dfound[:keys].uniq
          nbkeys = dfound[:keys].count
          s   = nbkeys > 1 ? 's' : ''
          les = nbkeys > 1 ? 'les' : 'la'
          nombre_almost += 1
          "\n\n \e[32m#{nombre_almost}. 📩 Presque valide : #{dfound[:instance].subject} \n\e[32m    Propriété#{s} valide#{s} : #{dfound[:keys].pretty_join}\n\e[31m    MAIS échoue sur :#{dfound[:raison_echec]}."
        end.join(', ')
      s     = nombre_almost > 1 ? 's' : ''
      sont  = nombre_almost > 1 ? 'sont' : 'est'
      "\n#{nombre_almost} mail#{s} #{sont} presque valide#{s} : #{almost_as_message}"
    end

    # Retourne le nombre de mail
    def nombre_mails
      all_mails.count
    end

    def add_message mess
      @message_to_add ||= ""
      @message_to_add << "#{mess} "
    end
    def message_added
      @message_to_add || ""
    end
    def flush_message
      @message_to_add = nil
    end


    # PATH du dossier contenant les données des mails qui
    # sont envoyés
    #
    def folder_mails_temp
      @folder_mails_temp ||= begin
        dpath = File.expand_path('./xtmp/mails')
        `mkdir -p "#{dpath}"`
        dpath
      end
    end

  end # << self
end #/MailMatcher
