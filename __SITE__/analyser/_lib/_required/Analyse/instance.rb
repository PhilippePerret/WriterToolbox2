# encoding: utf-8
class Analyse

  require_lib 'analyse:common'

  # TRUE si l'user d'ID +uid+ est le créateur de cette
  # analyse.
  def creator? uid
    uid.is_a?(User) && uid = uid.id
    uid == self.creator_id
  end


  # Liste des taches
  #
  # Chaque élément de cet Array est un Hash contenant :
  # :id       ID absolu de la tache dans taches_analyses
  # :action   {String} L'action à accomplir
  # :file_id  {Fixnum} Optionnellement, l'ID du fichier visé
  # :user_id  {Fixnum} Le responsable de cette tache
  # :specs    {String} Spécificités de la tache
  # :echeance {Fixnum} Échéance de la tache
  #
  def taches_analyse
    @taches_analyse ||=
      begin
        request = <<-SQL
        SELECT *
          FROM taches_analyses
          WHERE film_id = #{id}
          ORDER BY created_at
        SQL
        site.db.use_database(:biblio)
        site.db.execute(request)
      end
  end

end #/Analyse


# L'analyse courante, pour tout le dossier
def analyse ; Analyse.current end
