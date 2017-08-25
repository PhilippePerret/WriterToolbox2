# encoding: UTF-8
=begin

  Méthodes exclusivement réservées au program UAUS

=end
class User

  def program_id
    @program_id ||= begin
      # On prend le programme actif
      r = site.db.select(:unan, 'programs', "auteur_id = #{id} AND SUBSTRING(options,1,1) = '1'", [:id])
      r.first[:id]
    end
  end

  def projet_id
    @projet_id ||= begin
      # On prend le projet actif
      r = site.db.select(:unan, 'projets', "auteur_id = #{id} AND SUBSTRING(options,1,1) = '1'", [:id])
      r.first[:id]
    end
  end

end #/User
