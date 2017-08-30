# encoding: UTF-8
class User

  def identified?
    id != nil
  end

  def admin?
    identified? && id < 10
  end

  def homme?
    @is_homme ||= !femme?
  end
  def femme?
    @is_femme ||= @sexe == 'F'
  end

  def suscriber?
    identified? || ( return false )
    if @is_suscribed === nil
      @is_suscribed = is_user_suscribed? || unanunscript?
    end
    @is_suscribed
  end
  alias :suscribed? :suscriber?

  def unanunscript?
    identified? || ( return false )
    if @is_unanunscript === nil
      @is_unanunscript = is_auteur_unanunscript?
    end
    @is_unanunscript
  end

  def analyste?
    identified? || ( return false )
    if @is_analyste === nil
      @is_analyste = get(:options)[16].to_i > 0
    end
    @is_analyste
  end

  def icarien?
    identified? || ( return false )
    if @is_icarien === nil
      @is_icarien = get(:options)[31].to_i > 0
    end
    @is_icarien
  end


  private

  def is_user_suscribed?
    wclause = "user_id = #{id} "+
      "AND objet_id = 'ABONNEMENT' "+
      "AND created_at > #{Time.now.to_i - 1.annee}"
    site.db.count(:cold,'paiements',wclause) > 0
  end

  def is_auteur_unanunscript?
    wclause = "user_id = #{id}" +
      " AND objet_id = '1AN1SCRIPT'" +
      " AND created_at > #{Time.now.to_i - 2.annee}"
    site.db.count(:cold,'paiements',wclause) > 0
  end
end #/User
