# encoding: UTF-8
class Site

  # Tarif pour le paiement du programme UN AN UN SCRIPT et explication de
  # ce tarif en fonction de l'état de l'user, abonné ou non.
  #
  def tarif_et_explication
    explication =
      if user.suscriber?
        "#{Unan.tarif} - #{site.configuration.tarif} — et vous bénéficiez d’un an d’abonnement supplémentaire au site"
      else
        "compris : deux ans d’abonnement complet au site"
      end
    "<span id=\"tarif_unan\">#{montant_displayed} €</span> (#{explication})."
  end

  # On doit utiliser deux méthode `montant_displayed` et `montant` pour les
  # tests car les valeurs ne correspondent pas. Que ce soit en mode test ou en
  # mode production, le montant affiché doit toujours être le bon. En revanche,
  # en mode test, le montant réel n'est que de 0.01 €.
  def montant_displayed
    if user.suscriber?
      Unan.tarif - site.configuration.tarif
    else
      Unan.tarif
    end
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
