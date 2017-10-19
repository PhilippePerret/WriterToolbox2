# encoding: utf-8
class Analyse
  class << self

    # Le menu message ou lien en haut à droite qui indique le rapport du
    # visiteur avec l'analyse courante, pour savoir s'il est créator, contributeur,
    # etc.
    def visitor_state he
      if analyse.creator?(he.id)
        '<span class="tiny">Vous êtes le créateur de cette analyse.</span>'
      elsif Analyse.has_contributor?(analyse.id, he.id)
        '<span class="tiny">Vous contribuez à cette analyse.</span>'
      elsif he.analyste?
        "<a href=\"analyser/postuler/#{film.id}\" class=\"nodeco\">→ Contribuer</a>"
      else
        "<a href=\"aide?p=analyse%2Fcontribuer\" class=\"nodeco\">→ Devenir analyste</a>"
      end
    end

  end #/<< self


  # Code HTML des LI des fichiers de l'analyse
  def file_list
    if fichiers_analyse.count > 0
      fichiers_analyse.collect do |hfile|
        "<li class=\"file\" id=\"file-#{hfile[:id]}\">#{file_buttons(hfile)}#{hfile[:titre]}</li>"
      end.join
    else
      <<-HTML
      <p class="small">
        Cette analyse ne comporte encore aucun fichier.
        Pour en ajouter, cliquer sur le bouton « + » ci-dessous.
      </p>
      HTML
    end
  end

  # Boutons pour chaque fichier de la liste
  # Noter la différence avec `files_buttons` qui concerne les boutons de
  # tous les fichiers, SOUS la liste.
  def file_buttons hfile
    <<-HTML
    <div class="fright small">
      <a href="analyser/file/#{hfile[:id]}?op=edit" class="btn">edit</a>
      <a href="analyser/file/#{hfile[:id]}?op=rem" class="btn">sup</a>
    </div>
    HTML
  end
  def files_buttons
    btns = Array.new
    btns << simple_link("javascript:UI.toggle('form#new_file_form')", '+', 'btn small')
    btns << new_file_form
    return btns.join('')
  end

  def new_file_form
    <<-HTML
    <form id="new_file_form" method="POST" class="small div-inline lab30pc w50pc" style="display:none">
      <input type="hidden" name="op" value="add_file" />
      <!--
          Titre pour le fichier
          -->
      <div>
        <label for="file_name">Titre du fichier</label>
        <span class="field">
          <input type="text" name="file[name]" id="file_name" />
        </span>
      </div>

      <!--
          Menu pour définir le type du fichier (TYPES_FILES)
          -->
      <div>
        <label for="file_type">Type du fichier</label>
        <span class="field">
          #{menu_type_fichier_analyse}
        </span>
      </div>

      <!--
          Boutons pour enregistrer le fichier
          -->
      <div class="buttons">
        <input type="submit" value="Ajouter ce fichier" />
      </div>
    </form>
    HTML
  end
  def menu_type_fichier_analyse options = nil
    options ||= Hash.new
    options[:name]  ||= "file[type]"
    options[:id]    ||= "file_type"
    Form.build_select(options.merge!(values: FILES_TYPES))
  end

  # Code HTML des LI des contributors de l'analyse
  def contributor_list
    contributors.collect do |hcont|
      "<li class=\"contributor\" id=\"contributor-#{hcont[:id]}\">#{contributor_buttons(hcont)}#{hcont[:pseudo]}</li>"
    end.join
  end

  def contributor_buttons hcont
    hcont[:id] != user.id || (return '')
    # Le bouton de destruction de l'analyste (retrait de l'analyse) n'est accessible que
    # si l'user courant a ce privilège (256) et que ce n'est pas le créateur de l'analyse
    # qui est concerné par ce retrait.
    bouton_remove =
      if hcont[:role] & 32 == 0 && user.role & 256 > 0 # peut détruire des analystes
        "<a href=\"analyser/analyste/#{hcont[:id]}?op=rem\">supprimer</a>"
      end || ''
    <<-HTML
    <div class="fright small">
      <a href="user/contact/#{hcont[:id]}">contacter</a>
      #{bouton_remove}
      
    </div>
    HTML
  end

  # Code HTML des LI des taches de l'analyse
  def tache_list
    if taches_analyse.count > 0
      taches_analyse.collect do |htache|
        "<li class=\"tache\" id=\"tache-#{htache[:id]}\">#{htache[:action]}</li>"
      end.join
    else
      <<-HTML
      <p class="small">
        Cette analyse ne comporte encore aucune tâche. Pour en ajouter une, cliquer sur 
        le bouton « + » ci-dessous.
      </p>
      HTML
    end
  end

  def taches_buttons
    btns = Array.new
    btns << simple_link("javascript:UI.toggle('form#new_tache_form')", '+', 'btn small')
    btns << new_tache_form
    return btns.join('')
  end

  def new_tache_form
    <<-HTML
    <form id="new_tache_form" method="POST" class="small div-inline w50pc lab40pc" style="display:none">
      <input type="hidden" name="op" value="add_tache" />
      <!--
          Tache à exécuter
          -->
      <div>
        <label for="tache_action">Action</label>
        <span class="field">
          <input type="text" name="tache[action]" id="tache_action" />
        </span>
      </div>

      <div>
        <label for="tache_file">Fichier <span>(optionnel)</span></label>
        <span class="field">
          #{menu_fichiers_analyse({id: 'tache_file', name: 'tache[file]'})}
        </span>
      </div>

      <div>
        <label for="tache_echeance">Échéance <span>JJ/MM/AA (l'année est optionnelle)</span></label>
        <span class="field">
          <input type="text" name="tache[echeance]" id="tache_echeance" class="short" />
        </span>
      </div>

      <div>
        <label for="tache_user">Responsable <span>de cette tâche</span></label>
        <span class="field">
          #{menu_contributors( { id: 'tache_user', name: 'tache[user]' } )}
        </span>
      </div>

      <!--
          Boutons pour créer la tache
          -->
      <div class="buttons">
        <input type="submit" value="Ajouter cette tâche" />
      </div>
    </form>
    HTML
    
  end

  def menu_contributors options = nil
    options ||= Hash.new
    options[:id]    ||= 'contributor_id'
    options[:name]  ||= 'contributor[id]'
    Form.build_select(
      options.merge!(
        values: contributors.collect { |h| [ h[:id], h[:pseudo] ] }
      )
    )
  end

  def menu_fichiers_analyse options = nil
    options ||= Hash.new
    options[:name]  ||= 'file[id]'
    options[:id]    ||= 'file_id'
    Form.build_select(options.merge(values: fichiers_analyse))
  end

end #/Analyse

