# encoding: utf-8
class Site


  # ----------------------------------------------------------
  #
  #   MÉTHODES PRINCIPALES
  #
  # ----------------------------------------------------------

  # Retourne le code HTML pour la liste des taches qui doivent
  # être démarrées
  def list_taches_to_start
    build_liste_abs_taches(taches_to_start(user), :ready)
  end

  # Retourne le code HTML pour la liste des taches courantes
  # qui ont été démarrées
  def list_taches_courantes
    build_liste_abs_taches(taches_courantes(user), :current)
  end

  # Retourne le code HTML pour la liste des derniers taches
  # accomplies
  def list_last_taches_done
    build_liste_abs_taches(last_taches_done(user), :done)
  end


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
  # @param {Symbol} type_tache
  #                 :to_start, :done ou :current
  #                 
  def build_liste_abs_taches htaches, type_tache 
    '<ul class="tache_list" id="tache_list-#{type_tache}">'+
      htaches.collect do |htache|
        "<li class=\"tache\" id=\"tache-#{htache[:id]}\">#{htache[:titre]}</li>"
    end.join(',')+
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
  def taches_to_start auteur
    get_abs_works get_abs_works_ids(auteur, "status = 0")
  end

  def taches_courantes auteur
    get_abs_works get_abs_works_ids(auteur, "status = 1 AND ended_at IS NULL")
  end

  def last_taches_done auteur
    get_abs_works get_abs_works_ids(auteur, "status = 9 ORDER BY ended_at DESC LIMIT 5")
  end

  # Retourne le hash des abs-works ayant pour IDs +ids+. C'est l'intégralité
  # des données qui sont retournées
  def get_abs_works ids
    ids.count > 0 || (return Array.new)
    site.db.select(
      :unan,
      'absolute_works',
      "id IN (#{ids.join(',')})"
    )
  end
  
  # Retourne la liste des IDs des abs_works qui correspondent à la
  # where clause +where_clause+ pour l'auteur +auteur+ et son programme courant
  def get_abs_works_ids auteur, where_clause
    site.db.select(
      :users_tables,
      "unan_works_#{auteur_id}",
      "program_id = #{auteur.program.id} AND #{where_clause}",
      [:abs_work_id]
    ).collect{ |hwork| hwork[:abs_work_id] }
  end

end #/Site
