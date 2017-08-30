# encoding: UTF-8

require_lib_site

# Ajoute un paiement pour l'user +u+ avec les données +dpaiement+
def add_paiement u, dpaiement
  u.is_a?(User) || begin
    u.is_a?(Fixnum) || raise("Il faut fournir soit un ID d'user soit son instance à la méthode add_paiement")
    u = User.get(u)
  end
  dpaiement[:objet_id] ||= 'ABONNEMENT'
  dpaiement.merge!(user_id: u.id)
  dpaiement[:montant]  ||= (dpaiement[:objet_id] == '1AN1SCRIPT' ? 19.8 : site.configuration.tarif)
  dpaiement[:facture]  ||= "ABVDGFH#{Time.now.to_i.to_s(36)}"[0..31]
  site.db.insert(:cold,'paiements',dpaiement)
  u.instance_variable_set('@is_suscribed', nil)
  u.instance_variable_set('@is_unanunscript', nil)
end

# Vidage de la table des PAIEMENTS
def truncate_table_paiements
  site.db.use_database(:cold)
  site.db.execute('TRUNCATE TABLE paiements;')
end
