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
        "<a href=\"analyser/postuler/#{analyse.id}\" class=\"nodeco\">→ Contribuer</a>"
      else
        "<a href=\"aide?p=analyse%2Fcontribuer\" class=\"nodeco\">→ Devenir analyste</a>"
      end
    end

  end #/<< self


  # -------------------------------------------------------------------------------- 
  #
  #    FICHIERS 
  #
  #    Noter qu'il ne s'agit pas des types de documents, qui sont traités
  #    plus bas dans ce module.
  #
  # -------------------------------------------------------------------------------- 


  # Code HTML des LI des fichiers de l'analyse
  def file_list
    if fichiers_analyse.count > 0
      fichiers_analyse.collect do |hfile|
        <<-HTML
        <li class="file" id="file-#{hfile[:id]}">
          #{file_buttons(hfile)}
          <span class="titre">#{hfile[:titre]}</span>
        </li>
        HTML
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
      <a href="analyser/file/#{hfile[:id]}?op=edit" class="small btn">edit</a>
      <a href="analyser/file/#{hfile[:id]}?op=rem" class="small btn warning">sup</a>
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
    <form id="new_file_form" action="" method="POST" class="small div-inline lab30pc w50pc cadresimple" style="display:none">
      <input type="hidden" name="op" value="add_file" />
      <!--
          Titre pour le fichier
          -->
      <div>
        <label for="file_titre">Titre du fichier</label>
        <span class="field">
          <input type="text" name="file[titre]" id="file_titre" />
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
    Form.build_select(options.merge!(values: AFile::FILES_TYPES))
  end

  def menu_fichiers_analyse options = nil
    options ||= Hash.new
    options[:name]  ||= 'file[id]'
    options[:id]    ||= 'file_id'
    Form.build_select(options.merge(values: fichiers_analyse))
  end


  # -------------------------------------------------------------------------------- 
  #
  #     CONTRIBUTEURS
  #
  # -------------------------------------------------------------------------------- 

  
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
  rescue Exception => e
    debug e
    return "[PROBLÈME AVEC user ##{hcont[:id]}]"
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


  # -------------------------------------------------------------------------------- 
  #
  #     TACHES À FAIRE
  #
  # -------------------------------------------------------------------------------- 

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
    <form id="new_tache_form" method="POST" class="small div-inline w50pc lab40pc cadresimple" style="display:none">
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
 
  # -------------------------------------------------------------------------------- 
  #
  #     SPÉCIFICITÉS DE L'ANALYSE
  #
  #     Note : cette partie n'apparait que pour un créateur ou un administrateur
  #
  # -------------------------------------------------------------------------------- 

  DATA_BITS_SPECS = {

    # ATTENTION : bit est 1-start
    
    analysed: {bit: 1, name: 'analysed', label: "Film\nanalysé",
     exp_0: 'n’existe pas', exp_1: 'existe' 
  }, 

  lecon: {bit: 2, name: 'lecon', label: "Leçon\ntirée",
     exp_0: "ne possède pas de <a href=\"aide?p=analyse%2Ftype%2Flecon_tiree_film\">“leçon tirée d’un film”</a>",
     exp_1: "présente une <a href=\"aide?p=analyse%2Ftype%2Flecon_tiree_film\">“leçon tirée d’un film”</a>"
  }, 
  
  tm:  {value: '(bit4 & 1 > 0)', name: 'tm', label: "Analyse\nT.M.",
     exp_0: "n'est pas une <a href=\"aide?p=analyse%2Ftype%2Ftm\">analyse de type TM</a>", 
     exp_1: "est une <a href=\"aide?p=analyse%2Ftype%2Ftm\">analyse de type TM</a> basée autour d'un fichier de collecte"
  }, 

  mye:  {value: '(bit4 & 2 > 0 ? 1 : 0)', name: 'mye', label: "Analyse\nMYE",
     exp_0: "n'est pas une <a href=\"aide?p=analyse%2Ftype%2Fmye\">analyse de type MYE</a>",
     exp_1: "est une <a href=\"aide?p=analyse%2Ftype%2Fmye\">analyse de type MYE</a>"
  }, 

  current:  {bit: 6, name: 'current', label: "En\ncours",
     exp_0: "n'est pas ou plus en cours", exp_1: "est en cours"
  }, 

  visible:  {bit: 5, name: 'visible', label: "&nbsp;\nVisible",
     exp_0: "n’est visible que dans la partie contribution (par tout inscrit au site)",
     exp_1: "est visible dans la partie principale et publique des analyses"
  },

  relect:  {bit: 7, name: 'relect', label: "En\nrelecture",
     exp_0: "n'est pas en relecture", exp_1: "est en relecture, pour correction"
  },

  finish:  {bit: 8, name: 'finish', label: "&nbsp;\nFINIE",
     exp_0: 'n’est pas encore achevée', exp_1: 'est achevée'
  }, 
  
  partiel:   {bit: 9, name: 'partiel', label: "Quelques\nnotes", 
     exp_0: 'est complète', exp_1: 'n’est constituée que de quelques notes, peut-être même une seule',
     last: true
  } 
  }

  # Sauvegarde des spécificités de l'analyse
  #
  def save_specs_analyse

    new_specs = (data[:specs]||'').ljust(16,'0')

    debug "Valeur de new_specs courantes (avant modifs) : #{new_specs}"

    # --------------- SPECS HORS DOCUMENTS ----------------

    # Pour le type de l'analyse (TM, MYE)
    bit4 = 0

    param(:specs).each do |spec_name, spec_value|
      dspec = DATA_BITS_SPECS[spec_name.to_sym]

      # Utile pour le bit 4 par exemple. Sinon, on met simplement la valeur
      # spec_value qui est de 0 ou 1
      checked = spec_value == '1'
      
      if dspec.key?(:bit)

        # <= Cette donnée possède une propriété définissant le bit
        # => Il suffit de mettre la valeur récoltée

        new_specs[dspec[:bit] - 1] = spec_value

      else

        # <= C'est une donnée sans bit
        # => Il y a un autre moyen pour calculer la valeur de la spec
        #    en question.

        case spec_name
        when :tm  then checked && bit4 |= 1
        when :mye then checked && bit4 |= 2
        end

      end
      
    end

    # Le bit déterminant le type de l'analyse
    new_specs[3] = bit4.to_s

    # --------- TRAITEMENT DES DOCUMENTS ------------
    
    param_docs = param(:docs)
    new_bits_document = 0
    TYPES_DOCUMENTS.each do |bit_doc, ddoc|
      if param_docs[bit_doc.to_s.to_sym] == '1'
        new_bits_document |= bit_doc
      else
      end
    end 

    new_specs[11..15] = new_bits_document.to_s(36).rjust(5,'0')

    debug "Nouvelle valeur pour specs : #{new_specs}"

    # On enregistre 
    site.db.update(
      :biblio, 'films_analyses',
      {specs: new_specs},
      {id: self.id}
    )
    # On en a besoin tout de suite, donc il faut rafraichir.
    # Noter que @data[:specs] = nil ou self.data[:specs] ne
    # suffisent pas.
    @data  = nil
    @specs = nil

    __notice('Les nouvelles spécificités de l’analyse ont été enregistrées.')
  end

  # Méthode principale construisant le formulaire des specs du
  # film analysé (donc de son analyse) qui traite les specs propres et la
  # présence des documents dans l'analyse.

  def fieldset_specs
    uanalyser.admin? || uanalyser.creator? || 
      (return "<p>Vous n’êtes pas abilité#{uanalyser.real_user.f_e} à régler cette analyse</p>")

    require_lib 'analyse:types_documents'

    # Si on doit sauver les spécificités
    if param(:op) == 'save_specs'

      # On doit sauver la nouvelle valeur des specs

      save_specs_analyse

    end

    <<-HTML
    <form id="analyse_specs_form" class="nocadre" method="POST"> 
      <input type="hidden" name="op" value="save_specs" />
      #{analyse_specs_panneau}
      #{analyse_documents_panneau}
      <div class="buttons">
        <input type="submit" class="main btn small" value="Enregistrer" />
      </div>
    </form>
    HTML
  end

  # Les boutons qui permettent de déterminer si l'analyse est en cours, si
  # elle est visible, etc.
  def analyse_specs_panneau
    
    # debug "SPECS dans analyse_specs_panneau : #{data[:specs]}"

    specs = (self.data[:specs]||'').split('').collect{|i| i.to_i}


    bit4 = specs[3]

    # Pour mettre les explications sous les boutons
    # C'est un résumé qui explique en langage humain ce que signifie les
    # choix, positifs comme négatifs
    explanations = String.new

    # Pour l'administrateur et le créateur, on place des boutons pressoir pour
    # chaque spécificité de l'analayse dans un formulaire.
    <<-HTML
    <div id="specs_btns" class="container_buttons">
    #{
    DATA_BITS_SPECS.collect do |btn_name, hbtn| 
      if hbtn.key?(:bit)
        hbtn.merge! value: specs[hbtn[:bit]-1] # 1 | 0
      else
        hbtn[:value] = eval(hbtn[:value])
      end

      # Valeur courante
      actif = hbtn[:value] == 1

      style0 = "style=\"display:#{actif ? 'none' : 'block'}\""
      style1 = "style=\"display:#{actif ? 'block' : 'none'}\""
      virg = hbtn[:last] ? '.' : ','
      explanations += <<-HTM
      <li>
        <span id="#{hbtn[:name]}-exp0" #{style0}>#{hbtn[:exp_0]}#{virg}</span>
        <span id="#{hbtn[:name]}-exp1" #{style1}>#{hbtn[:exp_1]}#{virg}</span>
      </li>
      HTM

      # Construire et retourner le bouton poussoir pour
      # régler l'analyse
      bouton_spec(hbtn.merge(actif: hbtn[:value] == 1)).strip
    end.join 
    }
    </div>
    <div class="buttons">
      <input type="submit" class="btn main small" value="Enregistrer" />
    </div>
    <div class="titre">Caractéristiques de cette analyse <span class="small">(en fonction des boutons pressés ci-dessus)</span></div>
    <div>Cette analyse…</div>
    <ul class="explanations">#{explanations}</ul>
    HTML
    
  end

  # Les boutons qui permettent de déterminer les documents que possède cette
  # analyse.
  def analyse_documents_panneau

    # debug "SPECS dans analyse_documents_panneau (prises dans data[:specs]) : #{data[:specs]}"
    # Pour conserver la liste des documents courants

    <<-HTML
    <div id="documents_buttons" class="container_buttons">
    #{
    TYPES_DOCUMENTS.collect do |bit_document, ddocument|
      doc_existe = self.has_doc?(ddocument[:bit])
      ddocument.merge!(existe: doc_existe)
      bouton_document(ddocument, doc_existe)
    end.join
    }
    </div>
    <div class="titre">L'analyse contient les documents <span class="tiny">(conformément aux réglages ci-dessus)</span> :</div>
    <ul id="current_documents">
      #{
       TYPES_DOCUMENTS.collect do |bit_doc, ddocument|
      disp = ddocument[:existe] ? '' : 'none'
      "<li id=\"doc-#{bit_doc}-li\" style=\"display:#{disp}\">#{ddocument[:hname].titleize}</li>"
    end.join
      }
    </ul>
    HTML
  end
  def bouton_spec params
    <<-HTML
    <span class="spec_btn#{params[:actif] ? ' actif' : ''}"
          data-id="#{params[:name]}"
          id="#{params[:name]}_id"
          onclick="changeSpec(this)"
          >#{params[:label].gsub(/\n/,'<br>')}</span>
    <input type="hidden" id="specs_#{params[:name]}" name="specs[#{params[:name]}]" value="#{params[:value]}" />
    HTML
  end

  def bouton_document ddoc, doc_existe
    doc_id = ddoc[:bit]
    doc_value  = doc_existe ? '1' : '0'
    <<-HTML
    <span class="doc_btn#{doc_existe ? ' actif' : ''}"
        data-id="#{doc_id}"
        id="btn_doc-#{doc_id}"
        onclick="changeDocState(this)"
        >#{ddoc[:short_name]||ddoc[:hname]}</span>
    <input type="hidden" id="doc-#{doc_id}-value" name="docs[#{doc_id}]" value="#{doc_value}" />
    HTML
    
  end
end #/Analyse

