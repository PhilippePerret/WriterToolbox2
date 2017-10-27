# encoding: utf-8
#
require './__SITE__/narration/_lib/_required/constants'

class Narration
  class Page

    include PropsAndDbMethods

    attr_reader :id

    def initialize id
      @id = id
    end

    #--------------------------------------------------------------------------------
    #
    #   DONNÉES
    #
    #--------------------------------------------------------------------------------
    def titre       ; @titre        ||= id? ? data[:titre].gsub(/'/,'’') : nil end
    def livre_id    ; @livre_id     ||= data[:livre_id]     end
    def options     ; @options      ||= data[:options]      end
    def description ; @description  ||= data[:description]  end

    # Reseter les données, par exemple après l'enregistrement,
    # pour recalculer toutes les valeurs volatiles.
    def reset
      @btype        = nil
      @type         = nil
      @titre        = nil
      @livre_id     = nil
      @options      = nil
      @description  = nil
      @priority     = nil
      @nivdev       = nil
      @is_only_web  = nil
      @is_page      = nil
      @is_in_livre  = nil
      @md_file      = nil
      @dyn_file     = nil
      @has_id       = nil
    end

    # Propriétés volatiles
    #
    def btype
      @btype ||= id? ? options[0].to_i : nil
    end
    def type
      @type ||=
        begin
          case btype
          when 1 then :page
          when 2 then :sous_chapitre
          when 3 then :chapitre
          when 5 then :texte_type
          else :none
          end
        end
    end
    def priority ; @priority  ||= id? ? options[3].to_i : nil      end
    def nivdev   ; @nivdev    ||= id? ? options[1].to_i(11) : nil  end

    # Options
    def id?       ; @has_id       ||= id != nil         end
    def page?     ; @is_page      ||= type == :page     end
    def in_livre? ; @is_in_livre  ||= livre_id.to_i > 0 end
    def only_web? ; @is_only_web  ||= id? ? options[2] == '1' : nil end


    #--------------------------------------------------------------------------------
    #
    #  METHODES D'ENREGISTREMENT
    #
    #--------------------------------------------------------------------------------

    # Méthode principale qui enregistre les données de la page
    #
    def save
      data_valid? || return

      if id
        site.db.update(:cnarration,'narration',data2save,{id: id})
      else
        @id = site.db.insert(:cnarration,'narration',data2save)
      end

      # On met les nouvelles données et on les dispatche pour pouvoir
      # y avoir accès tout de suite.
      reset
      @data = data2save
      dispatch(@data)

      # Message de confirmation
      __notice "#{type.to_s.titleize} enregistré#{page? ? 'e' : ''}."

      # Si la case "Créer le fichier" est coché, et que le fichier n'existe pas,
      # il faut le créer en créant également le dossier le contenant, qui peut ne
      # pas exister lui non plus.
      if page? && in_livre? && dform[:create_file] && !File.exist?(md_file)
        # Il faut peut-être créer le dossier du fichier
        `mkdir -p "#{File.dirname(md_file)}"`
        File.open(md_file,'wb'){|f| f.write("<!-- Page ##{id} - #{titre} -->\n\n")}
        __notice "Fichier markdown créé."
      end


      # Si le fichier dynamique existe et que des informations déterminantes ont été
      # modifiées, il faut détruire ce fichier dynamique pour forcer la reconstruction
      # de la page.
      page? && in_livre? && require_building? && File.exist?(dyn_file) && File.unlink(dyn_file)

      debug "data2save: #{data2save.inspect}"
    end

    def md_file
      @md_file ||= page? && in_livre? ? File.join(folder_pages,livre_id.to_s, "#{id}.md") : nil
    end
    def dyn_file
      @dyn_file ||= page? && in_livre? ? File.join(folder_pages,livre_id.to_s,"#{id}.dyn.erb") : nil
    end

    def folder_pages
      @folder_pages ||= File.join('.','__SITE__','narration','_data')
    end

    def require_building?
      true # pour le moment, toujours
    end

    # Retourne les données à sauver dans la table
    #
    def data2save
      {
        titre:        dform[:titre],
        livre_id:     dform[:livre_id].to_i,
        options:      options_built,
        description:  dform[:description]
      }
    end

    def options_built
      o = dform[:type].to_s                 # page, sous-chapitre ou chapitre
      o << dform[:nivdev].to_s              # niveau de développement
      o << (dform[:only_web] ? '1' : '0')   # seulement pour livre en ligne
      o << dform[:priority].to_s            # priorité pour la correction
      debug "options : #{o}"
      return o
    end

    # Retourne true si les données sont valides, false dans le cas contraire
    ERRORS = {
      titre_required:  "Il faut impérativement définir le titre."
    }
    def data_valid?
      dform[:titre] || raise('titre_required')
    rescue Exception => e
      debug e
      __error ERRORS[e.message.to_sym]
    else
      return true
    end

    # Retourne les données du formulaire, en les corrigeant si nécessaire
    def dform
      @dform ||=
        begin
          d = param(:page)
          d.each { |k, v| d[k] = v.nil_if_empty }
          [:type, :nivdev, :priority].each{|p| d[p] = d[p].to_i}
          debug "dform = #{d.inspect}"
          d
        end
    end

    def base_n_table ; @base_n_table ||= [:cnarration,'narration'] end
  end #/Page

end #/Narration

def page
  @page ||= Narration::Page.new(site.route.objet_id)
end
