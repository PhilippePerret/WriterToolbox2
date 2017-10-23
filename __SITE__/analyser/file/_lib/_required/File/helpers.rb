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
    #
    def buttons where, ope
      is_analyse_creator = analyse.uanalyser.creator?

      can_edit  = ufiler.redactor? || is_analyse_creator || ufiler.corrector? || ufiler.admin?
      can_admin = is_analyse_creator || ufiler.admin? || ufiler.creator?

      boutons = String.new

      # Les boutons, avec en clé leur préfixe de méthode ("bouton_<prefixe>") et
      # en valeur true ou false suivant qu'en la circonstance courante on peut les
      # afficher ou non.
      {
        'remove'  => can_admin,
        'publish' => can_admin,
        'compare' => true,
        'edit'    => can_edit,
        'voir'    => true
      }.each do |kbutton, visible|
        kbutton == 'compare' || (visible && ope != kbutton) || next
        boutons << send("bouton_#{kbutton}".to_sym)
      end
      
     <<-HTML
     <div class="file_buttons #{where}">#{boutons}</div>
     HTML
    end


    def bouton_edit
      build_bouton('edit', 'éditer')
    end
    def bouton_publish
      build_bouton('publish', 'publier', 'green')
    end
    def bouton_remove
      build_bouton('rem', 'détruire', 'warning')
    end
    def bouton_voir
      build_bouton('voir')
    end
    def bouton_compare
      Dir["#{fpath}/*.*"].count > 1 ? build_bouton('compare') : ''
    end

    # Construit les boutons

    def build_bouton ope, tit = nil, css = nil
      simple_link("analyser/file/#{id}?op=#{ope}", tit || ope, css)
    end

  end #/AFile
end #/Analyse
