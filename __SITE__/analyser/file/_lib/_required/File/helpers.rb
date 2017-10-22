# encoding: utf-8
class Analyse
  class AFile

    # Sortie du fichier à afficher dans la page
    #
    # Dépend de l'opération choisie. Par défaut, c'est l'opération 'voir'
    #
    def output ope
      contenu_displayed(ope)
    end

    
    # Titre affiché dans la page
    #
    # Attention, il n'est pas lié à `output` comme `contenu_displayed`.
    def titre_displayed
      data[:titre]
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
    def buttons where, ope
      btn_remove = btn_edit = btn_publish = btn_save = btn_voir = ''
      
      if ope == 'compare' 

      else
        is_creator_analyse = analyse.uanalyser.creator?

        if ufiler.redactor? || is_creator_analyse || ufiler.corrector? || ufiler.admin? 
          ope != 'edit'    && btn_edit    = bouton_editer 
          ope != 'publish' && btn_publish = bouton_publier 
          ope != 'compare' && 
          btn_save = bouton_sauver 
          ( is_creator_analyse || ufiler.admin? || ufiler.creator? ) && btn_remove = bouton_remove 
        end

        ope != 'voir' && btn_voir = bouton_voir 
      end
     <<-HTML
     <div class="file_buttons #{where}">
     #{btn_remove}#{btn_publish}#{bouton_compare}#{btn_edit}#{btn_voir}#{btn_save}
     </div>
     HTML
    end


    def bouton_editer
      build_bouton('edit', 'éditer')
    end
    def bouton_publier
      build_bouton('publish', 'publier', 'green')
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
    def bouton_compare
      debug "fpath existe ? #{File.exist?(fpath).inspect}"
      debug "Fichiers : #{Dir[fpath+'/*.*'].inspect}"
      Dir["#{fpath}/*.*"].count > 1 ? build_bouton('compare') : ''
    end

    # Construit les boutons

    def build_bouton ope, tit = nil, css = nil
      simple_link("analyser/file/#{id}?op=#{ope}", tit || ope, css)
    end

  end #/AFile
end #/Analyse
