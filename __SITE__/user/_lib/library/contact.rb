# encoding: utf-8
=begin

  Tout ce qui concerne la façon dont l'user veut être contacté.

  On la charge à l'aide de :

      require_lib 'user:contact'


=end
class User

  def world_contact?
    @ww_contact.nil? && @ww_contact = tcontact & 8 > 0
    @ww_contact
  end
  def inscrits_contact?
    @wi_contact.nil? && @wi_contact = tcontact & 4 > 0
    @wi_contact
  end
  def admin_contact?
    @wa_contact.nil? && @wa_contact = tcontact & 2 > 0
    @wa_contact
  end
  def aucun_contact?
    @wn_contact.nil? && @wn_contact = tcontact == 0
    @wn_contact
  end

  def tcontact
    @tcontact ||= (data[:options][4]||'6').to_i(26)
  end

end
