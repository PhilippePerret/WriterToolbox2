# encoding: utf-8
class Analyse
  class AFile

    # Sortie du fichier à afficher dans la page
    #
    # Dépend de l'opération choisie. Par défaut, c'est l'opération 'voir'
    #
    def output ope, who
      contenu_displayed(ope, who)
    end

    
    # Titre affiché dans la page
    #
    # Attention, il n'est pas lié à `output` comme `contenu_displayed`.
    def titre_displayed
      data[:titre]
    end

    # Le contenu affiché, en fonction de celui qui visite
    #
    # Qu'il y ait un fichier ou non, le div est inscrit, car il peut
    # aussi contenir le formulaire d'édition du texte.

    def contenu_displayed ope, who

      debug "-> contenu_displayed avec who = #{who.pseudo} (#{who.id} - #{role_of(who).inspect})"

      redactor?(who) || analyse.contributor?(who) || corrector?(who) || who.admin? || visible_par_inscrit? || (return '')

      debug "-> contenu_displayed il passe avec who = #{who.pseudo} (#{who.id})"

      <<-HTML
      <div class="file_content" id="file-#{id}-content">
        #{ope == 'edit' || ope == 'save' ? formulaire_edition(who) : apercu(who) }
      </div>
      HTML
    end

    def formulaire_edition who
      '[plus tard, je retournerai le formulaire d’édition]'
    end

    def apercu who
      if File.exist?(path)
        formate_file(path)
      else
        '[Ce fichier ne possède pas encore de contenu. Cliquer le bouton “edit” pour le définir.]'
      end
    end
    
    

    # Boutons pour éditer, publier, etc. le fichier courant
    # Les boutons sont affichés en fonction du statut de l'user qui visite
    # et de l'opération courante, qui est toujours définie ici.
    #
    # @param {Symbol} where
    #                 :top ou :bottom pour savoir où ils sont placés
    # @param {String} ope
    #                 L'opération courante, p.e. 'voir' ou 'publish'
    # @param {User}   who
    #                 Le visiteur pour lequel sont affichés les boutons
    #
    def buttons where, ope, who
      btn_remove = btn_edit = btn_publish = btn_save = btn_voir = ''

      is_creator_analyse = analyse.creator?(who)
      who_is_redactor   = self.redactor?(who)
      who_is_corrector  = self.corrector?(who)

      debug "is_creator_analyse: #{is_creator_analyse.inspect}"
      debug "who role : #{role_of(who).inspect}"

      if who_is_redactor || is_creator_analyse || who_is_corrector || who.admin? 
        ope != 'edit'    && btn_edit    = bouton_editer 
        ope != 'publish' && btn_publish = bouton_publier 
        btn_save = bouton_sauver 
        ( is_creator_analyse || who.admin? || creator?(who) ) && 
          begin
            debug "Le bouton remove peut être écrit"
            btn_remove = bouton_remove 
        end
      end

      ope != 'voir' && btn_voir = bouton_voir 

     <<-HTML
     <div class="file_buttons #{where}">
     #{btn_remove}#{btn_publish}#{btn_edit}#{btn_voir}#{btn_save}
     </div>
     HTML
    end


    def bouton_editer
      build_bouton('edit', 'éditer')
    end
    def bouton_publier
      build_bouton('publish', 'publier')
    end
    def bouton_sauver
      build_bouton('save', 'sauver')
    end
    def bouton_remove
      build_bouton('rem', 'détruire', 'warning')
    end
    def bouton_voir
      build_bouton('voir')
    end

    # Construit les boutons

    def build_bouton ope, tit = nil, css = nil
      simple_link("analyser/file/#{id}?op=#{ope}", tit || ope, css)
    end

  end #/AFile
end #/Analyse
