# encoding: utf-8
debug "Je charge -> #{__FILE__}"
begin
  raise
rescue Exception => e
  debug e.backtrace.join("\n")
end
class Site


  # ----------------------------------------------------------
  #
  #   MÉTHODES PRINCIPALES
  #
  # ----------------------------------------------------------

  # Retourne le code HTML pour les trois listes de tâches,
  # prêtes à démarrer, courante et accomplies.
  # On rassemble en une seule méthode pour pouvoir charger toutes les données
  # absolues d'un seul coup
  #
  # @param {Symbol} task_type
  #                 :task, :page, :quiz ou :forum
  #
  def define_all_list_taches auteur, task_type
    
    abs_works_ids = Array.new
    
    # On récupère la liste des travaux à commencer
    #
    tready    = taches_to_start(auteur, task_type)
    tcurrent  = taches_courantes(auteur, task_type)
    tdone     = last_taches_done(auteur, task_type)

    # On récupère la liste] de tous les IDs des travaux absolus
    [tready, tcurrent, tdone].each do |liste|
      liste.each { |tdata| abs_works_ids << tdata[:abs_work_id] }
    end

    # Chargement de toutes les données absolues des travaux
    #
    habsworks = Hash.new
    if abs_works_ids.count > 0
      site.db.select(:unan,'absolute_works',"id IN (#{abs_works_ids.join(',')})")
        .each do |habswork|
        habsworks.merge!(habswork[:id] => habswork)
      end
    end

    # À présent, on peut construire les trois listes en envoyant les
    # données relatives des travaux ainsi que les données absolues
    #
    @list_taches_to_start  = build_liste_abs_taches(tready,   habsworks, :ready)
    @list_taches_courantes = build_liste_abs_taches(tcurrent, habsworks, :current)
    @list_taches_done      = build_liste_abs_taches(tdone,    habsworks, :done)
  end

  def list_taches_to_start ; @list_taches_to_start  end
  def list_taches_courantes; @list_taches_courantes end
  def list_last_taches_done; @list_last_taches_done end


  #--------------------------------------------------------------------------------
  #
  #   MÉTHODES DE CONSTRUCTION
  #
  #--------------------------------------------------------------------------------

  # Retourne la liste HTML de tâches +htaches+ de type +type_tache+
  #
  # @param {Array}  htaches
  #                 Liste des Hash contenant les abs-works de type
  #                 +type_tache+
  #
  # @param {Hash}   habsworks
  #                 Table des travaux absolus
  #
  # @param {Symbol} type_tache
  #                 :to_start, :done ou :current
  #
  def build_liste_abs_taches htaches, habsworks, type_tache
    "<ul class=\"work_list\" id=\"work_list-#{type_tache}\">"+
      htaches.collect do |hwork|
        Unan::Abswork.build_card_for_auteur(user, hwork, habsworks[hwork[:abs_work_id]])
    end.join('')+
    '</ul>'
  end

  #--------------------------------------------------------------------------------
  #
  #   MÉTHODES DE DONNÉES
  #
  #--------------------------------------------------------------------------------

  # Noter que dans le nouveau système (WriterToobox 2.0), les nouveaux travaux du
  # jour créent automatiquement des enregistrements de works dans la table de
  # l'auteur. Leur status est 0, on les reconnait à ça.
  def taches_to_start auteur, task_type
    get_user_works(auteur, task_type, "status IN (0, 2, 4)")
  end

  def taches_courantes auteur, task_type
    get_user_works(auteur, task_type, "status & 1 AND ended_at IS NULL")
  end

  def last_taches_done auteur, task_type
    get_user_works(auteur, task_type, "status = 9 ORDER BY ended_at DESC LIMIT 5")
  end

  # Retourne la liste des IDs des abs_works qui correspondent à la
  # where clause +where_clause+ pour l'auteur +auteur+ et son programme courant
  def get_user_works auteur, task_type, where_clause
    site.db.select(
      :users_tables,
      "unan_works_#{auteur.id}",
      "SUBSTRING(options,6,1) = '#{Unan::Abswork::ITYPES[task_type]}' AND program_id = #{auteur.program.id} AND #{where_clause}",
    )
  end

end #/Site
