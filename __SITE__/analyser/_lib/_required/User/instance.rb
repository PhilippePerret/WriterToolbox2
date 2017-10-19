# encoding: utf-8
class User


  # Rôle que joue l'user dans l'analyse courante (analyse)
  def role
    @role ||= data_analyse[:role]
  end
  

  def data_analyse
    @data_analyse ||=
      begin
        where = {user_id: id, film_id: analyse.id}
        site.db.select(:biblio,'user_per_analyse',where).first
      end
  end
  
end #/User
