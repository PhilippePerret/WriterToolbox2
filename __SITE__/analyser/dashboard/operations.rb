# encoding: utf-8
class Analyse
  class << self

    def eject_user mess = nil
      mess ||= "Vous n’êtes pas en mesure d’accomplir cette opération…"
      redirect_to('home', [mess, :error])
    end

    # Traite l'opération désignée par +op+ dans les paramètres
    #
    def traite_operation he, ope
      he.analyste? || he.admin? || (return eject_user)
      case ope
      when 'add_file'
        has_contributor?(analyse.id, he.id) || (return eject_user)
        analyse.add_file(param(:file), he)
      end
    end

  end #/<< self

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
    site.db.insert(
      :biblio,
      'user_per_file_analyse',
      {
        file_id: file_id,
        user_id: owner.id,
        role:    1
      }
    )

    unless owner.creator?
      creator.send_mail({
        subject: "Nouveau fichier créé sur votre analyse", 
        formated: true,
        message: <<-HTML
        <p>Bonjour #{creator.pseudo},</p>
        <p>Je vous informe qu'un de vos contributeurs vient de déposer un fichier 
        sur votre analyse de #{film.titre}</p>
        <p>Voici les infos précises sur ce dépôt :</p>

        HTML
      })
    end
  end

end #/Analyse
