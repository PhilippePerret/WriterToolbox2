# encoding: utf-8
class Site

  def montant
    @montant ||= site.configuration.tarif
  end
end 
