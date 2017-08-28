# encoding: UTF-8
class Site

  # Tarif pour le paiement du programme UN AN UN SCRIPT et explication de
  # ce tarif en fonction de l'état de l'user, abonné ou non.
  #
  def tarif_et_explication
    explication =
      if user.suscriber?
        "#{Unan.tarif} - #{site.configuration.tarif} — et vous bénéficiez d'un an d'abonnement supplémentaire au site"
      else
        "compris : deux ans d'abonnement complet au site"
      end
    "#{montant} € (#{explication})."
  end

  def montant
    @montant ||= begin
      if site.offline?
        '0.01'
      elsif user.suscriber?
        Unan.tarif - site.configuration.tarif
      else
        Unan.tarif
      end
    end
  end

end
