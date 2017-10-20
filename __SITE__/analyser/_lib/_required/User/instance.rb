# encoding: utf-8
class User


  # Rôle que joue l'user dans l'analyse courante (analyse)
  def role
    @role ||= begin
      if data_analyse.nil?
        # raise "# Impossible d'obtenir le role de l'user ##{id} pour l'analyse ##{analyse.id} dans la table `user_per_analyse`."
        debug "# Impossible d'obtenir le role de l'user ##{id} pour l'analyse ##{analyse.id} dans la table `user_per_analyse` (je mets rédacteur occasionnel)."
        1|8
      else
        data_analyse[:role]
      end
    end
  end


  def data_analyse
    @data_analyse ||=
      begin
        where = {user_id: id, film_id: analyse.id}
        site.db.select(:biblio,'user_per_analyse',where).first
      end
  end

end #/User
